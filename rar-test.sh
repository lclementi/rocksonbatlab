#!/bin/bash

# remote machine for staging output of compilation
RemoteMachine=calit2-110-119-23.ucsd.edu
RemotePath=upload
RemoteUser=upload

# used to figure out input file name for source code
Date=`date +%F`
FileName=rocks-source-$Date.tar.gz

wget ftp://ftp.rocksclusters.org/pub/rocks/src/$FileName
wget ftp://ftp.rocksclusters.org/pub/rocks/src/$FileName.md5

md5sum -c $FileName.md5 || (echo Error file checksum; exit -1;)

tar -xvzf $FileName || (echo Error untarring file; exit -1;)

#let free up some space
rm $FileName

# 
# proper ownership if not the pxeflash will not compile
# when creating a the pxe floppy it will not be able to chown to user id 
# if file are owned by somebody else then root
# 
sudo chown -R root:root rocks

cd rocks


echo --------   -----------------   -------------
echo --------   bootstrap section   -------------
echo --------   -----------------   -------------

pushd src/roll/base
sudo ./bootstrap0.sh < /dev/null 

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
tar -czvf results.tar.gz /tmp/*.out

# stage them to remote machine
RemoteDest=$RemoteUser@$RemoteMachine:~$RemotePath/$Date/

chmod 600 id_rsa
#TODO finish staging out results
rsync -av -e "ssh -o StrictHostKeyChecking=no -i id_rsa" results.tar.gz $RemoteDest
rsync -av -e "ssh -o StrictHostKeyChecking=no -i id_rsa"  rocks/src/roll/*/*.iso /tmp/*.iso $RemoteDest



exit 0

