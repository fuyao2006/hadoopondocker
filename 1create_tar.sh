#!/bin/bash
source /etc/profile

cd `dirname $0`
shell_path=`pwd`
para_path=`dirname $PWD`

cd ${shell_path}/downloadtmp/tmp

rm -rf $shell_path/work/datatools
mkdir -p $shell_path/work/datatools
for i  in `ls .` ;
do  
tar czvf $shell_path/work/datatools/${i}.tar.gz $i
done


