#!/bin/bash

install_src="/home/vagrant/src/install_src"
install_dist="/bgdt"
share_dir="/home/vagrant/src"
HADOOP_VERSION="2.7.2"
SPARK_VERSION="2.0.0"
SPARK_HADOOP_VERSION="2.7"
HIVE_VERSION="2.1.0"
OOZIE_VERSION="4.3.0"

mariadb_install_dist="/usr/local"
MARIADB_VERSION="10.1.17"
MARIADB_INSTALL_OS="linux-x86_64"

USER_NAME="hadoop"
USER_PASSWD="hadoop"

MASTER_HOSTNAME="hadoop-master"
SLAVE1_HOSTNAME="hadoop-slave1"
SLAVE2_HOSTNAME="hadoop-slave2"

echo "---- [22] SSH Non password process........ ----"

echo y | ssh-keygen -t rsa -f ~/.ssh/id_rsa -P ''
sshpass -p ${USER_PASSWD} ssh-copy-id -o StrictHostKeyChecking=no ${MASTER_HOSTNAME}
sshpass -p ${USER_PASSWD} ssh-copy-id -o StrictHostKeyChecking=no ${SLAVE1_HOSTNAME}
sshpass -p ${USER_PASSWD} ssh-copy-id -o StrictHostKeyChecking=no ${SLAVE2_HOSTNAME}

echo "---- [23] hadoop hdfs Format........ ----"
ssh hadoop-master "rm -rf ${install_dist}/hadoop-${HADOOP_VERSION}/tmp"
ssh hadoop-slave1 "rm -rf ${install_dist}/hadoop-${HADOOP_VERSION}/tmp"
ssh hadoop-slave2 "rm -rf ${install_dist}/hadoop-${HADOOP_VERSION}/tmp"
hadoop namenode -format

echo "---- [24] First start Hadoop Cluster Env......... ----"
bash ${install_dist}/hadoop-${HADOOP_VERSION}/sbin/start-dfs.sh
bash ${install_dist}/hadoop-${HADOOP_VERSION}/sbin/start-yarn.sh
bash ${install_dist}/hadoop-${HADOOP_VERSION}/sbin/mr-jobhistory-daemon.sh start historyserver
nohup ${install_dist}/hive-${HIVE_VERSION}/bin/hive --service hiveserver2 &
bash ${install_dist}/oozie-${OOZIE_VERSION}/bin/oozied.sh start

echo "---- [25] Create start Hadoop Cluster Shell Script file......... ----"
cat > /home/hadoop/start-all-hadoop-cluster-env.sh <<EOF
#!/bin/bash
bash ${install_dist}/hadoop-${HADOOP_VERSION}/sbin/start-dfs.sh
bash ${install_dist}/hadoop-${HADOOP_VERSION}/sbin/start-yarn.sh
bash ${install_dist}/hadoop-${HADOOP_VERSION}/sbin/mr-jobhistory-daemon.sh start historyserver
nohup ${install_dist}/hive-${HIVE_VERSION}/bin/hive --service hiveserver2 &
bash ${install_dist}/oozie-${OOZIE_VERSION}/bin/oozied.sh start
EOF

echo "---- [26] Create stop Hadoop Cluster Shell Script file......... ----"
cat > /home/hadoop/stop-all-hadoop-cluster-env.sh <<EOF
#!/bin/bash
num=\`jps|grep "RunJar"|cut -d' ' -f1\`
if [ "\$num" != "" ];then
kill -9 \$num
echo "hive service(\$num) is deleted"
fi
bash ${install_dist}/oozie-${OOZIE_VERSION}/bin/oozied.sh stop
bash ${install_dist}/hadoop-${HADOOP_VERSION}/sbin/mr-jobhistory-daemon.sh stop historyserver
bash ${install_dist}/hadoop-${HADOOP_VERSION}/sbin/stop-yarn.sh
bash ${install_dist}/hadoop-${HADOOP_VERSION}/sbin/stop-dfs.sh
EOF

echo "---- [27] Modify  Shell Script file mode to 755......... ----"
chmod 755 /home/hadoop/start-all-hadoop-cluster-env.sh
chmod 755 /home/hadoop/stop-all-hadoop-cluster-env.sh

