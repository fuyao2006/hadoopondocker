#!/bin/bash

# the default node number is 3
N=${1:-3}


# start hadoop master container
sudo docker rm -f hdp-master &> /dev/null
echo "start hdp-master container..."
sudo docker run -itd \
                --net=hadoop \
                -p 50070:50070 \
                -p 50010:50010 \
                -p 50020:50020 \
                -p 50075:50075 \
                -p 50090:50090 \
                -p 8020:8020 \
                -p 9000:9000 \
                -p 10020:10020 \
                -p 19888:19888 \
                -p 8030:8030 \
                -p 8031:8031 \
                -p 8032:8032 \
                -p 8040:8040 \
                -p 8042:8042 \
                -p 49707:49707 \
                -p 2122:2122 \
										-p 30022:22 \
                -p 8088:8088 \
                -v /usr/local/hadoop \
                --name hdp-master \
                --hostname hdp-master \
                hadoopbase bash
# &> /dev/null


# start hadoop slave container
i=1
while [ $i -lt $N ]
do
	sudo docker rm -f hdp-slave$i &> /dev/null
	echo "start hdp-slave$i container..."
	sudo docker run -itd \
	                --net=hadoop \
	                --name hdp-slave$i \
	                --hostname hdp-slave$i \
	                hadoopbase bash
	i=$(( $i + 1 ))
done 
#docker attach hdp-master
# get into hadoop master container
sudo docker exec -it hdp-master su - hadoop
