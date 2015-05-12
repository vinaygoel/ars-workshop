Archive Research Services Workshop
==================================

## Initial Setup

1. [Download Workshop](#download-workshop)
2. [Install Java](#install-java)
3. [Install Python](#install-python)
4. [Setup Passphraseless ssh](#setup-passphraseless-ssh)
5. [Setup Hadoop in Pseudo Distributed Mode](#setup-hadoop-pseudo-mode)
6. [Setup Pig](#setup-pig)
7. [Download Fat JARs](#download-fat-jars)

#### Download Workshop ####

Please make sure *git* is installed, and then run:

```
git clone https://github.com/vinaygoel/ars-workshop.git

cd ars-workshop
```

### Install Java ####

Please install the latest version of Java and set JAVA_HOME

Linux

```
export JAVA_HOME=/usr
```

OS X

```
export JAVA_HOME=$(/usr/libexec/java_home)
```

### Install Python ####

Install Python:

Linux

```
sudo apt-get install python-pip
```

OS X

```
sudo easy_install pip
curl https://bitbucket.org/pypa/setuptools/raw/bootstrap/ez_setup.py | python
```

#### Setup Passphraseless ssh ####

Check that you can ssh to the localhost without a passphrase:

```
ssh localhost
```

If you cannot ssh to localhost without a passphrase, execute the following command:

```
bin/setup-passphraseless-ssh.sh
```  

#### Setup Hadoop in Pseudo Distributed Mode ####

Download and setup Hadoop:

```
HADOOP_INSTALL_DIR=/tmp/ars-hadoop-install

bin/setup-hadoop-pseudo-mode.sh $HADOOP_INSTALL_DIR
```

Set the HADOOP_HOME environment variable:

```
export HADOOP_HOME=$HADOOP_INSTALL_DIR/hadoop-2.6.0/
```

#### Setup Pig ####

Download and setup Pig:

```
PIG_INSTALL_DIR=/tmp/ars-pig-install

bin/setup-pig.sh $PIG_INSTALL_DIR
```

Set the PIG_HOME environment variable:

```
export PIG_HOME=$PIG_INSTALL_DIR/pig-0.14.0/
```

Update the PATH environment variable to include path to Pig binary:

```
export PATH=$PIG_HOME/bin:$PATH
```

#### Download Fat JARs ####

Execute the following command:

```
bin/download-fat-jars.sh
```

## Build Derivatives from WARC files

1. [Download Sample WARC files](#download-sample-warc-files)
2. [Build Derivatives in Hadoop](#build-derivatives-in-hadoop)

#### Download Sample WARC files ####

Execute the following commands:

```
LOCAL_WARC_DIR=/tmp/ars-workspace-warcs

bin/download-sample-warcs.sh $LOCAL_WARC_DIR
```

#### Build Derivatives in Hadoop ####

Execute the following commands to build derivatives from WARC files in Hadoop:

```
LOCAL_DERIVATIVE_DIR=/tmp/ars-workspace-derivatives/

HDFS_DERIVATIVE_DIR=/tmp/ars-workspace-derivatives/

bin/build-derivatives.sh $LOCAL_WARC_DIR $LOCAL_DERIVATIVE_DIR $HDFS_DERIVATIVE_DIR
```
Steps:
* Uploads WARC files from Local directory to the Hadoop Distributed File System (HDFS)
* Runs Hadoop jobs to build the following derivatives:
  * CDX data
  * WAT data
  * Parsed text data
  * LGA data
  * WANE data
* Downloads derivatives from HDFS to local directory (<path_to_output_local_derivative_dir>)

