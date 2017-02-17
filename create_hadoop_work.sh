#!/bin/bash

echo "---- [34] Format HDFS工作 ******* 很重要要小心使用,執行以下指令HDFS資料會消失********----"
ssh hadoop-master "rm -rf /bgdt/hadoop-2.7.2/tmp"
ssh hadoop-slave1 "rm -rf /bgdt/hadoop-2.7.2/tmp"
#ssh hadoop-slave2 "rm -rf /bgdt/hadoop-2.7.2/tmp"
hadoop namenode -format
echo "drop database metastore_db" | /usr/local/mysql/bin/mysql -u root --password=\!QAZxsw2
echo "create database metastore_db" | /usr/local/mysql/bin/mysql -u root --password=\!QAZxsw2
/bgdt/hive-2.1.0/bin/schematool -dbType mysql -initSchema



echo "---- [28] Create HDFS Directory ----"
hadoop fs -mkdir -p /user/hadoop/share/lib
hadoop fs -mkdir -p /user/hadoop/workflow
hadoop fs -mkdir -p /user/hadoop/data

echo "---- [29] upload oozie share library ----"
hadoop fs -put -f /bgdt/oozie-4.3.0/share/lib /user/hadoop/share
hadoop fs -put -f /home/vagrant/src/job/* /user/hadoop/workflow

echo "---- [30] Create Hive Tables for MSG----"
hive -f "/home/vagrant/src/job/hive_tables/msg_tables_ddl.sql"

echo "---- [31] Create Hive Tables for CAS----"
hive -f "/home/vagrant/src/job/hive_tables/cas_source_table_ddl.sql"
hive -f "/home/vagrant/src/job/hive_tables/cas_analysis_table_ddl.sql"

echo "---- [32] Import MSG History Data(Oracle to Hive)----"
spark-submit --driver-memory 2g --class "com.sti.spark.main.MSGImportToHive" /home/vagrant/src/job/spark-import/lib/MSGImport.jar 20090101 20170201 msg.message_history1

echo "---- [33] Import CAS_SOURCE Tables Data----"
spark-submit --class "com.sti.cas.main.ImportVariantsDetail" /home/vagrant/src/job/cas_workflow/cas_source_imp/lib/CASImportSQLtoHive.jar
spark-submit --class "com.sti.cas.main.ImportVariantsCategory" /home/vagrant/src/job/cas_workflow/cas_source_imp/lib/CASImportSQLtoHive.jar
spark-submit --class "com.sti.cas.main.ImportTelPhoneView" /home/vagrant/src/job/cas_workflow/cas_source_imp/lib/CASImportSQLtoHive.jar
spark-submit --class "com.sti.cas.main.ImportLogData" /home/vagrant/src/job/cas_workflow/cas_source_imp/lib/CASImportSQLtoHive.jar
spark-submit --class "com.sti.cas.main.ImportMainTab" /home/vagrant/src/job/cas_workflow/cas_source_imp/lib/CASImportSQLtoHive.jar
spark-submit --class "com.sti.cas.main.ImportContentTab" /home/vagrant/src/job/cas_workflow/cas_source_imp/lib/CASImportSQLtoHive.jar







#/bgdt/hive-2.1.0/bin/schematool -dbType mysql -upgradeSchemaFrom 1.2.0 -dryRun
#/bgdt/hive-2.1.0/bin/schematool -dbType mysql -info


echo "---- [32] Drop Hive Tables for CAS----"
#hive -e "drop table IF EXISTS msg.message_history1"
#hive -e "drop table IF EXISTS msg.message_result"
#hive -e "drop database IF EXISTS msg"

echo "---- [33] Drop Hive Tables for CAS----"
#hive -e "drop table IF EXISTS CAS_SOURCE.LogData"
#hive -e "drop table IF EXISTS CAS_SOURCE.All_DialedUser_TelPhone_View"
#hive -e "drop table IF EXISTS CAS_SOURCE.Variants_Detail"
#hive -e "drop table IF EXISTS CAS_SOURCE.Variants_Category"
#hive -e "drop table IF EXISTS CAS_SOURCE.MainTab"
#hive -e "drop table IF EXISTS CAS_SOURCE.ContentTab"
#hive -e "drop table IF EXISTS CAS_ANALYSIS.LogData"
#hive -e "drop table IF EXISTS CAS_ANALYSIS.Result_LogSummary"
#hive -e "drop table IF EXISTS CAS_ANALYSIS.Result_LogDetail"
#hive -e "drop table IF EXISTS CAS_ANALYSIS.Custom_Category"
#hive -e "drop table IF EXISTS CAS_ANALYSIS.custom_categorymember"
#hive -e "drop database IF EXISTS CAS_SOURCE"
#hive -e "drop database IF EXISTS CAS_ANALYSIS"