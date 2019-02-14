FROM centos
MAINTAINER   fuyao<fuyaoaa@qq.com>
RUN \
yum -y update &&\
yum -y install openssh-server openssh-clients wget net-tools nano yum-utils vim sudo snappy snappy-devel &&\
wget --no-check-certificate --no-cookie --header "Cookie:oraclelicense=accept-securebackup-cookie;" https://download.oracle.com/otn-pub/java/jdk/8u201-b09/42970487e3af4f5aa5bca3f542482c60/jdk-8u201-linux-x64.rpm &&\
rpm -ivh jdk-8u201-linux-x64.rpm &&\
rm -rf jdk-8u201-linux-x64.rpm &&\
yum -y clean packages &&\
groupadd hadoop && useradd -g hadoop -m -s /bin/bash hadoop &&\
usermod -aG wheel hadoop &&\
echo "hadoop ALL=(root) NOPASSWD:ALL" >> /etc/sudoers
#sed -i '/^SELINUX=/c SELINUX=disabled' /etc/sysconfig/selinux

#建立各个目录
RUN mkdir -p /home/hadoop/data/conf

WORKDIR /home/hadoop/data
COPY ./conf /home/hadoop/data/conf

RUN \
wget https://mirrors.tuna.tsinghua.edu.cn/apache/hadoop/common/hadoop-2.9.2/hadoop-2.9.2.tar.gz https://mirrors.tuna.tsinghua.edu.cn/apache/hive/stable-2/apache-hive-2.3.4-bin.tar.gz https://mirrors.tuna.tsinghua.edu.cn/apache/zookeeper/stable/zookeeper-3.4.12.tar.gz https://mirrors.tuna.tsinghua.edu.cn/apache/hbase/stable/hbase-1.4.9-bin.tar.gz https://mirrors.tuna.tsinghua.edu.cn/apache/spark/spark-2.4.0/spark-2.4.0-bin-hadoop2.7.tgz https://mirrors.tuna.tsinghua.edu.cn/apache/kafka/0.10.2.2/kafka_2.12-0.10.2.2.tgz  https://mirrors.tuna.tsinghua.edu.cn/apache/tez/0.9.1/apache-tez-0.9.1-bin.tar.gz https://mirrors.tuna.tsinghua.edu.cn/apache/sqoop/1.4.7/sqoop-1.4.7.bin__hadoop-2.6.0.tar.gz https://mirrors.tuna.tsinghua.edu.cn/apache/flume/stable/apache-flume-1.9.0-bin.tar.gz https://mirrors.tuna.tsinghua.edu.cn/apache/storm/apache-storm-1.0.6/apache-storm-1.0.6.tar.gz https://mirrors.tuna.tsinghua.edu.cn/apache/flink/flink-1.7.1/flink-1.7.1-bin-hadoop28-scala_2.12.tgz&&\

tar -xzf hadoop-2.9.2.tar.gz && \
rm -rf hadoop-2.9.2/share/doc/hadoop/* && \
ln -s hadoop-2.9.2 hadoop && \
rm hadoop-2.9.2.tar.gz &&\

tar -xzf apache-hive-2.3.4-bin.tar.gz && \
ln -s apache-hive-2.3.4-bin hive && \
rm apache-hive-2.3.4-bin.tar.gz &&\

tar -xzf zookeeper-3.4.12.tar.gz && \
ln -s zookeeper-3.4.12 zookeeper && \
rm zookeeper-3.4.12.tar.gz &&\

tar -xzf hbase-1.4.9-bin.tar.gz && \
rm -rf hbase-1.4.9/docs/* && \
ln -s hbase-1.4.9 hbase && \
rm hbase-1.4.9-bin.tar.gz &&\

tar -xzf spark-2.4.0-bin-hadoop2.7.tgz && \
ln -s spark-2.4.0-bin-hadoop2.7 spark && \
rm spark-2.4.0-bin-hadoop2.7.tgz &&\

tar -xzf kafka_2.12-0.10.2.2.tgz && \
ln -s kafka_2.12-0.10.2.2 kafka && \
rm kafka_2.12-0.10.2.2.tgz &&\

tar -xzf apache-tez-0.9.1-bin.tar.gz && \
ln -s apache-tez-0.9.1-bin tez && \
rm apache-tez-0.9.1-bin.tar.gz &&\

tar -xzf sqoop-1.4.7.bin__hadoop-2.6.0.tar.gz && \
rm -rf sqoop-1.4.7.bin__hadoop-2.6.0/docs/* && \
ln -s sqoop-1.4.7.bin__hadoop-2.6.0 sqoop && \
rm sqoop-1.4.7.bin__hadoop-2.6.0.tar.gz &&\

tar -xzf apache-flume-1.9.0-bin.tar.gz && \
rm -rf apache-flume-1.9.0-bin/docs/* && \
ln -s apache-flume-1.9.0-bin flume && \
rm apache-flume-1.9.0-bin.tar.gz &&\

tar -xzf apache-storm-1.0.6.tar.gz && \
rm -rf apache-storm-1.0.6/docs/* && \
ln -s apache-storm-1.0.6 storm && \
rm apache-storm-1.0.6.tar.gz &&\

tar -xzf flink-1.7.1-bin-hadoop28-scala_2.12.tgz && \
ln -s flink-1.7.1 flink && \
rm flink-1.7.1-bin-hadoop28-scala_2.12.tgz &&\

chown -R hadoop.hadoop /home/hadoop/data  &&\
cat /home/hadoop/data/conf/profile >>/etc/profile &&\
cat /home/hadoop/data/conf/limits >>/etc/security/limits.conf &&\
sed -i "/GSSAPIAuthentication /c   GSSAPIAuthentication no" /etc/ssh/ssh_config &&\
cp -a /usr/lib64/libsnappy.so* /home/hadoop/data/hadoop/lib/native/.

#再次建目录
RUN  mkdir  /home/hadoop/data/zookeeper/data && \
mkdir  /home/hadoop/data/zookeeper/datalog  && \
mkdir  -p /home/hadoop/data/hadoop/data/tmp  && \
mkdir  /home/hadoop/data/hadoop/data/namenode && \
mkdir  /home/hadoop/data/hadoop/data/datanode && \
mkdir  /home/hadoop/data/hbase/data &&\
mkdir  /home/hadoop/data/kafka/logsdir &&\
mkdir  /home/hadoop/data/hbase/logs &&\
mkdir  /home/hadoop/data/spark/tmp &&\
chown -R hadoop.hadoop /home/hadoop/data

#配置ssh
USER hadoop
WORKDIR /home/hadoop

RUN ssh-keygen -t rsa -f ~/.ssh/id_rsa -P '' && \
cat ~/.ssh/id_rsa.pub >> ~/.ssh/authorized_keys

#修改配置文件
RUN \
sed -i "/zookeeper.connect=localhost:2181/c zookeeper.connect=hdp-master:2181,hdp-slave1:2181,hdp-slave2:2181" /home/hadoop/data/kafka/config/server.properties &&\
sed -i "/log.dirs=\/tmp\/kafka-logs/c log.dirs=/home/hadoop/data/kafka/logsdir" /home/hadoop/data/kafka/config/server.properties &&\
sed -i "/\#delete.topic.enable=true/c delete.topic.enable=true " /home/hadoop/data/kafka/config/server.properties &&\
sed -i "/export JAVA_HOME=/c export JAVA_HOME=/usr/java/latest" /home/hadoop/data/hadoop/etc/hadoop/hadoop-env.sh &&\
sed -i "/export HADOOP_CONF_DIR=/c export HADOOP_CONF_DIR=/home/hadoop/data/hadoop/etc/hadoop" /home/hadoop/data/hadoop/etc/hadoop/hadoop-env.sh &&\
sed -i "/jobmanager.rpc.address: localhost/c jobmanager.rpc.address:hdp-master " /home/hadoop/data/flink/conf/flink-conf.yaml &&\
cp -a ./data/conf/spark.conf /home/hadoop/data/spark/conf/spark-env.sh &&\
cp -a ./data/conf/slaves /home/hadoop/data/spark/conf/slaves &&\
rm /home/hadoop/data/spark/conf/slaves.template  &&\

cp -a ./data/conf/hbase-regionservers /home/hadoop/data/hbase/conf/regionservers &&\
cat ./data/conf/hbase-env.sh >> /home/hadoop/data/hbase/conf/hbase-env.sh &&\
cp -a ./data/conf/hbase-site.xml /home/hadoop/data/hbase/conf &&\

cp -a ./data/conf/slaves /home/hadoop/data/hadoop/etc/hadoop/slaves &&\
cp -a ./data/conf/core-site.xml /home/hadoop/data/hadoop/etc/hadoop/ &&\
cp -a ./data/conf/hdfs-site.xml /home/hadoop/data/hadoop/etc/hadoop/ &&\
cp -a ./data/conf/mapred-site.xml /home/hadoop/data/hadoop/etc/hadoop/ &&\
cp -a ./data/conf/yarn-site.xml /home/hadoop/data/hadoop/etc/hadoop/ &&\

cp -a ./data/conf/zoo.cfg /home/hadoop/data/zookeeper/conf/zoo.cfg &&\
cp -a ./data/conf/zoo.cfg /home/hadoop/data/flink/conf/zoo.cfg &&\
cp -a ./data/conf/zoo.cfg /home/hadoop/data/kafka/config/zookeeper.properties &&\

cp -a ./data/conf/flink_masters /home/hadoop/data/flink/conf/masters &&\
cp -a ./data/conf/flink_slaves /home/hadoop/data/flink/conf/slaves &&\

cp -a  ./data/conf/config  .ssh/config
#USER root
RUN /home/hadoop/data/hadoop/bin/hdfs namenode -format

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

ENTRYPOINT ["/home/hadoop/data/conf/docker-entrypoint.sh"]
CMD [ "bash", "-c", "sudo /usr/sbin/sshd-keygen -A ;sudo /usr/sbin/sshd;bash"]
