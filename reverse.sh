#!/bin/bash

########################
#Check for requirements#
########################
#zenity=$(which zenity)
#if [ "$zenity" == "" ]; then
#    echo "You must have zenity installed"
#    exit 1
#fi

# Check if avconv in installed, fallback to ffmpeg (avconv's previous name, still used on some systems)

avconv=$(which avconv)
if [ "$avconv" == "" ]; then
	avconv=$(which ffmpeg)
fi

if [ "$avconv" == "" ]; then
#    zenity --error --text="You must have avconv installed"
    echo "You must have either avconv or ffmpeg installed."
    exit 1 
fi

##############################
#Check command line arguments#
##############################

if [ -z $1 ]; then
    echo "No input file supplied."
    exit 1
fi

if [ ! -e $1 ]; then
    echo "File $1 does not exist."
    exit 1
fi

if [ -z $2 ]; then
    output_file='reversed_'$1
else
    output_file=$2
fi

if [ -e $output_file ]; then
    echo "File $output_file already exists."
    exit 1
fi

#ffmpeg=$(which ffmpeg)
#if [ "$ffmpeg" == "" ]; then
#	echo "You must have ffmpeg installed"
#	exit 1
#fi
##################################
#Spawn frames into images/ folder#
##################################
mkdir images
cd images
$avconv -i ../$1 %d.jpg

##############
#Count images#
##############
images=0

for i in $(ls | grep .jpg); do
    let images=images+1
done
#####################################
#Rename images in the opposite order#
#####################################
i=1
factor=0
while [ $factor -lt $images ]; do
    new_name=$((images-factor))
    printf $new_name' '
    mv $i.jpg image$new_name.jpg
    let factor=factor+1
    let i=i+1
done
echo ''

###############################################
#Finally convert newly named images into video#
###############################################
#$avconv -f image2 -i image%d.jpg -vcodec mjpeg -b 12000k -r 30 ../$output_file
$avconv -f image2 -i image%d.jpg -vcodec mpeg4 ../$output_file

#######################
#Remove temporal files#
#######################
rm *jpg
