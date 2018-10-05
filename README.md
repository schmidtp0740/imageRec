# TensorFlow Models

This repository contains a number of different models implemented in [TensorFlow](https://tensorflow.org):

The [official models](official) are a collection of example models that use TensorFlow's high-level APIs. They are intended to be well-maintained, tested, and kept up to date with the latest stable TensorFlow API. They should also be reasonably optimized for fast performance while still being easy to read. We especially recommend newer TensorFlow users to start here.

The [research models](research) are a large collection of models implemented in TensorFlow by researchers.

The [tutorial models](tutorials) are models described in the [TensorFlow tutorials](https://www.tensorflow.org/tutorials/).

# Prerequisites
- Python 3.5
- Protobuf 3.4

# Installation Steps
- pip install -r requirements.txt
- cd research
- protoc object_detection/protos/*.proto --python_out=.
- export PYTHONPATH=$PYTHONPATH:`pwd`:`pwd`/slim