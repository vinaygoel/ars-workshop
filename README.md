Archive Research Services Workshop
==================================

## Initial Setup

1. [Install Java](#install-java)
2. [Install Python](#install-python)
3. [Download Workshop](#download-workshop)
4. [Download Libraries](#download-libraries)

##### Install Java #####

Please check if you have Java installed by running:

```
java -version
```

If not installed, please [install Java](https://www.java.com/en/download/help/download_options.xml)

Then, set JAVA_HOME:

Linux

```
export JAVA_HOME=/usr
```

OS X

```
export JAVA_HOME=$(/usr/libexec/java_home)
```

##### Install Python #####

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

##### Download Workshop #####

Please make sure *git* is installed, and then run:

```
git clone https://github.com/vinaygoel/ars-workshop.git

cd ars-workshop
```

##### Download Libraries #####

To download software libraries needed for the workshop, execute the following command:

```
bin/download-libraries.sh
```

## Homework Exercises

### Exercise-0: Build Derivatives from WARC files ###

1. [Set Exercise-0 enviroment variables](#set-exercise-0-enviroment-variables)
2. [Setup Passphraseless ssh](#setup-passphraseless-ssh)
3. [Setup Hadoop and Pig in Pseudo Distributed Mode](#setup-hadoop-in-pseudo-mode)
4. [Download Sample WARC files](#download-sample-warc-files)
5. [Build Derivatives in Hadoop](#build-derivatives-in-hadoop)


##### Set Exercise-0 enviroment variables #####

Take a look at the setup-exercise-0-env.sh file (in current directory) and update the values as needed (where specified).

Then, set environment variables by running:

```
source setup-exercise-0-env.sh
```

##### Setup Passphraseless ssh #####

To enable ssh for OS X, follow the [instructions provided here](http://bluishcoder.co.nz/articles/mac-ssh.html)

Next, check that you can ssh to the localhost without a passphrase:

```
ssh localhost
```

If you cannot ssh to localhost without a passphrase, execute the following command:

```
bin/setup-passphraseless-ssh.sh
```  

##### Setup Hadoop and Pig in Pseudo Distributed Mode #####

Download and setup [Hadoop](http://hadoop.apache.org/) and [Pig](http://pig.apache.org/) - Pseudo-distributed mode:

```
bin/setup-hadoop-pseudo-mode.sh $HADOOP_INSTALL_DIR $PIG_INSTALL_DIR
```

##### Download Sample WARC files #####

Execute the following commands:

```
bin/download-sample-warcs.sh $LOCAL_WARC_DIR
```

##### Build Derivatives in Hadoop #####

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

To stop all Hadoop daemons, run:
```
$HADOOP_HOME/sbin/stop-dfs.sh
```

## Exercises

To run the self-contained exercises, do the following:

1. [Set Exercises enviroment variables](#set-exercises-enviroment-variables)
2. [Setup Hadoop and Pig in Local Mode](#setup-hadoop-and-pig-in-local-mode)
3. [Setup Elasticsearch](#setup-elasticsearch)
4. [Download Workshop Derivatives](#download-workshop-derivatives)

##### Set Exercises enviroment variables #####

Take a look at the setup-exercises-env.sh file (in current directory) and update the values as needed (where specified).

Then, set environment variables by running:

```
source setup-exercises-env.sh
```

##### Setup Hadoop and Pig in Local Mode #####

Download and setup [Hadoop](http://hadoop.apache.org/) and [Pig](http://pig.apache.org/) - Local mode:

```
bin/setup-hadoop-local-mode.sh $HADOOP_PIG_LOCAL_INSTALL_DIR
```

##### Setup Elasticsearch #####

Download and setup [Elasticsearch](https://www.elastic.co/products/elasticsearch) by running:

```
bin/setup-elasticsearch $ELASTICSEARCH_INSTALL_DIR
```
