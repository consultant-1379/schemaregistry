#!/bin/bash

mkdir -p /backupdata

if [ "$LOG_OUTPUT" == "stream" ]; then
    /usr/bin/stdout-redirect -redirect file -logfile /logs/brAgent.log -container brAgent -service-id $SERVICE_ID -run="/bragent/scripts/startBrAgent.sh"
elif [ "$LOG_OUTPUT" == "all" ]; then
    /usr/bin/stdout-redirect -redirect all -logfile /logs/brAgent.log -container brAgent -service-id $SERVICE_ID -run="/bragent/scripts/startBrAgent.sh"
else
    /bragent/scripts/startBrAgent.sh
fi