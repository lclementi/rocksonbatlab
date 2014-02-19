#!/bin/bash
#
# This script checksout rocks and built it on BatLab 
# 
# LC

## remote machine for staging output of compilation
RemoteMachine=calit2-110-119-23.ucsd.edu
RemotePath=upload
RemoteUser=upload

#
## used to figure out input file name for source code
Date=`date +%F`

#FileName=rocks-source-$Date.tar.gz
#
#wget ftp://ftp.rocksclusters.org/pub/rocks/src/$FileName
#wget ftp://ftp.rocksclusters.org/pub/rocks/src/$FileName.md5
#
#md5sum -c $FileName.md5 || (echo Error file checksum; exit -1;)
#
#tar -xvzf $FileName || (echo Error untarring file; exit -1;)
#
#lets free up some space

wget -O master.tar.gz https://github.com/rocksclusters/rocks/archive/master.tar.gz || \
	( echo Unable to download master repository; exit -1 )
tar -xvzf master.tar.gz || ( echo Problem untarring; exit -1)
mv rocks-master rocks
rm master.tar.gz
cd rocks
./init.sh --source  || ( echo Unable to download sub-repositories; exit -1 )
cd ..


# 
# proper ownership if not the pxeflash will not compile
# when creating a the pxe floppy it will not be able to chown to user id 
# if file are owned by somebody else then root
# 
sudo chown -R root:root master

cd rocks


echo --------   -----------------   -------------
echo --------   bootstrap section   -------------
echo --------   -----------------   -------------



sudo yum -y install system-config-keyboard


#don't ask me why but in centos 5 we need this
export PATH=$PATH:/sbin:/usr/sbin:/usr/local/sbin

pushd src/roll/base
sudo bash -l ./bootstrap0.sh < /dev/null 

if [ `/opt/rocks/bin/rocks list roll | wc -l ` -lt 3 ]; then 
	echo Error bootstrapping the appliance;
	exit -1; 
fi

popd
## ---- build the whole thing
#reload the new environment
echo ----  Running builder script  ----
. /etc/profile
. /etc/profile.d/rocks-binaries.sh
sudo bash -l builder.sh < /dev/null 
echo ----  End builder script      ----

cd ..
## ---- fetch all the output files
tar -czvf results.tar.gz /tmp/*.out ../remote_task.*

# stage them to remote machine
RemoteDest=$RemoteUser@$RemoteMachine:~$RemotePath/$Date/

chmod 600 id_rsa
#TODO finish staging out results
rsync -av -e "ssh -o StrictHostKeyChecking=no -i id_rsa" results.tar.gz $RemoteDest
rsync -av -e "ssh -o StrictHostKeyChecking=no -i id_rsa"  rocks/src/roll/*/*.iso /tmp/*.iso $RemoteDest



exit 0

