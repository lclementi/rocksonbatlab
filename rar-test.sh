#!/bin/bash

Date=`date +%F`
FileName=rocks-source-$Date.tar.gz

wget ftp://ftp.rocksclusters.org/pub/rocks/src/$FileName
wget ftp://ftp.rocksclusters.org/pub/rocks/src/$FileName.md5

md5sum -c $FileName.md5 || (echo Error file checksum; exit -1;)

tar -xvzf $FileName || (echo Error untarring file; exit -1;)

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

sudo ./builder.sh < /dev/null 

## ---- fetch all the output files
tar -czvf results.tar.gz /tmp/*.out

exit 0

