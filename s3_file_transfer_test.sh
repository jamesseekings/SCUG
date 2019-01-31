#!/bin/bash

#################################################################################
# S3 file transfer test								#
#										#
# This script sets up some temp directories to work in				#
# It then creates some dummy data in one file location (file_location_dd)	#
# It then moves these files to an S3 bucket (file_location_s3)			#
# Then downloads these files from file_location_s3 to the local scratch folder	#
# Then clean everything up before repeating itself (if desired)			#
#################################################################################

# Clear the screen to reduce clutter
clear

# Variable setup (File locations is the only bit that needs manual configuration)

# Set number and size of files to create
read -p "How many files would you like to create? " file_number
read -p "How large (In mebibytes) do you want your file(s) to be? " file_size

# Set file location to put sample data
read -p "Where would you like the temporary data directories created (Ideally locally)? " -e -i ~/s3-file-transfer-test file_location_root
file_location_dd=$file_location_root\/dd			# We will make this on the fly
read -p "Where is your remote storage? " file_location_s3
file_location_scratch=$file_location_root\/scratch		# We will make this on the fly
file_name=file_test

# Tell user what we are going to do
echo ""
echo "We will create some directories to work in:"
echo " $file_location_dd"
echo " $file_location_scratch"
echo ""
echo "We will create $file_number file(s) $file_size MiB in size here $file_location_dd."
echo ""
echo "We will move the file(s) to $file_location_s3."
echo "This simulates writing to remote location."
echo ""
echo "We will download the file(s) from $file_location_s3 to $file_location_scratch."
echo "This simulates reads from remote location."
echo ""
echo "If this is not what you want to do press Ctrl-C and edit the script to change functionality."
echo ""
read -p "How many times do you want to perform this operation? " iterations

for i in $(seq 1 $iterations);
do
 # Create directories
 echo "Creating directories"
 mkdir -p $file_location_dd
 mkdir -p $file_location_scratch

 # Create some test data in file location data
 for i in $(seq 1 $file_number);
 do
  echo "Creating dummy data files"
  dd if=/dev/urandom of=$file_location_dd\/$file_name\_$i count=$file_size bs=1M;
 done

 # Move test data from file location DD to file location S3
 echo "Moving data file(s) from DD to S3"
 aws s3 mv $file_location_dd $file_location_s3 --recursive --exclude "*" --include "$file_name*"

 # Download test data from S3 to scratch folder
 echo "Copying data file(s) from S3 to scratch"
 aws s3 cp $file_location_s3 $file_location_scratch --recursive --exclude "*" --include "$file_name*"

 # Delete test data
 echo "Cleaning up data file(s)"
 aws s3 rm $file_location_s3 --recursive --exclude "*" --include "$file_name*"
 rm -vr $file_location_scratch\/*
 rmdir -v $file_location_dd
 echo "Cleaning up directories"
 rmdir -v $file_location_scratch
 rmdir -v $file_location_root
done
