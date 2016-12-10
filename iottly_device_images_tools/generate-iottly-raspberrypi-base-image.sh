#!/bin/bash

FILENAME=$1

DEVICEDIR="/iottly-device-image-manager/iottly_device_images/raspberrypi"
BASEIMAGEDIR=$DEVICEDIR/images
BASEIMAGEPATH=$BASEIMAGEDIR/$FILENAME

WHERE=/tmp/$FILENAME

PRELOADBINS=ld.so.preload

mkdir $WHERE

STARTSECTOR=$(file $BASEIMAGEPATH|awk 'BEGIN {RS="startsector"} NR >1 {print $0*512}' | tr ' ' "\n" | awk 'BEGIN {max=$0} NF {max=(max>$0)?max:$0} END {print max}')

echo "mounting image: $FILENAME ..."
mount -o loop,offset=$STARTSECTOR $BASEIMAGEPATH $WHERE
echo "mounted image: $FILENAME ..."


cp /usr/bin/qemu-arm-static $WHERE/usr/bin/
echo "qemu copied"

cp $WHERE/etc/$PRELOADBINS /tmp/$PRELOADBINS
echo "# $(cat $WHERE/etc/$PRELOADBINS)" > $WHERE/etc/$PRELOADBINS
echo "$PRELOADBINS commented"

IOTTLYDEVICEAGENT="iottly-device-agent-py-installer"
mkdir $WHERE/tmp/$IOTTLYDEVICEAGENT
cp -a "/tmp/iottly-device-agent-py/iottly-device-agent-py-installers/installer-builders/raspberry-pi/payload/." $WHERE/tmp/$IOTTLYDEVICEAGENT


echo "#!/bin/bash
cd /tmp/iottly-device-agent-py-installer
/bin/bash installer
" > $WHERE/installer
chmod +x $WHERE/installer
chroot $WHERE qemu-arm-static "/bin/bash installer"
chroot $WHERE qemu-arm-static /bin/bash

cp /tmp/$PRELOADBINS $WHERE/etc/$PRELOADBINS
rm /tmp/$PRELOADBINS
echo "$PRELOADBINS resumed"

rm  $WHERE/usr/bin/qemu-arm-static
echo "qemu removed"

umount $WHERE
echo "raspbian image unmounted"

rmdir $WHERE