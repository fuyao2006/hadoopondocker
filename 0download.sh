#!/bin/bash
source /etc/profile

cd `dirname $0`
shell_path=`pwd`
para_path=`dirname $PWD`

source $shell_path/downloadfiles
source $shell_path/config
source ${shell_path}/common.sh

mkdir -p ${shell_path}/downloadtmp/tmp
cd ${shell_path}/downloadtmp
for i in `sed -n '/^[a-zA-Z]/p' ${shell_path}/downloadfiles | awk -F '=' '{print $2}' ` ;
do  
 axel $i
 j=${i##*\/}
 k=${j##"apache-"}
 m=${k%%[0-9-_]*}
 mkdir $m
 tar xzvf $j -C $m
 mv $m/* tmp/$m
# rm $j
 rm -rf $m
done


