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

### 下載及安裝Virtual Box(5.1.14)
---
[Download Virtual Box for Windows7](http://download.virtualbox.org/virtualbox/5.1.14/VirtualBox-5.1.14-112924-Win.exe)  
執行安裝程式安裝Virtual Box

### 下載及安裝vagrant(1.9.1)
---
1. [Download vagrant for Windows7](https://releases.hashicorp.com/vagrant/1.9.1/vagrant_1.9.1.msi)  
2. 執行安裝程式安裝vagrant
3. vagrant box 下載途徑有兩種
```
##vagrant box 下載途徑有兩種
vagrant box add ubuntu/precise64(預設 https://atlas.hashicorp.com/)
vagrant box add precise64 http://files.vagrantup.com/precise64.box

##vagrant box 列表
vagrant box list

##刪除box
vagrant box remove precise64
```  
* vagrant init 初始化(其實就是一個產生Vagrantfile的步驟),如果原本就有這個檔案的話可以直接修改後使用就不需要執行vagrant init指令
```
mkdir work
cd work
git clone https://popalhuang@github.com/popalhuang/hadoop.git
cd hadoop
```  
* 啟動,關機,重啟 VM
```
vagrant up			##啟動all VMs
vagrant halt		##關閉all VMs
vagrant reload		##重啟所有VMs(先執行vagrant halt->vagrant up)
vagrant up master	##啟動單一個VM
```  