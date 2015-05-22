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

If not installed, install it by running:

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

To download software libraries needed for the workshop, run:

```
bin/download-libraries.sh
```

### (Optional) Exercise-0: Build Derivatives from WARC files ###

1. [Set Exercise-0 enviroment variables](#set-exercise-0-enviroment-variables)
2. [Setup Passphraseless ssh](#setup-passphraseless-ssh)
3. [Setup Hadoop and Pig in Pseudo Distributed Mode](#setup-hadoop-in-pseudo-mode)
4. [Download Sample WARC files](#download-sample-warc-files)
5. [Build Derivatives in Hadoop](#build-derivatives-in-hadoop)


##### Set Exercise-0 enviroment variables #####

*(optional) Update the values in setup-exercise-0-env.sh file*

Set environment variables by running:

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

*You can browse the [web interface for the Hadoop Distributed File System](http://localhost:50070/)*

##### Download Sample WARC files #####

```
bin/download-sample-warcs.sh $LOCAL_WARC_DIR
```

##### Build Derivatives in Hadoop #####

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

*(optional) Update the values in setup-exercises-env.sh file*

Set environment variables by running:

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

Run Elasticsearch in the background:

```
$ELASTICSEARCH_HOME/bin/elasticsearch -d
```

##### Download Workshop Derivatives #####

```
#TODO
```

### Exercise-1: Store CDX data into Elasticsearch ###

```
pig -x local -p I_CDX_DIR=$ARS_DERIVATIVES_DIR/cdx/ -p O_ES_INDEX_DIR=ars-cdx/cdx pig/store-cdx-data-into-elasticsearch.pig
```

### Exercise-2: Store WAT text data into Elasticsearch ###

```
pig -x local -p I_WAT_DIR=$ARS_DERIVATIVES_DIR/wat/ -p O_ES_INDEX_DIR=ars-wat/text pig/store-wat-text-data-into-elasticsearch.pig
```

### Exercise-3: Store WANE data into Elasticsearch ###

```
pig -x local -p I_CDX_DIR=$ARS_DERIVATIVES_DIR/wane/ -p O_ES_INDEX_DIR=ars-wane/entities pig/store-wane-data-into-elasticsearch.pig
```

