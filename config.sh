#!/bin/bash

# =========================== #
# ==== setup environment ==== #
# =========================== #
echo 'INSTALLDIR=/opt/' >> ~/.bashrc
echo 'JOERN=/opt/joern-0.3.1' >> ~/.bashrc
source ~/.bashrc
sudo chmod 777 -R /opt

# update apt
sudo apt-get -y update

# install dependencies
sudo apt-get -y install git
sudo apt-get -y install python-setuptools python-dev
sudo apt-get -y install graphviz libgraphviz-dev graphviz-dev
sudo apt-get -y install pkg-config
sudo apt-get -y install openjdk-8-*
sudo apt-get -y install ant
sudo apt-get -y install unzip
sudo apt-get -y install p7zip-full
sudo apt-get -y install python-pip
sudo apt-get -y install python3-pip
sudo apt-get -y install python-igraph

# build joern
cd $INSTALLDIR
wget https://github.com/fabsx00/joern/archive/0.3.1.tar.gz
tar xfzv 0.3.1.tar.gz
cd joern-0.3.1/
wget http://mlsec.org/joern/lib/lib.tar.gz
tar xfzv lib.tar.gz
sudo ant
sudo ant tools
echo "alias joern='java -jar /opt/joern-0.3.1/bin/joern.jar'" >> ~/.bashrc
source ~/.bashrc

# build neo4j
cd $INSTALLDIR
wget http://neo4j.com/artifact.php?name=neo4j-community-2.1.8-unix.tar.gz
tar -zxvf artifact.php\?name\=neo4j-community-2.1.8-unix.tar.gz
echo "export Neo4jDir='/opt/neo4j-community-2.1.8/'" >> ~/.bashrc
source ~/.bashrc
wget http://mlsec.org/joern/lib/neo4j-gremlin-plugin-2.1-SNAPSHOT-server-plugin.zip
unzip neo4j-gremlin-plugin-2.1-SNAPSHOT-server-plugin.zip -d $Neo4jDir/plugins/gremlin-plugin

# build py2neo
cd $INSTALLDIR
wget https://github.com/nigelsmall/py2neo/archive/py2neo-2.0.tar.gz
tar zxvf py2neo-2.0.tar.gz
cd /opt/py2neo-py2neo-2.0/
sudo python setup.py install
# adding this to make sure you install py2neo 2.0
pip install py2neo==2.0

# build python-joern
cd $INSTALLDIR
git clone https://github.com/fabsx00/python-joern.git
pip install py2neo
cd python-joern/
pip install pyparsing
sudo python setup.py install

# build joern-tools
cd $INSTALLDIR
git clone https://github.com/fabsx00/joern-tools
pip install pygraphviz
cd joern-tools/
sudo python setup.py install

# install other dependencies
pip install xlrd
pip3 install gensim==3.8.3
pip3 install imbalanced-learn==0.4.0
pip3 install scikit-learn==0.19.1
# choose tensorflow-gpu if you've got a fancy GPU
pip3 install tensorflow==1.14.0
pip3 install keras==2.3.0

# get ReSySeVR
echo 'ReSySeVR=/opt/ReSySeVR/' >> ~/.bashrc
source ~/.bashrc
cd $INSTALLDIR
git clone https://github.com/chyanju/ReSySeVR.git

# ========================== #
# ==== prepare raw data ==== #
# ========================== #
# (do this for different dataset, e.g., SARD)
cd $ReSySeVR/data
7z x SARD.7z
./split-sard.sh

# ===================================== #
# ==== process data: source2slice/ ==== #
# ===================================== #

cd $ReSySeVR/data/SARD/
# (do this for every partition, e.g., dir_001)
rm -rf ./.joernIndex/
java -jar /opt/joern-0.3.1/bin/joern.jar /opt/ReSySeVR/data/SARD/dir_001/

# (on screen A: start neo4j service)
cd $INSTALLDIR
rm -rf ./neo4j-community-2.1.8
tar -zxvf artifact.php\?name\=neo4j-community-2.1.8-unix.tar.gz
unzip neo4j-gremlin-plugin-2.1-SNAPSHOT-server-plugin.zip -d $Neo4jDir/plugins/gremlin-plugin
sed -i 's/#org.neo4j.server.webserver.address=0.0.0.0/org.neo4j.server.webserver.address=0.0.0.0/g' /opt/neo4j-community-2.1.8/conf/neo4j-server.properties
sed -i 's/data\/graph.db/\/opt\/ReSySeVR\/data\/SARD\/.joernIndex\//g' /opt/neo4j-community-2.1.8/conf/neo4j-server.properties
sed -i 's/#org.neo4j.server.webserver.address/org.neo4j.server.webserver.address/g' /opt/neo4j-community-2.1.8/conf/neo4j-server.properties
cd $INSTALLDIR/neo4j-community-2.1.8/bin
./neo4j console
# then you can check http://<your_server_ip>:7474/ to see if there are "Relation types"
# if yes, then the configuration is successful

# (on screen B: start processing)
cd $ReSySeVR/src/source2slice/
python ./get_cfg_relation.py
python ./complete_PDG.py
python ./access_db_operate.py
python ./points_get.py
python ./extract_df.py
python ./make_label.py
cp api_slices.txt arraysuse_slices.txt integeroverflow_slices.txt pointersuse_slices.txt ./slices/
cp api_slices_label.pkl api_slices_vulline.pkl array_slice_label.pkl expr_slice_label.pkl pointer_slice_label.pkl ./label_source/
cd $ReSySeVR/src/source2slice/label_source/
mv expr_slice_label.pkl integeroverflow_slices.pkl
mv api_slices_label.pkl api_slices.pkl
mv array_slice_label.pkl arraysuse_slices.pkl
mv pointer_slice_label.pkl pointersuse_slices.pkl
cd $ReSySeVR/src/source2slice/

python ./data_preprocess.py

# ======================================== #
# ==== process data: data_preprocess/ ==== #
# ======================================== #
cp $ReSySeVR/src/source2slice/slice_label/*.txt $ReSySeVR/src/data_preprocess/data/data_source/SARD/
rm $ReSySeVR/src/data_preprocess/data/data_source/SARD/error.txt
cp $ReSySeVR/src/source2slice/label_source/*.pkl $ReSySeVR/src/data_preprocess/data/label_source/SARD/
cd $ReSySeVR/src/data_preprocess/
python ./process_dataflow_func.py
python3 ./create_w2vmodel.py
python3 ./get_dl_input.py
python3 ./dealrawdata.py

# ================================ #
# ==== model training: model/ ==== #
# ================================ #
cp -r $ReSySeVR/src/data_preprocess/dl_input_shuffle/ $ReSySeVR/src/model/
cd $ReSySeVR/src/model/
python3 ./bgru.py



