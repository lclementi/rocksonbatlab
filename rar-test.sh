#!/bin/bash
echo "Creating test1..."
echo > test1
ls -la test1
echo "Creating test2..."
echo > test2
ls -la test2
echo "Chowning test2 to root as root..."
sudo chown root.root test2
ls -la test2
# echo "Shutting down the machine..."
# sudo shutdown -h now

wget ftp://ftp.rocksclusters.org/pub/rocks/src/rocks-source-2013-01-03.tar.gz
wget ftp://ftp.rocksclusters.org/pub/rocks/src/rocks-source-2013-01-03.tar.gz.md5

md5sum -c rocks-source-2013-01-03.tar.gz.md5 || (echo Error file checksum; exit -1;)

tar -xvzf rocks-source-2013-01-03.tar.gz || (echo Error untarring file; exit -1;)

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


exit 0
