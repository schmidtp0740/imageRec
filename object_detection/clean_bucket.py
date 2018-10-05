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

import os, io, shutil, json
import oci

from PIL import Image
from collections import namedtuple, OrderedDict

config = oci.config.from_file()
compartment_id = config["tenancy"]
object_storage = oci.object_storage.ObjectStorageClient(config)
namespace = object_storage.get_namespace().data

def main():
    bucket = input('Which bucket to clean: ')
    objects = [f.name for f in object_storage.list_objects(namespace, bucket).data.objects]
    print('Erasing %s objects ...' % (len(objects)))
    for obj in objects:
        object_storage.delete_object(namespace, bucket, obj)

if __name__ == '__main__':
    main()