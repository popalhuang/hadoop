##使用vagrant建立Hadoop cluster環境
### Hadoop cluster環境說明
---
#### namenode\*1:  
1. OS:Ubuntu 16.04 for server 64bit  
Memory:3500M  
CPU*1   
2. JDK 8  
3. Hadoop相關元件:    
Hadoop-2.7.2  
Spark-2.0.0   
Hive-2.1.0   
OOZIE-4.3.0  
MariaDB-10.1
  
#### datanode\*2:  
1. OS:Ubuntu 16.04 for server 64bit  
Memory:3500M  
CPU*1   
2. JDK 8  
3. Hadoop相關元件:    
Hadoop-2.7.2

### 安裝Virtual Box(5.1.14)
---
[Download Virtual Box for Windows7](http://download.virtualbox.org/virtualbox/5.1.14/VirtualBox-5.1.14-112924-Win.exe)  
執行安裝程式安裝Virtual Box

### 安裝vagrant(1.9.1)
---
[Download vagrant for Windows7](https://releases.hashicorp.com/vagrant/1.9.1/vagrant_1.9.1.msi)  
執行安裝程式安裝vagrant

```
vagrant box add ubuntu/precise64 
```
### 安裝github
---

### clone GitHub
---
### vagrant 
---