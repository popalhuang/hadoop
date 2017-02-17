#!/bin/bash

install_src="/home/vagrant/src/install_src"
install_dist="/bgdt"

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

setHosts(){
echo "---- [0] add hosts........ ----"
cat > /etc/hosts <<EOF
192.168.51.4 ${MASTER_HOSTNAME}
192.168.51.5 ${SLAVE1_HOSTNAME}
192.168.51.6 ${SLAVE2_HOSTNAME}
EOF
}

function createHadoopUser(){
echo "---- [1] Create hadoop user........ ----"
pass=$(perl -e 'print crypt($ARGV[0], "password")' ${USER_PASSWD});	
useradd -m -p $pass -s /bin/bash ${USER_NAME}
echo "${USER_NAME}    ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers;
}

function installLibrary(){
echo "---- [2] Create Directory,install deb for Ubuntu........ ----"		
mkdir -p ${install_dist}/java
dpkg -i ${install_src}/deb/*.deb
}

function closeIpv6forUbuntu(){
echo "---- [3] stop ipv6 service........ ----"
echo "net.ipv6.conf.all.disable_ipv6 = 1" 		>> /etc/sysctl.conf
echo "net.ipv6.conf.default.disable_ipv6 = 1"   >> /etc/sysctl.conf
echo "net.ipv6.conf.lo.disable_ipv6 = 1" 		>> /etc/sysctl.conf
sysctl -p
}
function installJDK(){
echo "---- [4] Install Java JDK 1.8........ ----"
tar -zxf ${install_src}/jdk-8u101-linux-x64.tar.gz -C ${install_dist}/java
}
function modifyBashrc(){
echo "---- [5] Modify User bashrc file........ ----"
echo "export JAVA_HOME=${install_dist}/java/jdk1.8.0_101" >> /home/${USER_NAME}/.bashrc;
echo "export HADOOP_HOME=${install_dist}/hadoop-${HADOOP_VERSION}" >> /home/${USER_NAME}/.bashrc;
echo "export HADOOP_CONF_DIR=${install_dist}/hadoop-${HADOOP_VERSION}/etc/hadoop" >> /home/${USER_NAME}/.bashrc;
echo "export HIVE_HOME=${install_dist}/hive-${HIVE_VERSION}" >> /home/${USER_NAME}/.bashrc;
echo "export SPARK_HOME=${install_dist}/spark-${SPARK_VERSION}" >> /home/${USER_NAME}/.bashrc;
echo "export OOZIE_HOME=${install_dist}/oozie-${OOZIE_VERSION}" >> /home/${USER_NAME}/.bashrc;
echo "export MAVEN_HOME=${install_dist}/maven-3.2.2" >> /home/${USER_NAME}/.bashrc;
echo "export CLASSPATH=\$CLASSPATH:\$HADOOP_HOME/lib/*:." >> /home/${USER_NAME}/.bashrc;
echo "export CLASSPATH=\$CLASSPATH:\$HADOOP_HOME/share/hadoop/common/*:." >> /home/${USER_NAME}/.bashrc;
echo "export CLASSPATH=\$CLASSPATH:\$HIVE_HOME/lib/*:." >> /home/${USER_NAME}/.bashrc;
echo "export CLASSPATH=\$CLASSPATH:\$HIVE_HOME/lib/mysql-connector-java-5.1.39-bin.jar" >> /home/${USER_NAME}/.bashrc;
echo "export PATH=\$PATH:\$JAVA_HOME/bin:\$HADOOP_HOME/bin:\$HADOOP_HOME/sbin:\$HIVE_HOME/bin:\$SPARK_HOME/bin:\$SPARK_HOME/sbin:\$OOZIE_HOME/bin:\$MAVEN_HOME/bin" >> /home/${USER_NAME}/.bashrc;
echo "export PYSPARK_PYTHON=python3" >> /home/${USER_NAME}/.bashrc;
source /home/${USER_NAME}/.bashrc
}

function installHadoop(){
echo "---- [6] Install hadoop ${HADOOP_VERSION}........ ----"
tar -zxf ${install_src}/hadoop-${HADOOP_VERSION}.tar.gz -C ${install_dist}
echo "export JAVA_HOME=${install_dist}/java/jdk1.8.0_101" >> ${install_dist}/hadoop-${HADOOP_VERSION}/etc/hadoop/hadoop-env.sh
sed -i 's/<value>0.1<\/value>/<value>0.5<\/value>/' /bgdt/hadoop-2.7.2/etc/hadoop/capacity-scheduler.xml
}

function modifyCoreSiteXML(){
echo "---- [7] Modify core-site.xml........ ----"
cat > ${install_dist}/hadoop-${HADOOP_VERSION}/etc/hadoop/core-site.xml <<EOF
<?xml version="1.0" encoding="UTF-8"?>
<?xml-stylesheet type="text/xsl" href="configuration.xsl"?>
<configuration>
<property>
   <name>fs.defaultFS</name>
   <value>hdfs://${MASTER_HOSTNAME}:8020</value>
</property>
<property>
   <name>hadoop.tmp.dir</name>
   <value>file:${install_dist}/hadoop-${HADOOP_VERSION}/tmp</value>
   <description>Abase for other temporary directories.</description>
</property>
<property>
	<name>hadoop.proxyuser.hadoop.hosts</name>
	<value>*</value>    
</property>
<property>
	<name>hadoop.proxyuser.hadoop.groups</name>
	<value>*</value>    
</property>
</configuration>
EOF
}
function modifyHdfsSiteXML(){
echo "---- [8] Modify hdfs-site.xml........ ----"
cat > ${install_dist}/hadoop-${HADOOP_VERSION}/etc/hadoop/hdfs-site.xml <<EOF
<?xml version="1.0" encoding="UTF-8"?>
<?xml-stylesheet type="text/xsl" href="configuration.xsl"?>
<configuration>
<property>
   <name>dfs.namenode.secondary.http-address</name>
   <value>${MASTER_HOSTNAME}:50090</value>
</property>
<property>
   <name>dfs.replication</name>
   <value>1</value>
</property>
<property>
   <name>dfs.namenode.name.dir</name>
   <value>file:${install_dist}/hadoop-${HADOOP_VERSION}/tmp/dfs/name</value>
</property> 
<property>
   <name>dfs.datanode.data.dir</name>
   <value>${install_dist}/hadoop-${HADOOP_VERSION}/tmp/dfs/data</value>
</property>
<property>
   <name>dfs.block.size</name>
   <value>64M</value>   
</property>
</configuration>
EOF
}
function modifyMapredSiteXML(){
echo "---- [9] Modify mapred-site.xml........ ----"
cat > ${install_dist}/hadoop-${HADOOP_VERSION}/etc/hadoop/mapred-site.xml <<EOF
<?xml version="1.0" encoding="UTF-8"?>
<?xml-stylesheet type="text/xsl" href="configuration.xsl"?>
<configuration>
<property>
   <name>mapreduce.framework.name</name>
   <value>yarn</value>
</property>
<property>
   <name>mapreduce.jobhistory.address</name>
   <value>${MASTER_HOSTNAME}:10020</value>
</property>
<property>
   <name>mapreduce.jobhistory.webapp.address</name>
   <value>${MASTER_HOSTNAME}:19888</value>
</property>
</configuration>
EOF
}
function modifyYarnSiteXML(){
echo "---- [10] Modify yarn-site.xml........ ----"
cat > ${install_dist}/hadoop-${HADOOP_VERSION}/etc/hadoop/yarn-site.xml <<EOF
<?xml version="1.0" encoding="UTF-8"?>
<?xml-stylesheet type="text/xsl" href="configuration.xsl"?>
<configuration>
<property>
	<name>yarn.resourcemanager.hostname</name>
	<value>${MASTER_HOSTNAME}</value>
</property>
<property>
	<name>yarn.nodemanager.aux-services</name>
	<value>mapreduce_shuffle</value>
</property>
<property>
	<name>yarn.log.server.url</name>
	<value>http://${MASTER_HOSTNAME}:19888/jobhistory/logs</value>
</property>
</configuration>
EOF
}
function modifySlaves(){
echo "---- [11] Modify slaves........ ----"
cat > ${install_dist}/hadoop-${HADOOP_VERSION}/etc/hadoop/slaves <<EOF
${SLAVE1_HOSTNAME}
${SLAVE2_HOSTNAME}
EOF
}
function modifyExcludes(){
echo "---- [12] Modify excludes........ ----"
cat > ${install_dist}/hadoop-${HADOOP_VERSION}/etc/hadoop/excludes <<EOF
EOF
}
function installMariaDB(){
echo "---- [13] Install MariaDB........ ----"
groupadd mysql
useradd -g mysql mysql
cd ${mariadb_install_dist}
tar -zxf ${install_src}/mariadb-${MARIADB_VERSION}-${MARIADB_INSTALL_OS}.tar.gz -C ${mariadb_install_dist}
ln -s mariadb-${MARIADB_VERSION}-${MARIADB_INSTALL_OS} mysql
cd mysql
./scripts/mysql_install_db --user=mysql
chown -R root .
chown -R mysql data
cd ${mariadb_install_dist}/mysql
./bin/mysqld --user=root &

cat > /etc/rc.local <<EOF
#!/bin/sh -e
cd ${mariadb_install_dist}/mysql
./bin/mysqld --user=root &
exit 0
EOF
}
function installSpark(){
	echo "---- [14] Install Spark........ ----"
	tar -zxf ${install_src}/spark-${SPARK_VERSION}-bin-hadoop${SPARK_HADOOP_VERSION}.tgz -C ${install_dist}
	mv ${install_dist}/spark-${SPARK_VERSION}-bin-hadoop${SPARK_HADOOP_VERSION} ${install_dist}/spark-${SPARK_VERSION}
	cp ${install_src}/mysql-connector-java-5.1.39-bin.jar ${install_dist}/spark-${SPARK_VERSION}/jars
	cp ${install_src}/ojdbc6.jar ${install_dist}/spark-${SPARK_VERSION}/jars
}
function installHive(){
	echo "---- [15] Install Hive........ ----"
	tar -zxf ${install_src}/apache-hive-${HIVE_VERSION}-bin.tar.gz -C ${install_dist}
	mv ${install_dist}/apache-hive-${HIVE_VERSION}-bin ${install_dist}/hive-${HIVE_VERSION}
	cp ${install_src}/mysql-connector-java-5.1.39-bin.jar ${install_dist}/hive-${HIVE_VERSION}/lib
}
function createHiveSiteXML(){
echo "---- [16] create hive-site.xml........ ----"
cat > ${install_dist}/hive-${HIVE_VERSION}/conf/hive-site.xml <<EOF
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<configuration>
<property>
	<name>javax.jdo.option.ConnectionURL</name>
	<value>jdbc:mysql://127.0.0.1:3306/metastore_db</value>
	<description>JDBC connect string for a JDBC metastore </description>
</property>
<property>
	<name>javax.jdo.option.ConnectionDriverName</name>
	<value>com.mysql.jdbc.Driver</value>
	<description>Driver class name for a JDBC metastore</description>
</property>
<property>
	<name>javax.jdo.option.ConnectionUserName</name>
	<value>root</value>
	<description>username to use against metastore database</description>
</property>
<property>
	<name>javax.jdo.option.ConnectionPassword</name>
	<value>!QAZxsw2</value>
	<description>password to use against metastore database</description>
</property>
</configuration>
EOF
ln -s ${install_dist}/hive-${HIVE_VERSION}/conf/hive-site.xml ${install_dist}/spark-${SPARK_VERSION}/conf/hive-site.xml
}
function compilerOOZIE(){
echo "---- [17] Compiler OOZIE........ ----"
export JAVA_HOME=${install_dist}/java/jdk1.8.0_101
tar -zxf ${install_src}/apache-maven-3.2.2-bin.tar.gz -C ${install_dist}
mv ${install_dist}/apache-maven-3.2.2 ${install_dist}/maven-3.2.2

tar -zxvf ${install_src}/oozie-${OOZIE_VERSION}.tar.gz -C ${install_dist}
cd ${install_dist}/oozie-${OOZIE_VERSION}
${install_dist}/maven-3.2.2/bin/mvn clean package assembly:single -DskipTests -Dhadoop.vaersion=2.7.2 -Dspark.version=2.0.0
cp ${install_dist}/oozie-${OOZIE_VERSION}/distro/target/oozie-${OOZIE_VERSION}-distro.tar.gz ${install_src}
}
function InstallOOZIE(){
echo "---- [18] Install OOZIE........ ----"
tar -zxf ${install_src}/oozie-${OOZIE_VERSION}-distro.tar.gz -C ${install_dist}
mkdir -p ${install_dist}/oozie-${OOZIE_VERSION}/libext
cp ${install_dist}/hadoop-${HADOOP_VERSION}/share/hadoop/*/*.jar ${install_dist}/oozie-${OOZIE_VERSION}/libext/
cp ${install_dist}/hadoop-${HADOOP_VERSION}/share/hadoop/*/lib/*.jar ${install_dist}/oozie-${OOZIE_VERSION}/libext/
cp ${install_src}/ext-2.2.zip ${install_dist}/oozie-${OOZIE_VERSION}/libext
rm -rf ${install_dist}/oozie-${OOZIE_VERSION}/libext/jsp-api-2.1.jar

#mkdir -p ${install_dist}/oozie-${OOZIE_VERSION}/oozie
#cd ${install_dist}/oozie-${OOZIE_VERSION}/oozie
#/bgdt/java/jdk1.8.0_101/bin/jar -xvf ../oozie.war
#rm -rf ./WEB-INF/lib/hadoop-*-2.6.0.jar
#/bgdt/java/jdk1.8.0_101/bin/jar cvf ../oozie.war *.* .
#rm -rf ${install_dist}/oozie-${OOZIE_VERSION}/oozie

cd ${install_dist}/oozie-${OOZIE_VERSION}
./bin/oozie-setup.sh prepare-war
./bin/oozie-setup.sh db create -run
}

function modifyOozieSiteXML(){
echo "---- [19] modify oozie-site.xml........ ----"
cat > ${install_dist}/oozie-${OOZIE_VERSION}/conf/oozie-site.xml <<EOF
<?xml version="1.0"?>
<configuration>
<property>
  <name>oozie.service.WorkflowAppService.system.libpath</name>
  <value>/user/hadoop/share/lib</value>
</property>
<property>
  <name>oozie.service.HadoopAccessorService.hadoop.configurations</name>
  <value>*=${install_dist}/hadoop-${HADOOP_VERSION}/etc/hadoop</value>
</property>
<property>
  <name>oozie.use.system.libpath</name>
  <value>true</value>
</property>
<property>
  <name>oozie.service.SparkConfigurationService.spark.configurations</name>
  <value>*=${install_dist}/spark-${SPARK_VERSION}/conf</value>
</property>
</configuration>
EOF
}

function installOOZIEShareLibrary(){
echo "---- [20] install oozie sharelib........ ----"
tar -zxf oozie-sharelib-${OOZIE_VERSION}.tar.gz	

mv ${install_dist}/oozie-${OOZIE_VERSION}/share/lib/spark ${install_dist}/oozie-${OOZIE_VERSION}/share/lib/spark_bak
mkdir -p ${install_dist}/oozie-${OOZIE_VERSION}/share/lib/spark

cp ${install_dist}/spark-${SPARK_VERSION}/jars/* ${install_dist}/oozie-${OOZIE_VERSION}/share/lib/spark 
cp ${install_dist}/oozie-${OOZIE_VERSION}/share/lib/spark_bak/oozie-sharelib-spark-${OOZIE_VERSION}.jar ${install_dist}/oozie-${OOZIE_VERSION}/share/lib/spark
cp ${install_dist}/oozie-${OOZIE_VERSION}/share/lib/oozie/oozie-sharelib-oozie-${OOZIE_VERSION}.jar ${install_dist}/oozie-${OOZIE_VERSION}/share/lib/spark
cp ${install_src}/mysql-connector-java-5.1.39-bin.jar ${install_dist}/oozie-${OOZIE_VERSION}/share/lib/spark
cp ${install_src}/ojdbc6.jar ${install_dist}/oozie-${OOZIE_VERSION}/share/lib/spark
cp ${install_dist}/hive-${HIVE_VERSION}/conf/hive-site.xml ${install_dist}/oozie-${OOZIE_VERSION}/share/lib/spark
sed -i 's/127.0.0.1/hadoop-master/' ${install_dist}/oozie-${OOZIE_VERSION}/share/lib/spark/hive-site.xml

rm -rf ${install_dist}/oozie-${OOZIE_VERSION}/share/lib/spark_bak

tar -zxf oozie-examples.tar.gz
}

function InitHiveMetaStore(){
echo "---- [21] Init Hive Meta Store........ ----"
export JAVA_HOME=${install_dist}/java/jdk1.8.0_101
${mariadb_install_dist}/mysql/bin/mysqladmin -u root password '!QAZxsw2'
echo "GRANT ALL PRIVILEGES ON *.* TO 'root'@'%' IDENTIFIED BY '\!QAZxsw2' WITH GRANT OPTION" | ${mariadb_install_dist}/mysql/bin/mysql -u root --password=\!QAZxsw2
echo "create database metastore_db" | ${mariadb_install_dist}/mysql/bin/mysql -u root --password=\!QAZxsw2
export HADOOP_HOME=${install_dist}/hadoop-${HADOOP_VERSION}
${install_dist}/hive-${HIVE_VERSION}/bin/schematool -dbType mysql -initSchema
}

if [ ! -d ${install_dist} ]; then
setHosts
createHadoopUser
installLibrary
closeIpv6forUbuntu
installJDK
modifyBashrc
installHadoop
modifyCoreSiteXML
modifyHdfsSiteXML
modifyMapredSiteXML
modifyYarnSiteXML
modifySlaves
modifyExcludes
installMariaDB
installSpark
installHive
createHiveSiteXML
#compilerOOZIE
InstallOOZIE
modifyOozieSiteXML
installOOZIEShareLibrary
InitHiveMetaStore
chown -R hadoop:hadoop ${install_dist}
fi