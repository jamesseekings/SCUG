#!/bin/bash

#######################################################################################
# Amazon data transfer test
#
# This script creates some dummy data files in one file location (file_location_a)
# It then moves these files to a second file location (file_location_b)
# It'll then create a scratch folder (file_location_local_scratch) for download tests
# Then download these files from file_location_b to the local scratch folder
# Then clean everything up before repeating itself (if desired)
#######################################################################################


# Variables (This is the only bit that needs user configuration)

    # Set file size in megabytes (This is more user friendly than using bytes)
    file_size=10

    # Set file location to put sample data
    file_location_root=~/AWS_data_test			# We will make this on the fly
    file_location_a=$file_location_root\/a		# We will make this on the fly
    file_location_b=$file_location_root\/b		# We will make this on the fly
    file_location_scratch=$file_location_root\/scratch	# We will make this on the fly
    file_name=file_test

    # Set number of files to create
    file_number=10

    # Times to perform operation
    iterations=5
    iterations_minus_1=$(echo $(( $iterations - 1 )))	# This is just to correct the number of repeats


# The workflow starts here

# Tell user what we are going to do
clear
echo "We will create some directories to work in;"
echo " $file_location_a"
echo " $file_location_b"
echo " $file_location_scratch"
echo ""
echo "We will create $file_number files $file_size MiB in size here $file_location_a."
echo ""
echo "We will move these files to $file_location_b."
echo ""
echo "We will download the files from $file_location_b to $file_location_scratch."
echo ""
echo "We will clean everything up before repeating this $iterations_minus_1 times."
echo ""
echo "If this is not what you want to do press Ctrl-C and edit the script to change functionality."
echo ""
read -p "If this is what you want press return to continue."

for i in $(seq 1 $iterations);
do
 # Create directories
 echo "Creating directories"
 mkdir -p $file_location_a
 mkdir -p $file_location_b
 mkdir -p $file_location_scratch 
 
 # Create some test data in file location A
 for i in $(seq 1 $file_number);
 do
  echo "Creating dummy data files"
  dd if=/dev/urandom of=$file_location_a\/$file_name\_$i count=$file_size bs=1M;
 done

 # Move test data from file location A to file location B
 echo "Moving data files from A to B"
 mv -v $file_location_a\/$file_name* $file_location_b

 # Download test data from file location B to scratch folder
 echo "Copying data files from B to scratch"
 cp -v $file_location_b\/$file_name* $file_location_scratch

 # Delete test data
 echo "Cleaning up data files"
 rm -vr $file_location_b\/$file_name*
 rm -vr $file_location_scratch\/*
 rmdir -v $file_location_a
 echo "Cleaning up directories"
 rmdir -v $file_location_b
 rmdir -v $file_location_scratch
 rmdir -v $file_location_root
done
