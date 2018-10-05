"""
Usage: ** deprecated **
  # From tensorflow/object_storage.models/
  # Create train data:
  python generate_tfrecord.py --csv_input=data/train_labels.csv  --output_path=data/train.record
  # Create test data:
  python generate_tfrecord.py --csv_input=data/test_labels.csv  --output_path=data/test.record
"""
from __future__ import division
from __future__ import print_function
from __future__ import absolute_import

import os, io, shutil, json, threading
import pandas as pd
import numpy as np
import tensorflow as tf
import oci

from PIL import Image
from utils import dataset_util
from collections import namedtuple, OrderedDict

#flags = tf.app.flags
#flags.DEFINE_string('split', '', 'Train or Test data')
#flags.DEFINE_string('output_path', '', 'Path to output TFRecord')
#FLAGS = flags.FLAGS

config = oci.config.from_file()
compartment_id = config['tenancy']
object_storage = oci.object_storage.ObjectStorageClient(config)
namespace = object_storage.get_namespace().data
models = oci.object_storage.models

row_labels = json.loads(object_storage.get_object(namespace, 'training', 'row_labels.json').data.content.decode())

"""def split(df, group):
    data = namedtuple('data', ['filename', 'object'])
    gb = df.groupby(group)
    return [data(filename, gb.get_group(x)) for filename, x in zip(gb.groups.keys(), gb.groups)]"""


def create_tf_example(group):
    encoded_img = object_storage.get_object(namespace, 'images', group.filename).data.content
    #with tf.gfile.GFile(os.path.join(path, '{}'.format(group.filename)), 'rb') as fid:
        #encoded_jpg = fid.read()
    #encoded_jpg_io = io.BytesIO(encoded_jpg)
    image = Image.open(io.BytesIO(encoded_img))
    if group.filename.endswith('.png'): 
        image = image.convert('RGB')
    width, height = image.size

    filename = group.filename.encode('utf8')
    image_format = b'jpg'
    xmins = []
    xmaxs = []
    ymins = []
    ymaxs = []
    classes_text = []
    classes = []

    for index, row in group.object.iterrows():
        xmins.append(row['xmin'] / width)
        xmaxs.append(row['xmax'] / width)
        ymins.append(row['ymin'] / height)
        ymaxs.append(row['ymax'] / height)
        classes_text.append(row['class'].encode('utf8'))
        classes.append(row_labels[row['class']])

    tf_example = tf.train.Example(features=tf.train.Features(feature={
        'image/height': dataset_util.int64_feature(height),
        'image/width': dataset_util.int64_feature(width),
        'image/filename': dataset_util.bytes_feature(filename),
        'image/source_id': dataset_util.bytes_feature(filename),
        'image/encoded': dataset_util.bytes_feature(encoded_img),
        'image/format': dataset_util.bytes_feature(image_format),
        'image/object/bbox/xmin': dataset_util.float_list_feature(xmins),
        'image/object/bbox/xmax': dataset_util.float_list_feature(xmaxs),
        'image/object/bbox/ymin': dataset_util.float_list_feature(ymins),
        'image/object/bbox/ymax': dataset_util.float_list_feature(ymaxs),
        'image/object/class/text': dataset_util.bytes_list_feature(classes_text),
        'image/object/class/label': dataset_util.int64_list_feature(classes),
    }))
    return tf_example 
        
  # Create train data:
  # python generate_tfrecord.py --csv_input=data/train_labels.csv  --output_path=data/train.record
  # Create test data:
  # python generate_tfrecord.py --csv_input=data/test_labels.csv  --output_path=data/test.record

def generate_tfrecord(split):
    writer = tf.python_io.TFRecordWriter('data/'+split+'.record')
    labels = object_storage.get_object(namespace, split+'_images', 'image_labels.csv').data.content
    df = pd.read_csv(io.BytesIO(labels))
    
    data = namedtuple('data', ['filename', 'object'])
    gb = df.groupby('filename')
    grouped = [data(filename, gb.get_group(x)) for filename, x in zip(gb.groups.keys(), gb.groups)]

    multipart_upload_details = models.CreateMultipartUploadDetails()
    multipart_upload_details.object = split+'.record'
    multipart_upload = object_storage.create_multipart_upload(namespace, 'tfrecords', multipart_upload_details)
    upload_id = multipart_upload.data.upload_id
    etags = []
    parts_to_commit = []
    parts_to_exclude = []
    for ID, group in enumerate(grouped):
        tf_example = create_tf_example(group)
        part = object_storage.upload_part(namespace, 'tfrecords', split+'.record', upload_id, ID+1, tf_example.SerializeToString())
        detail = models.CommitMultipartUploadPartDetails()
        detail.part_num = ID+1
        if 'etag' in part.headers:
            detail.etag = part.headers['etag']
            parts_to_commit.append(detail)
        else:
            print('Part %s has no ETag' % (ID+1))
            parts_to_exclude.append(ID+1)
        writer.write(tf_example.SerializeToString())
    commit_details = models.CommitMultipartUploadDetails()
    commit_details.parts_to_commit = parts_to_commit
    commit_details.parts_to_exclude = parts_to_exclude
    res = object_storage.commit_multipart_upload(namespace, 'tfrecords', split+'.record', upload_id, commit_details)
    writer.close()
    #output_path = os.path.join(os.getcwd(), "data/"+split_type+".record")
    print('Successfully created the %s TFRecord' % (split))

def main(_):
    try:
        os.remove('./data/test.record')
        os.remove('./data/train.record')
    except Exception as e: pass
    threads = []
    for split in ['train', 'test']:
        print('Generating %s.record file' % (split))
        thread = threading.Thread(target=generate_tfrecord, args=(split,))
        threads.append(thread)
        thread.start()
    for thread in threads:
        thread.join()
        

if __name__ == '__main__':
    tf.app.run()