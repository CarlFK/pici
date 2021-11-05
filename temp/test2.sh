#!/bin/bash -x
for x in a b c d e
do
    umount /$x/merged
    umount /$x/lower
    rm -rf /$x
    mkdir /$x /$x/lower /$x/upper /$x/work /$x/merged
done

mount -t nfs -o vers=3,ro,noatime 10.21.0.1:/srv/nfs/rpi/buster/root/merged /a/lower
mount -t overlay -o lowerdir=/a/lower,upperdir=/a/upper,workdir=/a/work,default_permissions overlay /a/merged

mount -t nfs -o ro,noatime 10.21.0.1:/srv/nfs/rpi/buster/root/merged /b/lower
mount -t overlay -o lowerdir=/b/lower,upperdir=/b/upper,workdir=/b/work,default_permissions overlay /b/merged

mount -t nfs -o vers=4.1,ro,noatime 10.21.0.1:/srv/nfs/rpi/buster/root/merged /c/lower
mount -t overlay -o lowerdir=/c/lower,upperdir=/c/upper,workdir=/c/work,default_permissions overlay /c/merged

# mount -oremount,noacl $EXPORTED_FS

mount -t nfs -o vers=3,ro,noatime,noacl 10.21.0.1:/srv/nfs/rpi/buster/root/merged /d/lower
mount -t overlay -o lowerdir=/d/lower,upperdir=/d/upper,workdir=/d/work,default_permissions overlay /d/merged

mount -t nfs -o ro,noatime,noacl 10.21.0.1:/srv/nfs/rpi/buster/root/merged /e/lower
mount -t overlay -o vers=4.1,noacl,noatime,lowerdir=/e/lower,upperdir=/e/upper,workdir=/e/work,default_permissions overlay /e/merged


