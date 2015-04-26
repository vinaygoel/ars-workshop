Archive Research Services Workshop
==================================

## Initial Setup

1. [Setup Passphraseless ssh](#setup-passphraseless-ssh)
2. [Setup Hadoop in Pseudo Distributed Mode](#setup-hadoop-pseudo-mode)
3. [Setup Pig](#setup-pig)
4. [Download Fat JARs](#download-fat-jars)
5. [Download Sample WARC files](#download-sample-warc-files)

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

If you don't currently have Hadoop installed, execute the following command:

```
bin/setup-hadoop-pseudo-mode.sh /path/to/hadoop/install/dir
```

Please set the HADOOP_HOME environment variable as specified by the script.

#### Setup Pig ####

If you don't currently have Pig installed, execute the following command:

```
bin/setup-pig.sh /path/to/pig/install/dir
```

Please set PIG_HOME and PATH environment variables as specified by the script.

#### Download Fat JARs ####

Execute the following command:

```
bin/download-fat-jars.sh
```

## Build Derivatives from WARC files

1. [Download Sample WARC files](#download-sample-warc-files)
2. [Build Derivatives in Hadoop](#build-derivatives-in-hadoop)

#### Download Sample WARC files ####

Execute the following command:

```
bin/download-sample-warcs.sh path/to/local/warc/dir
```

#### Build Derivatives in Hadoop ####

Execute the following command:

```
bin/build-derivatives.sh /path/to/local/warc/dir /path/to/output/local/derivative/dir /hdfs/path/to/working/dir
```

The above command runs the following steps:
* Uploads WARC files from Local directory to the Hadoop Distributed File System (HDFS)
* Run Hadoop jobs to build the following derivatives:
  * CDX data
  * WAT data
  * Parsed text data
  * LGA data
  * WANE data
* Downloads derivatives from HDFS to local directory (/path/to/output/local/derivative/dir)

