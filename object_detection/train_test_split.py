"""
Usage: ** deprecated **
  # From tensorflow/models/
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
from sklearn.model_selection import train_test_split as split
import oci

from PIL import Image
from utils import dataset_util
from collections import namedtuple, OrderedDict

config = oci.config.from_file()
compartment_id = config['tenancy']
object_storage = oci.object_storage.ObjectStorageClient(config)
namespace = object_storage.get_namespace().data

cocoA = b'# SSD with Mobilenet v1 configuration for MSCOCO Dataset.\n# Users should configure the fine_tune_checkpoint field in the train config as\n# well as the label_map_path and input_path fields in the train_input_reader and\n# eval_input_reader. Search for "PATH_TO_BE_CONFIGURED" to find the fields that\n# should be configured.\n\nmodel {\n  ssd {\n    num_classes: '
cocoB = b'\n    box_coder {\n      faster_rcnn_box_coder {\n        y_scale: 10.0\n        x_scale: 10.0\n        height_scale: 5.0\n        width_scale: 5.0\n      }\n    }\n    matcher {\n      argmax_matcher {\n        matched_threshold: 0.5\n        unmatched_threshold: 0.5\n        ignore_thresholds: false\n        negatives_lower_than_unmatched: true\n        force_match_for_each_row: true\n      }\n    }\n    similarity_calculator {\n      iou_similarity {\n      }\n    }\n    anchor_generator {\n      ssd_anchor_generator {\n        num_layers: 6\n        min_scale: 0.2\n        max_scale: 0.95\n        aspect_ratios: 1.0\n        aspect_ratios: 2.0\n        aspect_ratios: 0.5\n        aspect_ratios: 3.0\n        aspect_ratios: 0.3333\n      }\n    }\n    image_resizer {\n      fixed_shape_resizer {\n        height: 300\n        width: 300\n      }\n    }\n    box_predictor {\n      convolutional_box_predictor {\n        min_depth: 0\n        max_depth: 0\n        num_layers_before_predictor: 0\n        use_dropout: false\n        dropout_keep_probability: 0.8\n        kernel_size: 1\n        box_code_size: 4\n        apply_sigmoid_to_scores: false\n        conv_hyperparams {\n          activation: RELU_6,\n          regularizer {\n            l2_regularizer {\n              weight: 0.00004\n            }\n          }\n          initializer {\n            truncated_normal_initializer {\n              stddev: 0.03\n              mean: 0.0\n            }\n          }\n          batch_norm {\n            train: true,\n            scale: true,\n            center: true,\n            decay: 0.9997,\n            epsilon: 0.001,\n          }\n        }\n      }\n    }\n    feature_extractor {\n      type: \'ssd_mobilenet_v1\'\n      min_depth: 16\n      depth_multiplier: 1.0\n      conv_hyperparams {\n        activation: RELU_6,\n        regularizer {\n          l2_regularizer {\n            weight: 0.00004\n          }\n        }\n        initializer {\n          truncated_normal_initializer {\n            stddev: 0.03\n            mean: 0.0\n          }\n        }\n        batch_norm {\n          train: true,\n          scale: true,\n          center: true,\n          decay: 0.9997,\n          epsilon: 0.001,\n        }\n      }\n    }\n    loss {\n      classification_loss {\n        weighted_sigmoid {\n          anchorwise_output: true\n        }\n      }\n      localization_loss {\n        weighted_smooth_l1 {\n          anchorwise_output: true\n        }\n      }\n      hard_example_miner {\n        num_hard_examples: 3000\n        iou_threshold: 0.99\n        loss_type: CLASSIFICATION\n        max_negatives_per_positive: 3\n        min_negatives_per_image: 0\n      }\n      classification_weight: 1.0\n      localization_weight: 1.0\n    }\n    normalize_loss_by_num_matches: true\n    post_processing {\n      batch_non_max_suppression {\n        score_threshold: 1e-8\n        iou_threshold: 0.6\n        max_detections_per_class: 100\n        max_total_detections: 100\n      }\n      score_converter: SIGMOID\n    }\n  }\n}\n\ntrain_config: {\n  batch_size: 24\n  optimizer {\n    rms_prop_optimizer: {\n      learning_rate: {\n        exponential_decay_learning_rate {\n          initial_learning_rate: 0.004\n          decay_steps: 800720\n          decay_factor: 0.95\n        }\n      }\n      momentum_optimizer_value: 0.9\n      decay: 0.9\n      epsilon: 1.0\n    }\n  }\n  fine_tune_checkpoint: "ssd_mobilenet_v1_coco_11_06_2017/model.ckpt"\n  from_detection_checkpoint: true\n  # Note: The below line limits the training process to 200K steps, which we\n  # empirically found to be sufficient enough to train the pets dataset. This\n  # effectively bypasses the learning rate schedule (the learning rate will\n  # never decay). Remove the below line to train indefinitely.\n  num_steps: 200000\n  data_augmentation_options {\n    random_horizontal_flip {\n    }\n  }\n  data_augmentation_options {\n    ssd_random_crop {\n    }\n  }\n}\n\ntrain_input_reader: {\n  tf_record_input_reader {\n    input_path: "data/train.record"\n  }\n  label_map_path: "data/object_detection.pbtxt"\n}\n\neval_config: {\n  num_examples: 8000\n  # Note: The below line limits the evaluation process to 10 evaluations.\n  # Remove the below line to evaluate indefinitely.\n  max_evals: 10\n}\n\neval_input_reader: {\n  tf_record_input_reader {\n    input_path: "data/test.record"\n  }\n  label_map_path: "data/object_detection.pbtxt"\n  shuffle: false\n  num_readers: 1\n  num_epochs: 1\n}\n'

def clean():
    print('Cleaning "models/model/train" and "models/model/eval" directories ...')
    shutil.rmtree('./models/model/train')
    os.mkdir('./models/model/train')
    shutil.rmtree('./models/model/eval')
    os.mkdir('./models/model/eval')
    print('Cleaning config files')
    try:
        os.remove('./data/object_detection.pbtxt')
        os.remove('./models/model/ssd_mobilenet_v1_coco.config')
    except Exception as e: pass
    print('Cleaning "all_labels.csv" from the "images" bucket ...')
    try:
        object_storage.delete_object(namespace, 'images', 'image_labels.csv')
    except Exception as e:
        pass
    print('Cleaning "train_images" and "test_images" buckets ...\n')
    while True:
        for bucket in ['train_images', 'test_images']:
            objects = [f.name for f in object_storage.list_objects(namespace, bucket).data.objects]
            if bucket == 'train_images' and len(objects) == 0: return
            print('Cleaning %s objects from %s bucket ...' % (len(objects), bucket))
            for obj in objects:
                object_storage.delete_object(namespace, bucket, obj)

def transfer_to_bucket(bucket, img_file):
    try:
        img = object_storage.get_object(namespace, 'images', img_file).data.content
        res = object_storage.put_object(namespace, bucket, img_file, img)
    except Exception as e:
        print('Failed on train img_file: %s' % (img_file))
        print(e)

def main():
    row_labels = {}
    pbtxt = ''
    df = pd.DataFrame()
    objects = [f.name for f in object_storage.list_objects(namespace, 'image_labels').data.objects]
    for i, labels in enumerate(objects):
        # Pull the csv from object storage
        obj = object_storage.get_object(namespace, 'image_labels', labels).data.content
        df = df.append(pd.read_csv(io.BytesIO(obj)))
        # Add object name to labels dict for config files
        obj_name = labels.replace('_labels.csv', '')
        
        row_labels[obj_name] = i+1
        pbtxt += 'item {\n    id: '+str(i+1)+'\n    name: \"'+obj_name+'\"\n}\n\n'
    all_labels = df.to_csv(index=False).encode()

    # Update config files
    pbtxt = pbtxt[:-2].encode()
    num_classes = str(len(row_labels.keys())).encode()
    coco = cocoA + num_classes + cocoB
    row_labels = json.dumps(row_labels).encode()

    # Split csv into train and test csv files
    train, test = split(df, test_size=0.25)
    train_labels = train.to_csv(index=False).encode()
    test_labels = test.to_csv(index=False).encode()

    # Write files to object storage
    print('Writing "image_labels.csv" to each respective bucket ...')
    res = object_storage.put_object(namespace, 'images', 'image_labels.csv', all_labels)
    res = object_storage.put_object(namespace, 'train_images', 'image_labels.csv', train_labels)
    res = object_storage.put_object(namespace, 'test_images', 'image_labels.csv', test_labels)

    print('Writing config files to "training" bucket ...')
    res = object_storage.put_object(namespace, 'training', 'object_detection.pbtxt', pbtxt)
    res = object_storage.put_object(namespace, 'training', 'ssd_mobilenet_v1_coco.config', coco)
    res = object_storage.put_object(namespace, 'training', 'row_labels.json', row_labels)

    print('Writing config files to "data/" and "models/model" directories, respectively ...')
    with open('data/object_detection.pbtxt', 'wb') as f:
        f.write(pbtxt)
    with open('models/model/ssd_mobilenet_v1_coco.config', 'wb') as f:
        f.write(coco)

    # Write the corresponding image files to the Train and Test buckets
    """print('Writing %s objects to "train_images" bucket ...' % (len(train)))
    for img_file in train['filename']:
        transfer_to_bucket('train_images', img_file)
    print('Writing %s objects to "test_images" bucket ...' % (len(test)))
    for img_file in test['filename']:
        transfer_to_bucket('test_images', img_file) """

    ## multithreading
    print('Writing %s objects to "train_images" bucket ...' % (len(train)))
    threads = []
    for img_file in train['filename']:
        thread = threading.Thread(target=transfer_to_bucket, args=('train_images', img_file,))
        threads.append(thread)
        thread.start()
    for thread in threads:
        thread.join()  
    threads = []   
    print('Writing %s objects to "test_images" bucket ...' % (len(test)))
    for img_file in test['filename']:
        thread = threading.Thread(target=transfer_to_bucket, args=('test_images', img_file,))
        threads.append(thread)
        thread.start()      
    for thread in threads:
        thread.join()

if __name__ == '__main__':
    clean()
    main()