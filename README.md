# How to Deploy on OCI
- provision a BM.GPU or VM.GPU shape in OCI
- Image should be Ubuntu 16.04
- Allow the following in the security lists
    - TCP - 5000

# Install nvidia-docker
```
sudo apt-get update -y

sudo apt-get install  -y \
    apt-transport-https \
    ca-certificates \
    curl \
    software-properties-common

curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -

sudo add-apt-repository \
   "deb [arch=amd64] https://download.docker.com/linux/ubuntu \
   $(lsb_release -cs) \
   stable"

sudo apt-get update

sudo apt-get install -y docker-ce

sudo usermod -aG docker $USER

sudo su ubuntu

curl https://get.docker.com | sudo CHANNEL=stable sh

curl -s -L https://nvidia.github.io/nvidia-docker/gpgkey | sudo apt-key add -
curl -s -L https://nvidia.github.io/nvidia-docker/ubuntu16.04/nvidia-docker.list \
  | sudo tee /etc/apt/sources.list.d/nvidia-docker.list

sudo apt-get update && sudo apt-get install -y nvidia-docker2
sudo sed -i 's/^#root/root/' /etc/nvidia-container-runtime/config.toml

sudo tee /etc/modules-load.d/ipmi.conf <<< "ipmi_msghandler"
sudo tee /etc/modprobe.d/blacklist-nouveau.conf <<< "blacklist nouveau"
sudo tee -a /etc/modprobe.d/blacklist-nouveau.conf <<< "options nouveau modeset=0"
sudo update-initramfs -u

# Optionally, if the kernel is not up to date
# sudo apt-get dist-upgrade

sudo reboot

sudo docker run -d --privileged --pid=host -v /run/nvidia:/run/nvidia:shared \
  --restart=unless-stopped nvidia/driver:396.37-ubuntu16.04 --accept-license

sudo docker run --rm --runtime=nvidia nvidia/cuda:9.2-base nvidia-smi




```

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