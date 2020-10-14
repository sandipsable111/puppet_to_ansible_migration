#!/bin/bash
source /opt/orange/rover/rover.conf

ACTION=$1

PIDFILE='/opt/orange/alhalla-m_run/valhalla_micro.pid'

case $ACTION in
start)
    $0 status > /dev/null 2>&1
    if [[ $? == 0 ]]; then
        echo "Process is already running"
        exit 1
    fi
    printf "%-50s" "Running 'alhalla-m'..."
    
	#Removed code from here
	
    sleep 1
    if [ -d /proc/$PID ]; then
        echo $PID > $PIDFILE
        printf "%s\n" "Ok"
        exit 0
    else
        printf "%s\n" "Fail"
        exit 1
    fi
;;
status)
    printf "%-50s" "Checking 'alhalla-m'..."
    if [ -f $PIDFILE ]; then
        PID=$(cat $PIDFILE)
        if [[ -d /proc/$PID ]]; then
            cat /proc/$PID/cmdline | grep -q "alhalla-m"
            if [[ $? == 0 ]]; then
                printf "%s\n" "Running"
                exit 0
            fi
        fi
        printf "%s\n" "Process dead but pidfile exists"
        exit 1
    else
        printf "%s\n" "Service not running"
        exit 3
    fi
;;
stop)
    printf "%-50s" "Stopping 'alhalla-m...'"
    $0 status > /dev/null 2>&1
    if [[ $? == 0 ]]; then
        PID=$(cat $PIDFILE)
        kill $PID
        sleep 4
        $0 status > /dev/null 2>&1
        if [[ $? == 0 ]]; then
            printf "%s\n" "Failed"
            exit 1
        else
            rm -f $PIDFILE
            printf "%s\n" "Ok"
            exit 0
        fi
    else
        rm -f $PIDFILE
        printf "%s\n" "Not running"
        exit 0
    fi
;;
*)
    echo "Usage: $0 {status|start|stop}"
    exit 1
esac
