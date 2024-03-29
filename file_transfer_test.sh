#!/bin/bash

#########################################################################################
# Data transfer test									#
#											#
# This script sets up some temp directories to work in					#
# It then creates some dummy data files in one file location (file_location_a)		#
# It then moves these files to a second file location (file_location_b)			#
# It'll then create a scratch folder (file_location_local_scratch) for download tests	#
# Then download these files from file_location_b to the local scratch folder		#
# Then clean everything up before repeating itself (if desired)				#
#########################################################################################

# Clear the screen to reduce clutter
clear

# Variable setup (File locations is the only bit that needs manual configuration)

# Set number and size of files to create
read -p "How many files would you like to create? " file_number
read -p "How large (In mebibytes) do you want your file(s) to be? " file_size

# Set file location to put sample data
read -p "Where would you like the temporary data directories created (Ideally locally)? " -e -i ~/data-transfer-test file_location_root
file_location_a=$file_location_root\/a			# We will make this on the fly
file_location_b=$file_location_root\/b			# We will make this on the fly
file_location_scratch=$file_location_root\/scratch	# We will make this on the fly
file_name=file_test

# Tell user what we are going to do
echo ""
echo "We will create some directories to work in:"
echo " $file_location_a"
echo " $file_location_b"
echo " $file_location_scratch"
echo ""
echo "We will create $file_number file(s) $file_size MiB in size here $file_location_a."
echo ""
echo "We will move the file(s) to $file_location_b."
echo "This simulates writing to remote location."
echo ""
echo "We will download the file(s) from $file_location_b to $file_location_scratch."
echo "This simulates reads from remote location."
echo ""
echo "If this is not what you want to do press Ctrl-C and edit the script to change functionality."
echo ""
read -p "How many times do you want to perform this operation? " iterations

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
 echo "Moving data file(s) from A to B"
 mv -v $file_location_a\/$file_name* $file_location_b

 # Download test data from file location B to scratch folder
 echo "Copying data file(s) from B to scratch"
 cp -v $file_location_b\/$file_name* $file_location_scratch

 # Delete test data
 echo "Cleaning up data file(s)"
 rm -vr $file_location_b\/$file_name*
 rm -vr $file_location_scratch\/*
 rmdir -v $file_location_a
 echo "Cleaning up directories"
 rmdir -v $file_location_b
 rmdir -v $file_location_scratch
 rmdir -v $file_location_root
done
