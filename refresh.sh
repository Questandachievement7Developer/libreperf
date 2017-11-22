#!/bin/bash
#Trim Memory algorithm questandachievement7 monitoring cpu memory IO
ramdiskid=memfill
deelsleep=$(( ( RANDOM % 360 )  + 180 ))
clear
while true; do
#mountstart
echo checking status
cpuusage=$( /Volumes/libreperfruntime/bin/cat /Volumes/libreperfruntime/sys/cpu/cpuusage )
FREE=$( /Volumes/libreperfruntime/bin/cat /Volumes/libreperfruntime/sys/mem/free )
INACTIVE=$( /Volumes/libreperfruntime/bin/cat /Volumes/libreperfruntime/sys/mem/inactive )
TOTAL=$( /Volumes/libreperfruntime/bin/cat /Volumes/libreperfruntime/sys/mem/total )
IOPROC=$( /Volumes/libreperfruntime/bin/cat /Volumes/libreperfruntime/sys/IOstats/IOPROC )
size=$(( $TOTAL ))
sizefill=$(( $size - ( $size * 1 / 4 ) ))
sizefillbytes=$(( $sizefill * 1048576 ))
echo filling ram with 0
echo input $TOTAL $cpuusage $IOPROC
echo trigger 2048 30 5000
if [[ $TOTAL -lt 9999 && $cpuusage -lt 400  ]]; then
  echo allocating creating VM
  if [ ! -d "/Volumes/$ramdiskid/" ]; then
  diskutil erasevolume HFS+ "$ramdiskid" `hdiutil attach -nomount ram://$[$size*2048]`
    else
      echo volume exist
    fi
  echo Filling ram with 0 process 1
  echo allocating creating VM may take a while
  mkfile -n -v 1m /Volumes/memfill/purgemod
  dd if=/dev/urandom of=/Volumes/memfill/fill bs=64M count=8
  echo push
  openssl rand -out /Volumes/memfill/0 -base64 $(( $sizefillbytes * 3/4 ))
  echo waiting reactions
  rm -rf /Volumes/$ramdiskid/purgemod
  rm -rf /Volumes/$ramdiskid/0
  rm -rf /Volumes/$ramdiskid/fill
  echo deallocating ram
  sudo dmesg &
  sudo sync
  sudo purge
  sudo killall -KILL Dock
  sudo killall -KILL Finder
  sudo killall -KILL diskimages-helper
  TOTAL2=$( /Volumes/libreperfruntime/bin/cat /Volumes/libreperfruntime/sys/mem/total )
  deltamem=$(( $TOTAL2 - $TOTAL ))
  echo $deltamem Free delta ram
  umount -f /Volumes/memfill
else
  echo conditions seems normal at this point
  exit
fi
sleep 7
exit
done