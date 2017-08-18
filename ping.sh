#!/bin/bash
REMOTEHOST=192.168.1.36
REMOTEPORT=3000
TIMEOUT=1

if nc -w $TIMEOUT -z $REMOTEHOST $REMOTEPORT; then
    echo "I was able to connect to ${REMOTEHOST}:${REMOTEPORT}"
    ./run.sh
else
    echo "Connection to ${REMOTEHOST}:${REMOTEPORT} failed. Exit code from Netcat was ($?)."
        for ((sec=5;sec>0;sec--))
        do
                echo "Retry in " $sec
                sleep 1
        done
        ./ping.sh
fi
