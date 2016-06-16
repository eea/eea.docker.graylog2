#! /bin/bash
LOGS=$(awk -v d1="$(date -u --date="-5 min" "+%Y-%m-%d %H:%M:%S.000")" \
       -v d2="$(date -u "+%Y-%m-%d %H:%M:%S.%3N")" \
       '$0 > d1 && $0 < d2 || $0 ~ d2' /opt/graylog2/log/graylog-server.log \
       | grep "ERROR: org.graylog2.alarmcallbacks.EmailAlarmCallback - Stream" )

if [[ $LOGS ]]; then
   kill -9 `cat /tmp/graylog.pid`
   /opt/graylog2/bin/graylogctl start
   echo "$(date -u "+%Y-%m-%d %H:%M:%S.%3N") Graylog server restarted"  >> $LOGFILE
fi
