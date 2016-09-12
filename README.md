What is this about?

https://github.com/amandeepbatra/killZombieZeppelinsAndSparkShells/wiki/Kill-those-Zombie-Zeppelins-&-Spark-Shells-!

How to execute this?

Prerequisites: 

Python, EMR over Yarn, Should be run on EMR Master, Hadoop Web UI and Spark UI 

To Run: 

sh killZombiesSparkShellsZeppelins.sh
Or setup as cron Job: */10 * * * * sh /mnt/yarnMetricsScripts/killZombies/killZombiesSparkShellsZeppelins.sh > /dev/null 2>/dev/null

Output: 

appsRunning.txt : Will contain currently running apps in yarn in given queues (in yarnAppsRunning.py)
sparkShell.txt: Currently running Spark Shells
zeppelin.txt: Currently running Zeppelins 
killZombies.2016_09_12.log: 

########## Start Thu Sep  8 06:30:01 UTC 2016 ###########
########## Spark Shell Processing ###########
Spark shell not found so killing pid=5502 name=abc memory(KB)=2053520
Spark shell found pid=6196 name=validation-set memory(KB)=3370564
########## Zepplin Processing ###########
Zeppelin not found so killing pid=5741 memory(KB)=2247636 cid=52610
Zeppelin found pid=9785 name=amandeep-Zeppelin memory(KB)=1660872 cid=33721
########## End ###########  

