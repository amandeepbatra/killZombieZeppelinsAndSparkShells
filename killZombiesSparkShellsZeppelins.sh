#!/usr/bin/bash

appsRunningFile="/mnt/yarnMetricsScripts/killZombies/appsRunning.txt"
echo "" > $appsRunningFile

yarnSiteXML="/etc/hadoop/conf/yarn-site.xml"
hostname=`cat $yarnSiteXML | grep "<property><name>yarn.resourcemanager.hostname</name><value>" |  grep -o -P '(?<=<value>).*(?=</value>)'`


#Get all the applications which are running in default and non-produciton queues
python /mnt/yarnMetricsScripts/killZombies/yarnAppsRunning.py $appsRunningFile $hostname

now=$(date +"%Y_%m_%d")
logFileName="/mnt/yarnMetricsScripts/killZombies/killZombies."$now".log"
#Removing all log files except todays 
ls /mnt/yarnMetricsScripts/killZombies/killZombies*.log  | grep -v $logFileName | xargs rm

echo "########## Start $(date -u) ###########" >> $logFileName
echo "########## Spark Shell Processing ###########" >> $logFileName

#Get all the spark shells which are running 
sparkShellFileName="/mnt/yarnMetricsScripts/killZombies/sparkShell.txt"
ps -ef | grep -E "class org.apache.spark.repl.Main" | grep -v "grep" > $sparkShellFileName

#Process Spark Shells 
while read -r line
do
	
	pid=`echo $line | awk 'BEGIN {FS=" "}{print $2}'`;
	name=`echo $line | awk 'BEGIN {FS="--name"}{print $3}' | awk 'BEGIN {FS=" "}{print $1}'`;
	mem=`awk '/Rss:/{ sum += $2 } END { print sum }' /proc/$pid/smaps`
	#echo "name="$name "pid="$pid "mem="$mem
	if [ ! -z $name ]; then
		found=`cat $appsRunningFile | grep $name`
		if [ -z $found ]; then
			echo "Spark shell not found so killing pid="$pid "name="$name "memory(KB)="$mem >> $logFileName
			sudo kill -9 $pid
		else
			echo "Spark shell found pid="$pid "name="$name "memory(KB)="$mem >> $logFileName
		fi
	else
		echo "Spark shell not named pid="$pid "memory(KB)="$mem >> $logFileName
	fi
done < $sparkShellFileName

echo "########## Zepplin Processing ###########" >> $logFileName

#Get all the Zeppelins which are running 
zeppelinFileName="/mnt/yarnMetricsScripts/killZombies/zeppelin.txt"
zeppelinJar="zeppelin-spark-0.5.5-incubating-amzn-0.jar"
ps -ef | grep $zeppelinJar | grep -v "grep" > $zeppelinFileName

#Process Zeppellins 
while read -r line
do

        pid=`echo $line | awk 'BEGIN {FS=" "}{print $2}'`;
        mem=`sudo awk '/Rss:/{ sum += $2 } END { print sum }' /proc/$pid/smaps`
	cid=`echo $line | rev | awk 'BEGIN {FS=" "}{print $1}' | rev`;
        found="0"
	while read -r lineAppRunning
	do
		appId=`echo $lineAppRunning | awk 'BEGIN {FS=","}{print $1}'`;
		appName=`echo $lineAppRunning | awk 'BEGIN {FS=","}{print $2}'`;
		curl "http://$hostname:20888/proxy/$appId/environment/" > appEnvironmentDump.log
		if grep -q "$zeppelinJar $cid" appEnvironmentDump.log; then 
			echo "Zeppelin found pid="$pid "name="$appName "memory(KB)="$mem "cid="$cid >> $logFileName
			found="1";	
		fi
	done < $appsRunningFile
	if [ $found -eq "0" ]; then
		echo "Zeppelin not found so killing pid="$pid "memory(KB)="$mem "cid="$cid >> $logFileName
		sudo kill -9 $pid
	fi
done < $zeppelinFileName

echo "########## End ###########" >> $logFileName
