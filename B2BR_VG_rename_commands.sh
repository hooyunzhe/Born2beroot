# Enter superuser mode
su -

# Enter your root password

# Get vim
apt-get install vim

# Rename the volume group
vgrename OLD_NAME NEW_NAME

# Verify that the name has changed
lsblk

# Go to the root directory
cd ..

# Replace instances of old name with new name in 2 files
# Type double dash '--' instead of just one dash '-' if there are any
sed -i 's/OLD_NAME/NEW_NAME/g' /etc/fstab
sed -i 's/OLD_NAME/NEW_NAME/g' /boot/grub/grub.cfg

# Save the UUID of the root volume into a file and copy it
lsblk -o UUID /dev/NEW_NAME/root > temp.txt
vim temp.txt
dd

# Replace the old name of the root volume with its UUID
vim /etc/fstab
change "/dev/mapper/NEW_NAME-root" to "UUID=ROOT_UUID"

# Add the following lines to /etc/default/grub
vim /etc/default/grub
add both
"GRUB_DEVICE=/dev/NEW_NAME/root"
"GRUB_DEVICE_UUID=ROOT_UUID"

# Modify this line in /usr/sbin/grub-mkconfig in order to avoid error in the next part
vim /usr/sbin/grub-mkconfig
/GRUB_DEVICE
change
GRUB_DEVICE="`${grub_probe} --target=device /`"
to
GRUB_DEVICE="`${grub_probe} --target=device /`" || true

# Create symbolic links for all volumes in the volume group to avoid errors in later parts
# Type double dash '--' instead of just one dash '-' if there are any
ln -s /dev/mapper/NEW_NAME-LV_NAME /dev/mapper/OLD_NAME-LV_NAME
example:
ln -s /dev/mapper/NEW_NAME-root /dev/mapper/OLD_NAME-root
ln -s /dev/mapper/NEW_NAME-home /dev/mapper/OLD_NAME-home
ln -s /dev/mapper/NEW_NAME-swap_1 /dev/mapper/OLD_NAME-swap_1

# Replace the old name with the new name in /etc/initramfs-tools/conf.d/resume
# Type double dash '--' instead of just one dash '-' if there are any
sed -i 's/OLD_NAME/NEW_NAME/g' /etc/initramfs-tools/conf.d/resume

# Rebuild the grub config
grub-mkconfig --output=/boot/grub/grub.cfg

# Rebuild the initramfs for all versions of the kernel
update-initramfs -u -k all

# Finally, reboot the system
reboot
