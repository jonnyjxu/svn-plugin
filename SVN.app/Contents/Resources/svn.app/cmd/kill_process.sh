#!/bin/sh

#  kill_process.sh
#  SVN
#
#  Created by xujun on 2018/5/14.
#  Copyright © 2018年 xujun. All rights reserved.


#根据进程名杀死进程
if [ $# -lt 1 ]
then
echo "缺少参数：procedure_name"
exit 1
fi

PROCESS=`ps -ef|grep $1|grep -v grep|grep -v PPID|awk '{ print $2}'`
for i in $PROCESS
do
echo "Kill the $1 process [ $i ]"
kill -9 $i
done
