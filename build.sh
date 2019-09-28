#!/bin/bash
source /etc/profile

cd `dirname $0`
shell_path=`pwd`
para_path=`dirname $PWD`

source $shell_path/downloadfiles
source $shell_path/config
source ${shell_path}/common.sh

work_path=${shell_path}/work
conf_path=${shell_path}/conf

#etc
cp -a $conf_path/etc/*  $work_path/conf
#dockerfile
template $shell_path/Dockerfile > $work_path/Dockerfile
#zookeeper
template $conf_path/zookeeper/zoo.cfg > $work_path/conf/zoo.cfg
#kafka
#template $conf_path/kafka/kafka-env > $work_path/conf/kafka-env
#spark
template $conf_path/spark/spark.conf > $work_path/conf/spark.conf
#hbase
template $conf_path/hbase/hbase-env > $work_path/conf/hbase-env.sh
template $conf_path/hbase/hbase-site.xml > $work_path/conf/hbase-site.xml
template $conf_path/hbase/regionservers > $work_path/conf/hbase-regionservers
#hadoop
template $conf_path/hadoop/hadoop-env > $work_path/conf/hadoop-env.sh
template $conf_path/hadoop/core-site.xml > $work_path/conf/core-site.xml
template $conf_path/hadoop/hdfs-site.xml > $work_path/conf/hdfs-site.xml
template $conf_path/hadoop/mapred-site.xml > $work_path/conf/mapred-site.xml
template $conf_path/hadoop/slaves > $work_path/conf/slaves
template $conf_path/hadoop/yarn-site.xml> $work_path/conf/yarn-site.xml

template $conf_path/flink/slaves > $work_path/conf/flink_slaves
template $conf_path/flink/masters> $work_path/conf/flink_masters
#ssh这个内容需要注意一下
cp -a $conf_path/ssh/ssh_config  $work_path/conf/config
cp -a $conf_path/bin/docker-entrypoint.sh $work_path/conf

cd $work_path

docker build -t hadoopbase .
