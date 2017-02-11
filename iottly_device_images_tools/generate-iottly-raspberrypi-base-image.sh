#!/bin/bash

FILENAME=$1
VERSION=$2


DEVICEDIR="/iottly-device-image-manager/iottly_device_images/raspberrypi"
ORIGINALIMAGEDIR=$DEVICEDIR/original-images
ORIGINALIMAGEPATH=$ORIGINALIMAGEDIR/$FILENAME


IOTTLYCUSTOMIMAGEFILENAME=${FILENAME%.*}_iottly_$VERSION.${FILENAME##*.}
IOTTLYCUSTOMIMAGEDIR=$DEVICEDIR/iottly-customized-images
IOTTLYCUSTOMIMAGEPATH=$IOTTLYCUSTOMIMAGEDIR/$IOTTLYCUSTOMIMAGEFILENAME

# this is crytical, moving file in S3 takes a lot of time
cp $ORIGINALIMAGEPATH $IOTTLYCUSTOMIMAGEPATH

WHERE=/tmp/$IOTTLYCUSTOMIMAGEFILENAME

PRELOADBINS=ld.so.preload

#apt-get install -y binfmt-support

mkdir $WHERE

STARTSECTOR=$(file $IOTTLYCUSTOMIMAGEPATH|awk 'BEGIN {RS="startsector"} NR >1 {print $0*512}' | tr ' ' "\n" | awk 'BEGIN {max=$0} NF {max=(max>$0)?max:$0} END {print max}')

echo "mounting image: $IOTTLYCUSTOMIMAGEFILENAME ..."
mount -o loop,offset=$STARTSECTOR $IOTTLYCUSTOMIMAGEPATH $WHERE
echo "mounted image: $IOTTLYCUSTOMIMAGEFILENAME ..."


cp /usr/bin/qemu-arm-static $WHERE/usr/bin/
echo "qemu copied"

cp $WHERE/etc/$PRELOADBINS /tmp/$PRELOADBINS
echo "# $(cat $WHERE/etc/$PRELOADBINS)" > $WHERE/etc/$PRELOADBINS
echo "$PRELOADBINS commented"

IOTTLYDEVICEAGENT="iottly-device-agent-py-installer"
mkdir $WHERE/tmp/$IOTTLYDEVICEAGENT
cp -a "/iottly-device-agent-py-installers/installer-builders/raspberry-pi/payload/." $WHERE/tmp/$IOTTLYDEVICEAGENT


echo "#!/bin/bash
cd /tmp/iottly-device-agent-py-installer
./installer
" > $WHERE/installer
chmod +x $WHERE/installer
chroot $WHERE /installer

cp /tmp/$PRELOADBINS $WHERE/etc/$PRELOADBINS
rm /tmp/$PRELOADBINS
echo "$PRELOADBINS resumed"

rm  $WHERE/usr/bin/qemu-arm-static
echo "qemu removed"

umount $WHERE
echo "raspbian image unmounted"

rmdir $WHERE