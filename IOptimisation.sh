#!/bin/bash
delay=$(( ( RANDOM % 1080 )  + 412 ))
sleep $delay 
while true; do
cpuusage=$( ps -A -o %cpu | awk '{s+=$1} END {print s ""}' )
irregulardelay=$(( ( ${cpuusage%%.*} ) / 4 ))
echo ------------------- Disk optimisation
#sudo iotop -t 1 -C 1 1
IOPROC=$(sudo iotop -C 1 1 -P | sed 1,1d | sed -n 1p | awk '{print substr($0, index($1,$7))}')
IOPROC=$( echo "${IOPROC}" | tr -d '[:space:]' | tail -c 18 | sed 's/[^0-9]*//g')
#IOTOPPROCESS=$(sudo iotop -t 1 -C 1 1 | sed 1,1d | sed -n 4p | awk '{print substr($0, index($1,$7))}')
sleep 1
IOTOPPROCESSPID=$(sudo iotop -t 1 -C 1 1)
IOTOPPROCESSPID=$( echo "${IOTOPPROCESSPID}" | sed 1,1d | sed -n 4p | awk '{print substr($2, index($11,$7))}' )
sleep 1
#IOTOPPROCESS=$(sudo iotop -t 1 -C 1 1 | sed 1,1d | sed -n 1p | awk '{print substr($0, index($1,$7))}')
#IOTOPPROCESS=$( echo "${IOPROC}" | tr -d '[:space:]' | tail -c 18 | sed 's/[^0-9]*//g')
TOPPROCESS=$( /Volumes/libreperfruntime/bin/ps -c -p $IOTOPPROCESSPID )
TOPPROCESS=$( echo "${TOPPROCESS}" | sed 1,1d | sed -n 1p |sed 's/[^a-zA-Z]*//g' )
sleep 1
TOPPROCESSCPUUSAGE=$( /Volumes/libreperfruntime/bin/ps -o %cpu -c -p $IOTOPPROCESSPID )
TOPPROCESSCPUUSAGE=$( echo "${TOPPROCESSCPUUSAGE}" | sed 1,1d | sed -n 1p | sed 's/[^0-9]*//g' )
sleep 1
echo PROCESS BEING MONITORED $TOPPROCESS CPUUSAGE $TOPPROCESSCPUUSAGE
sudo renice -n 20 $TOPPROCESSPID
#/Volumes/libreperfruntime/bin/kill -CONT $suspendedprocesseng5
echo IO VARIABLE $IOPROC 4999
IOPROCMOD=$IOPROC
IOGUARD=$(( ( RANDOM % 10000 )  + 1000 ))
echo $IOGUARD IO LIMIT
cpulimidle=$(( ( RANDOM % 15 )  + 4 ))
cpulimidle2=$(( ( RANDOM % 100 )  + 50 ))
echo $cpulimidle2 CPU DETECTION
sleep $irregulardelay
#ps -o %cpu -c -p 1143
if [[ $TOPPROCESS != "WindowServer" && $TOPPROCESS != "loginwindow" && $TOPPROCESS != "kernel_task" && $TOPPROCESS != "sh" && $TOPPROCESS != "bash" && $TOPPROCESS != "launchd" && $TOPPROCESS != "UserEventAgent" && $TOPPROCESS != "Terminal" && $TOPPROCESS != "node" && $TOPPROCESS != "spindump" && $TOPPROCESS != "kextd" && $TOPPROCESS != "launchd" && $TOPPROCESS != "coreduetd" && $TOPPROCESS != "SystemUIServer" && $TOPPROCESS != "sudo" && $TOPPROCESS != "Dock" && $TOPPROCESS != "coreaudiod" && $TOPPROCESS != "VBoxSVC" && $TOPPROCESS != "VBoxXPCOMIPCD" ]]; then
  if [[ "$IOPROCMOD" -gt "$IOGUARD" && "${cpuusage%%.*}" -gt "$cpulimidle" && "$TOPPROCESSCPUUSAGE" -lt "$cpulimidle2" ]]; then
     if [ $IOTOPPROCESSPID = 0 ]
		   then
	             invalid
		   else
         echo stopping $IOTOPPROCESSPID IOPS
         osascript -e 'display notification "your computer might be slower culprit $TOPPROCESS" with title "libreperf"'
         /Volumes/libreperfruntime/bin/kill -STOP $IOTOPPROCESSPID
         suspendedprocesseng5=$IOTOPPROCESSPID
         echo Suspending $IOTOPPROCESSPID
         suspendstatuseng5=1
	      fi
      else
        echo continuing $IOTOPPROCESSPID IOPS
        /Volumes/libreperfruntime/bin/kill -CONT $suspendedprocesseng5
        echo Unsuspending $suspendedprocesseng5
        suspendstatuseng5=0
      fi
    else
    echo Guarding system memory
fi
sleep 2
FREE_BLOCKS=$(vm_stat | grep free | awk '{ print $3 }' | sed 's/\.//')
INACTIVE_BLOCKS=$(vm_stat | grep inactive | awk '{ print $3 }' | sed 's/\.//')
SPECULATIVE_BLOCKS=$(vm_stat | grep speculative | awk '{ print $3 }' | sed 's/\.//')
FREE=$((($FREE_BLOCKS+SPECULATIVE_BLOCKS) * 4096 / 1048576))
INACTIVE=$(($INACTIVE_BLOCKS * 4096 / 1048576))
TOTAL=$((($FREE+$INACTIVE)))
if [[ $clamshellinfo = ACSN && $TOTAL -lt "2500" ]]; then
    sudo killall periodic
    sudo killall rsync
    sudo killall ls
  else
    echo awaiting the moment
fi
sleep 5
echo --------------------
done
