#!/usr/bin/env bash

#Please exetuce this script with the correct bash shell
#The above shebang is for convenience while maintaining a level of security. You should ensure you are running an acceptable bash shell, execute the command "bash passon.sh" manually after checking your PATH, or change the shebang to "#!/usr/bin/env bash" if you're feeling risky and efficient

# A script to expedite the creation of backups between storage devices
# Creates as many copies of given sets of files to as many devices as possible as quickly as possible

# In this file, sets of files defined in a way that the script understands are called "packages"
# These will primarily exist as folders with .passon files or .git subfolders

# All data needed by this script will be stored in one folder per duplication location, called .passon
# All data that could be copied by this script will be located in the "packages" folder
# Packages will be located in numbered subfolders based on their priority, and subfolders based on the hash of the folder contents
# Critical metadata about the package (duplication number, hashes, etc) will be in the root of each package's folder
# Required configuration files (EG duplication number) will be stored in a file called ".passon"
# Speed-enhancing metadata (EG packages sorted by number of copies) will be stored in a file called ".pass". It is mandatory that these files exist, but not that they be up to date. Placeholders for missing metadata will be re-generated at the beginning of a run.
# Root-level metadata will be timestamped, so it will be safe to unmount the device while it is being updated

# This script is intended for transferring files between removable media with lax permissions (EG FAT flash drives) and the home folder of the current user where there has been time available to prioritize and group files them beforehand but not during copying, EG to transfer files via sneakernet to dead drop locations


# Create list of package/file locations
# Use script location, ~, /, and extract disks from df
function getLocationList(){
	# Declare local variables
	local locations;
	local drives;
	local mounts;
	# TODO: May be appropriate to be global
	local allowedDiskTypes
	
	# Array that will hold all locations
	locations=(. ~ /)
	
	# Disk types allowed to be extracted from df
	allowedDiskTypes=(sd hd)
	
	# Stores hardware name, free kilobytes, and mount point of allowed solid state storage (sd or hd, not boot), delimited by spaces
		# Outputs all mounted locations with df (-P for POSIX Portability)
		# Uses sed to:
			# Exclude everything that doesn't begin with /dev/ (we want physical drives)
			# Exclude everything that isn't a sd or hd
			# Change spaces into one tab per column
			# Remove columns we don't need
			# Remove leading /dev/
			# Remove everything mentioning boot (we don't want to mess with boot drives (probably))
	drives=$( \
	df -P \
	| sed \
	-e '#Remove elements mentioning boot' \
	-e '/boot/d' \
	-e '#Find physical devices' \
	-e '/^\/dev\//!d' \
	-e '#Find allowed physical devices' \
	-e '/^\/dev\/'$(echo "\(${allowedDiskTypes[*]}\)" | sed -e '#Change space delimiter to escaped bar' -e 's/ /\\|/')'/!d' \
	-e '#Change groups of spaces into tabs for delimiters' \
	-e 's/ \+/\t/g' \
	-e '#Remove useless columns' \
	-e 's/\([^ ]\+\)\t[^ ]\+\t[^ ]\+\t\([^ ]\+\)\t[^ ]\+\t\([^ ]\+\)/\1 \2 \3/' \
	-e '#Remove leading /dev/' \
	-e 's/^\/dev\///' \
	)
	
	# Extract mount points from drives
	mounts=$(echo "$drives" | sed -e '#Extract mount points' -e 's/[^ ]\+ [^ ]\+ \([^ ]\+\)/\1/')
	
	# Append mount points to locations array
	locations+=($mounts)
	
	# Deduplicate locations
	locations=($(echo ${locations[*]} | sed -e '#Replace spaces with newlines' -e 's/ /\n/g' | awk '!seen[$0]++' -))
	
	# Output locations
	echo ${locations[@]}
}

#TODO: Create list of locations that have the .passon folder
	#TODO: Just check each location returned above
	#TODO: Use "find"
#TODO: Ensure that default folders, files, and metadata exist
	#TODO: Create default folders
	#TODO: If default configuration does not exist, copy it from this script
	#TODO: Generate full metadata on locations where it's missing
	#TODO: If creation of new metadata fails, warn the user, tell user what failed, and ask if writing to the device should be disabled or packages deleted. Use a noneAllSome function, taking a list of packages and returning a list of responses, to allow the user to select which packages should be deleted. This list should not be maintained across main calls. 
#TODO: Output current settings for minimum reserved storage space
#TODO: Ask the user if current minimum storage space settings are acceptable
	#TODO: use a noneAllSome function, taking a list of locations and returning a list of responses, to select which devices' configurations should be edited
#TODO: While storage space remains, 
	#TODO: Find the least duplicated package with the highest priority
		#TODO: use for loop looking at metadata?
	#TODO: Copy package to a target destination
	#TODO: Do O(remaining storage space) updates on metadata (IE incrementing duplication count inline on each device)
#TODO: Notify user that all available storage space has been used
#TODO: Notify user whether all available devices have been marked as copy locations
#TODO: If one or more devices are not marked with .passon, ask if none, all, or select devices should be marked. Use a noneAllSome function, taking a list of locations and returning a list of responses, to allow the user to select which devices should be marked.
#TODO: If one or more device was selected, simply add a .passion folder and run main program again
#TODO: Notify user whether low priority packages are preventing priority packages from being copied
#TODO: Calculate which packages would be deleted per device to allow perfect copying
#TODO: If one or more devices have low priority blockage, use a noneAllSome function, taking a list of locations and returning a list of responses, to allow the user to select which devices should be cleaned
#TODO: For each device to be cleaned, ask the user whether packages should have their priorities changed. Use a noneAllSome function, taking a list of packages and returning a list of responses, to allow the user to select what the priorities of packages should be
	#TODO: Allow the user to list package contents (ls -R)
#TODO: If any packages were re-arranged, modify data appropriately on all devices and run main program again
#TODO: If any devices were marked to be cleaned, clean them so they have enough space for high-priority packages
#TODO: If notify the user that only metadata is being updated, and that it should be safe to kill the program or remove devices
#TODO: For each device,
	#TODO: Create a lock file for root metadata, and store current date in it using 'date +%s'
	#TODO: Do full update of metadata, appending a space and the number of seconds since 1970-01-01 00:00:00 UTC to the filename
	#TODO: Delete lock file
	#TODO: Delete old metadata
