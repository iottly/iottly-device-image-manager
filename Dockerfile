# 
# Copyright 2015 Stefano Terna
# 
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
# 
#     http://www.apache.org/licenses/LICENSE-2.0
# 
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
# 


######### mount S3 bucket:
# FROM ubuntu:latest
# 
# RUN apt-get update -qq
# RUN apt-get install -y build-essential libfuse-dev fuse libcurl4-openssl-dev libxml2-dev mime-support automake libtool wget tar unzip
# 
# RUN wget https://github.com/s3fs-fuse/s3fs-fuse/archive/v1.80.tar.gz -O /usr/src/v1.80.tar.gz
# RUN tar xvz -C /usr/src -f /usr/src/v1.80.tar.gz
# RUN cd /usr/src/s3fs-fuse-1.80 && ./autogen.sh && ./configure --prefix=/usr && make && make install
# 
# RUN mkdir /s3bucket


FROM ubuntu:latest
MAINTAINER iottly

EXPOSE 8520

RUN apt-get update

RUN apt-get install -y tar git curl nano wget dialog net-tools build-essential
RUN apt-get install -y python python-dev python-distribute python-pip


RUN mkdir /iottly-device-image-manager

ADD requirements.txt /iottly-device-image-manager/requirements.txt
RUN pip install -r /iottly-device-image-manager/requirements.txt

ADD run_script.sh /iottly-device-image-manager/run_script.sh
ADD /iottly_device_image_manager /iottly-device-image-manager/iottly_device_image_manager
ADD /iottly_device_images_tools /iottly-device-image-manager/iottly_device_images_tools


ENV TERM xterm

# chroot support into raspbian image:
RUN apt-get install -y qemu-user-static

WORKDIR /iottly-device-image-manager
CMD ["./run_script.sh", "iottly_device_image_manager/main.py"] 