#USAGE: ./configure-wifi-rpi.sh [path to raspbian image] [wifi SSID] [wifi password]

#docker run -t -d --name testmount -v /s3bucket -e AWSACCESSKEYID=AKIAI47OVV46A2I42RLQ -e AWSSECRETACCESSKEY=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 --privileged --entrypoint /usr/bin/s3fs tests3fs -f iottly-images /s3bucket

CURRENT=`pwd`
PROJECTID=$1
IMAGENAME=$2

DEVICEDIR="/iottly-device-image-manager/iottly_device_images/raspberrypi"
BASEIMAGEDIR=$DEVICEDIR/images
PROJECTIMAGEDIR=$DEVICEDIR/projects/$PROJECTID
PROJECTIMAGEPATH=$PROJECTIMAGEDIR/$IMAGENAME

mkdir $PROJECTIMAGEDIR

cp $BASEIMAGEDIR/$IMAGENAME $PROJECTIMAGEDIR/.

WHERE=/tmp/$PROJECTID.$IMAGENAME
mkdir $WHERE

STARTSECTOR=$(file $PROJECTIMAGEPATH|awk 'BEGIN {RS="startsector"} NR >1 {print $0*512}' | tr ' ' "\n" | awk 'BEGIN {max=$0} NF {max=(max>$0)?max:$0} END {print max}')

echo "mounting image: $PROJECTIMAGEPATH ..."
mount -o loop,offset=$STARTSECTOR $PROJECTIMAGEPATH $WHERE
echo "mounted image: $FILENAME ..."

cd $WHERE
