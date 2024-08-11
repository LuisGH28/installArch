#!/usr/bin/evn bash

# Configurar el reloj
timedatectl set-ntp true

# Particionamiento de disco (ajustar según tus necesidades)
(
echo o;
echo n;
echo p;
echo 1;
echo ;
echo +512M;
echo n;
echo ;
echo ;
echo w;
) | fdisk /dev/sda

# Formatear las particiones
mkfs.ext4 /dev/sda1
mkfs.ext4 /dev/sda2

# Montar las particiones
mount /dev/sda2 /mnt
mkdir /mnt/boot
mount /dev/sda1 /mnt/boot

# Instalar el sistema base
pacstrap /mnt base linux linux-firmware

# Generar fstab
genfstab -U /mnt >> /mnt/etc/fstab

# Entrar en chroot
arch-chroot /mnt <<EOF

# Configurar la zona horaria
ln -sf /usr/share/zoneinfo/Region/City /etc/localtime
hwclock --systohc

# Configurar localización
echo "LANG=en_US.UTF-8" > /etc/locale.conf
echo "en_US.UTF-8 UTF-8" > /etc/locale.gen
locale-gen

# Configurar nombre de host
echo "nombre_host" > /etc/hostname

# Instalar y configurar GRUB
pacman -S grub --noconfirm
grub-install --target=i386-pc /dev/sda
grub-mkconfig -o /boot/grub/grub.cfg

# Establecer contraseña root
echo "root:tu_contraseña" | chpasswd

EOF

# Desmontar y reiniciar
umount -R /mnt
reboot
