#!/bin/bash
source /etc/profile
a=`hostname`
b=${#a}
c=${a:$b-1:1}
d=`echo $c | awk '{print int($0)}'`

if [ "$d" -eq "0"  ] ;then  d=3; fi 
echo ${d} > $ZOOKEEPER_DATA_HOME/myid
sed -i "/^broker.id=0/c broker.id=${d}" $KAFKA_HOME/config/server.properties
sudo -u hadoop /home/hadoop/data/zookeeper/bin/zkServer.sh start &
/usr/sbin/sshd -D &
exec "$@"

