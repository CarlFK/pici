mkdir boot
cd boot

mkdir img  lower  upper work merged

# export http_proxy=http://pc8:8000
wget -N http://downloads.raspberrypi.org/raspios_lite_armhf/images/raspios_lite_armhf-2020-05-28/2020-05-27-raspios-buster-lite-armhf.zip
unzip 2020-05-27-raspios-buster-lite-armhf.zip

sudo kpartx -av 2020-05-27-raspios-buster-lite-armhf.img
sudo mount /dev/mapper/loop0p1 img

# this errors:
sudo mount -t overlay overlay -olowerdir=img,upperdir=upper,workdir=work merged
# this too
sudo mount  -o ro -t overlay overlay -olowerdir=img,upperdir=upper,workdir=work merged

# this does not
cp img/* lower/
sudo mount -t overlay overlay -olowerdir=lower,upperdir=upper,workdir=work merged

