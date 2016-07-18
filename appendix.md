Archive Research Services Workshop
==================================

## Appendix

### Optional Exercise-0: Build Derivatives from WARC files ###

Exercise-0 illustrates for users how derivative datasets are generated from web archives using [Hadoop](https://en.wikipedia.org/wiki/Apache_Hadoop), a framework for "distributed processing of very large data sets on computer clusters." Given the size of even small web archive collections, processing these files to create derived datasets can be very computationally intensive. Hadoop efficiently handles such large-scale jobs using a process called [MapReduce](https://en.wikipedia.org/wiki/MapReduce). Internet Archive uses Hadoop on its cluster to generate derivative datasets from web archives and this exercise mimcs that process by allowing users to run similar "jobs" by installing Hadoop on their local computer.

1. [Set Exercise-0 enviroment variables](#set-exercise-0-enviroment-variables)
2. [Setup Passphraseless ssh](#setup-passphraseless-ssh)
3. [Setup Hadoop and Pig in Pseudo Distributed Mode](#setup-hadoop-and-pig-in-pseudo-distributed-mode)
4. [Download Sample WARC files](#download-sample-warc-files)
5. [Build Derivatives in Hadoop](#build-derivatives-in-hadoop)


##### Set Exercise-0 enviroment variables #####

This step defines the directory paths to which tools, scripts and workshop datasets will be downloaded. Future scripts depend on these settings, so users are advised to update them or know how to access the default location. The default locations are the `pseudo-mode/install/` and `pseudo-mode/data/` sub-directories.

You can update the paths in the setup-exercise-0-env.sh file by opening it in a text editor and defining a new path. For instance, the default values are:

```
export PSEUDO_MODE_INSTALL_DIR=`pwd`/pseudo-mode/install
export PSEUDO_MODE_DATA_DIR=`pwd`/pseudo-mode/data
```

To update them to different directories, as an example, you can change the values to:

```
export PSEUDO_MODE_INSTALL_DIR=/Users/superdog/Desktop/ars-workshop-pseudo-mode-install
export PSEUDO_MODE_DATA_DIR=/Users/superdog/Desktop/ars-workshop-pseudo-mode-data
```

This is just an example. Essentially you are defining where the upcoming installs and datasets will be located. Future exercise steps and scripts will depend on these paths being accurate, so be sure they are correct and the path/directory already exists if you choose to change it. Be sure to save the file if you have edited it.

You will then confirm these paths are set by running the below command. If you edit the paths later, you will need to re-run it.

```
source setup-exercise-0-env.sh
```

##### Setup Passphraseless ssh #####

Passphraseless ssh will allow you to run Hadoop jobs on your local computer without having to enter you user credentials each time.

To enable ssh for OS X, follow the [instructions provided here](http://bluishcoder.co.nz/articles/mac-ssh.html)

Next, check that you can ssh to the localhost without a passphrase:

```
ssh localhost
```

If successful, the first time you will see a message with "Host key not found from database. Key fingerprint... " and will be asked, "Are you sure you want to continue connecting (yes/no)?" Enter yes. Then type in Ctrl+d to exit this sub-shell.

If you cannot ssh to localhost without a passphrase, execute the following command:

```
bin/setup-passphraseless-ssh.sh
```  

##### Setup Hadoop and Pig in Pseudo Distributed Mode #####

In these steps you will install a local version (aka `pseudo-distributed`) of Hadoop and will also install Pig, which is a language for writing large-scale data analysis jobs that run on Hadoop. Simply put, Pig scripts describe the jobs you want to run and Hadoop manages running the job. Though you are running Hadoop on a single node (your computer) the processes are the same as they they were running in a "distributed" environment (across many computers).

Download and setup [Hadoop](http://hadoop.apache.org/) and [Pig](http://pig.apache.org/) - Pseudo-distributed mode:

```
bin/setup-hadoop-pseudo-mode.sh $HADOOP_INSTALL_DIR $PIG_INSTALL_DIR $HADOOP_VERSION $PIG_VERSION
```

Hadoop should take 1-3 minutes normally to download and install (depending on your bandwidth). Hadoop includes a GUI for managing its file system (HDFS: Hadoop Distributed File System, and you can browse the [local web interface for the Hadoop Distributed File System](http://localhost:50070/explorer.html)

##### Download Sample WARC files #####

Next you will download a single WARC file for processing by Pig and Hadoop. WARC files are the ISO-standard preservation file format for web archives and are essentially a convention for concatenating records download by a crawler during capture of web documents. See this page for more information about [the WARC file format](http://bibnum.bnf.fr/WARC/). Run:

```
bin/download-sample-warcs.sh $LOCAL_WARC_DIR
```

The WARC is a little under 1GB in size and normally will take 2-4 minutes to download (depending on your bandwidth)

##### Build Derivatives in Hadoop #####

In this step, you will build derivative datasets from this WARC using Hadoop. The datasets you will be generating are `CDX`, `WAT`, `LGA` and `WANE` datasets. You will also generate the `Parsed text` derivatives that are [Sequence Files](http://wiki.apache.org/hadoop/SequenceFile) containing page text and links extracted from html/text resources.

What takes place when you run the following command to build these derivatives:
* Uploads WARC files from Local directory (`$LOCAL_WARC_DIR`) to the Hadoop Distributed File System (HDFS)
* Runs Hadoop jobs to build the derivatives:
* Downloads derivatives from HDFS to local directory (`$LOCAL_DERIVATIVE_DIR`)

To build these derivatives, run:

```
bin/build-derivatives.sh $LOCAL_WARC_DIR $LOCAL_DERIVATIVE_DIR $HDFS_DERIVATIVE_DIR
```

To stop Hadoop services, run:
```
$HADOOP_HOME/sbin/stop-dfs.sh
```

> To start Hadoop services when you want to re-run this exercise at a later time:
```
$HADOOP_HOME/sbin/start-dfs.sh
```
