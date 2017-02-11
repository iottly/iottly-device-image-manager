# License

Copyright 2015 Stefano Terna

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.

# iottly-device-image-manager

This project deals with device images. For now Raspberry Pi, raspbian images.

There are four levels of images:
- original raspbian images (stored in `iottly_device_images/raspberrypi/original-images`)
- iottly customized rasbian images, with agent installed (stored in `iottly_device_images/raspberrypi/iottly-customized-images`)
- per-project customized iottly rasbian images, with specific project parameters (stored in `iottly_device_images/raspberrypi/project-customized-images`)
- per-board customized images, with specific connection parameters, like wifi SSID (to be defined)

This project has two goals:

1. batch generation of base Iottly customized images for raspberry Pi
  - starting from original raspbian images
2. on demand (via rest) generation of per-project Iottly images for raspberry Pi
  - starting from the Iottly customized images

## Batch generation of base Iottly customized images for raspberry Pi
(This part is almost finished, just some further testing needed)

The batch generation of base Iottly customized images is a **lenghty process**.

It is performed by manually running this script: [generate-iottly-raspberrypi-base-image.sh](https://github.com/iottly/iottly-device-image-manager/blob/dev-images-mgmt/iottly_device_images_tools/generate-iottly-raspberrypi-base-image.sh)

The script should be run from inside the service container (see 'how to run the service in dev env')

- `./generate-iottly-raspberrypi-base-image.sh 2016-11-25-raspbian-jessie-lite.img V1.2`
- it takes as input the following parameters:
  - the name of the file of the original image (which is expected to be stored in `iottly_device_images/raspberrypi/original-images` directory)
  - the version tag of the customized iottly image
- it copies the original image into the `iottly_device_images/raspberrypi/iottly-customized-images` directory
- it mounts the copied image into an ARM emulated env (with qemu)
- it runs the agent installer (taking it from the volume mounted from `iottly-device-agent-py`)
  - the agent installer runs as if it was inside a raspberry pi (thanks to qemu) and performs all the apt-get and pip stuff to have iottly agent installed
  - some user interaction could be required depending on what is happening inside the apt-get
- after installation completes, the image is unmounted and the result is a customized iottly `.img` file.

 
## On demand (via rest) generation of per-project Iottly images for raspberry Pi
(this part has to be almost entirely developed, just the tornado api server has been setup)

Tornado (in `iottly_device_image_manager`) exposes a REST API, which:
- takes as input a json containing all the required parameters to be injected into the image
  - project id
  - (optional) board wifi settings (SSID, password)
- runs the script `customize-iottly-raspberrypi-base-image.sh`
  - the script is incomplete
  - it must take the parameters incoming from the API call and inject them in the proper places inside the image.
  - here some examples on how to inject parameters into the image: [configure-wifi-rpi.sh](https://github.com/iottly/iottly-device-agent-py/blob/master/iottly-device-tools/configure-wifi-rpi.sh)
- returns the URL at which the image can be downloaded

### S3 in production
For this service to be run in production, all the `iottly_device_images` subfolders have to be mounted from S3.
Some code for mounting S3 volumes is commented in the [Dockerfile](https://github.com/iottly/iottly-device-image-manager/blob/dev-images-mgmt/Dockerfile)

Is mounting that way the right way to do things?
- The script `customize-iottly-raspberrypi-base-image.sh` performs a copy of the image, this is quite lenghty on S3 (already tested).

# How to run the service in dev env
(These are temporary instructions, untill the code won't be on master.)

1. checkout branch `dev-images-mgmt` of this repo (already done if you are reading this readme ;)
2. checkout branch `dev-images-mgmt` of repo [iottly-docker](https://github.com/iottly/iottly-docker/tree/dev-images-mgmt)
  - the compose of this branch will run the service, mounting the correct volume ([iottlyagentinstallers](https://github.com/iottly/iottly-docker/blob/dev-images-mgmt/docker-compose.yml#L79)) from the repo [iottly-device-agent-py](https://github.com/iottly/iottly-device-agent-py), where the agent installer files are stored.
3. run the following command (to avoid starting the entire Iottly stack): 
  - `cd ../iottly-docker`
  - `docker-compose up -d iottlydeviceimagemanager`
  - (to jump into the service bash) `docker exec -i -t iottlydocker_iottlydeviceimagemanager_1 /bin/bash`
