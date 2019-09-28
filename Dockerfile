FROM java8
MAINTAINER   fuyao<fuyao@qq.com>
RUN \
	apk update && \
	apk -U upgrade && \
	sed -i "/CREATE_MAIL_SPOOL=yes /c  CREATE_MAIL_SPOOL=no" /etc/default/useradd &&\
	groupadd ${hadoopuser} && useradd -g ${hadoopuser} -m ${hadoopuser} &&\
	usermod -aG wheel ${hadoopuser} &&\
	echo "${hadoopuser} ALL=(root) NOPASSWD:ALL" >> /etc/sudoers &&\
 echo "${hadoopuser}:${hadoopuser}" | chpasswd

#建立各个目录
RUN mkdir -p ${workdir}/conf

WORKDIR ${workdir}
COPY ./conf ${workdir}/conf

USER ${hadoopuser}
ADD ./datatools/* ${workdir}/
USER root
RUN \
cat ${workdir}/conf/profile >>/etc/profile &&\
cat ${workdir}/conf/limits >>/etc/security/limits.conf &&\
cp -a /usr/lib/libsnappy.so* ${workdir}/hadoop/lib/native/ &&\
ln -s ${workdir}/hadoop/lib/native/libsnappy.so.1 ${workdir}/hadoop/lib/native/libsnappy.so  &&\
#再次建目录
		 mkdir  ${zoodatadir} && \
		 mkdir  ${zoodatalogdir}  && \
		 mkdir  -p ${htmpdir}  && \
		 mkdir  ${namedir} && \
		 mkdir  ${datadir} && \
		 mkdir  ${hbasetmpdir} &&\
		 mkdir  ${kafka_logsdir} &&\
		 mkdir  ${workdir}/hbase/logs &&\
		 mkdir  ${workdir}/spark/tmp &&\
		 chown -R ${hadoopuser}.${hadoopuser} ${zoodatadir} &&\
chown -R ${hadoopuser}.${hadoopuser} ${zoodatalogdir} &&\
chown -R ${hadoopuser}.${hadoopuser} ${htmpdir} &&\
chown -R ${hadoopuser}.${hadoopuser} ${namedir} &&\
chown -R ${hadoopuser}.${hadoopuser} ${datadir} &&\
chown -R ${hadoopuser}.${hadoopuser} ${hbasetmpdir} &&\
chown -R ${hadoopuser}.${hadoopuser} ${kafka_logsdir} &&\
chown -R ${hadoopuser}.${hadoopuser} ${workdir}/hbase/logs &&\
chown -R ${hadoopuser}.${hadoopuser} ${workdir}/spark/tmp &&\
		chmod 777 /etc/ssh/ssh_host_rsa_key

#配置ssh
USER ${hadoopuser}
WORKDIR /home/${hadoopuser}

RUN ssh-keygen -t rsa -f ~/.ssh/id_rsa -P '' && \
   cat ~/.ssh/id_rsa.pub >> ~/.ssh/authorized_keys

#修改配置文件
RUN \
	sed -i "/zookeeper.connect=localhost:2181/c zookeeper.connect=${master}:2181,${slave1}:2181,${slave2}:2181" ${workdir}/kafka/config/server.properties &&\
	sed -i "/log.dirs=\/tmp\/kafka-logs/c log.dirs=${kafka_logsdir}" ${workdir}/kafka/config/server.properties &&\
	sed -i "/\#delete.topic.enable=true/c delete.topic.enable=true " /home/hadoop/data/kafka/config/server.properties &&\
	sed -i "/export JAVA_HOME=/c export JAVA_HOME=${java_home}" ${workdir}/hadoop/etc/hadoop/hadoop-env.sh &&\
	sed -i "/export HADOOP_CONF_DIR=/c export HADOOP_CONF_DIR=${workdir}/hadoop/etc/hadoop" ${workdir}/hadoop/etc/hadoop/hadoop-env.sh &&\
	sed -i "/jobmanager.rpc.address: localhost/c jobmanager.rpc.address:${master} " ${workdir}/flink/conf/flink-conf.yaml &&\
	 cp -a ./data/conf/spark.conf ${workdir}/spark/conf/spark-env.sh &&\
	 cp -a ./data/conf/slaves ${workdir}/spark/conf/slaves &&\
	 rm ${workdir}/spark/conf/slaves.template  &&\

	 cp -a ./data/conf/hbase-regionservers ${workdir}/hbase/conf/regionservers &&\
	 cat ./data/conf/hbase-env.sh >> ${workdir}/hbase/conf/hbase-env.sh &&\
	 cp -a ./data/conf/hbase-site.xml ${workdir}/hbase/conf &&\

	 cp -a ./data/conf/slaves ${workdir}/hadoop/etc/hadoop/slaves &&\
	 cp -a ./data/conf/core-site.xml ${workdir}/hadoop/etc/hadoop/ &&\
	 cp -a ./data/conf/hdfs-site.xml ${workdir}/hadoop/etc/hadoop/ &&\
	 cp -a ./data/conf/mapred-site.xml ${workdir}/hadoop/etc/hadoop/ &&\
	 cp -a ./data/conf/yarn-site.xml ${workdir}/hadoop/etc/hadoop/ &&\

	 cp -a ./data/conf/zoo.cfg ${workdir}/zookeeper/conf/zoo.cfg &&\
	 cp -a ./data/conf/zoo.cfg ${workdir}/flink/conf/zoo.cfg &&\
	 cp -a ./data/conf/zoo.cfg ${workdir}/kafka/config/zookeeper.properties &&\

	 cp -a ./data/conf/flink_masters ${workdir}/flink/conf/masters &&\
	 cp -a ./data/conf/flink_slaves ${workdir}/flink/conf/slaves &&\

	 cp -a  ./data/conf/config  .ssh/config &&\
	chmod 600 .ssh/config

#USER root
#RUN ${workdir}/hadoop/bin/hdfs namenode -format

#zookeeper
EXPOSE 2181 2888 3888
# Hdfs ports
EXPOSE 50010 50020 50070 50075 50090 8020 9000 9001 10000
# Mapred ports
EXPOSE 10020 19888
#Yarn ports
EXPOSE 8030 8031 8032 8033 8040 8042 8088
#Other ports
EXPOSE 49707 2122 22
#spark
EXPOSE 7077 4040 18080
#未知
EXPOSE 7373 7946 50475 8060 50060 2818 60000 60010
#flink
EXPOSE 6123 8081
USER root
ENTRYPOINT ["${workdir}/conf/docker-entrypoint.sh"]
