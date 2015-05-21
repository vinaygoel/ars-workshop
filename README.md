Archive Research Services Workshop
==================================

## Initial Setup

1. [Download Workshop](#download-workshop)
2. [Install Java](#install-java)
3. [Install Python](#install-python)
4. [Set enviroment variables](#set-enviroment-variables)
5. [Setup Pig](#setup-pig)
6. [Setup Elasticsearch](#setup-elasticsearch)
7. [Download Libraries](#download-libraries)

==================================

#### Download Workshop ####

Please make sure *git* is installed, and then run:

```
git clone https://github.com/vinaygoel/ars-workshop.git

cd ars-workshop
```

### Install Java ####

Please check if you have Java installed by running:

```
java -version
```

If not installed, please [install Java](https://www.java.com/en/download/help/download_options.xml)

### Install Python ####

Please check if you have Python installed by running:

```
python -V
```

If not already installed:

Linux

```
sudo apt-get install python-pip
```

OS X

```
sudo easy_install pip
curl https://bitbucket.org/pypa/setuptools/raw/bootstrap/ez_setup.py | python
```

#### Set enviroment variables ####

Take a look at the setup-env.sh file (in current directory) and update the values as needed (where specified).

Then, set environment variables by running:

```
source setup-env.sh
```

#### Setup Pig ####

Download and setup [Pig](http://pig.apache.org/) by running:

```
bin/setup-pig.sh $PIG_INSTALL_DIR
```

#### Download Libraries ####

To download software libraries needed for the workshop, execute the following command:

```
bin/download-libraries.sh
```

## Exercises

0. [Exercise-0: Build Derivatives from WARC files](#build-derivatives-from-warc-files)


### Exercise-0: Build Derivatives from WARC files ###

1. [Set Exercise-0 enviroment variables](#set-exercise-0-enviroment-variables)
2. [Setup Passphraseless ssh](#setup-passphraseless-ssh)
3. [Setup Hadoop in Pseudo Distributed Mode](#setup-hadoop-in-pseudo-mode)
4. [Download Sample WARC files](#download-sample-warc-files)
5. [Build Derivatives in Hadoop](#build-derivatives-in-hadoop)


#### Set Exercise-0 enviroment variables ####

Take a look at the setup-exercise-0-env.sh file (in current directory) and update the values as needed (where specified).

Then, set environment variables by running:

```
source setup-exercise-0-env.sh
```

#### Setup Passphraseless ssh ####

To enable ssh for OS X, follow the [instructions provided here](http://bluishcoder.co.nz/articles/mac-ssh.html)

Next, check that you can ssh to the localhost without a passphrase:

```
ssh localhost
```

If you cannot ssh to localhost without a passphrase, execute the following command:

```
bin/setup-passphraseless-ssh.sh
```  

#### Setup Hadoop in Pseudo Distributed Mode ####

Download and setup [Hadoop](http://hadoop.apache.org/) in pseudo-distributed mode by running:

```
bin/setup-hadoop-pseudo-mode.sh $HADOOP_INSTALL_DIR
```

#### Download Sample WARC files ####

Execute the following commands:

```
bin/download-sample-warcs.sh $LOCAL_WARC_DIR
```

#### Build Derivatives in Hadoop ####

Execute the following commands to build derivatives from WARC files in Hadoop:

```
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
* Downloads derivatives from HDFS to local directory
