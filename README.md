Archive Research Services Workshop
==================================

This workshop is to provide researchers, developers, and general users an introduction to data mining and computational tools and methods for working with web archives. Originally created by Internet Archive for an in-person training event at the [RESAW conference](http://resaw.eu/events/international-conference-aarhus-june-2015/) "Web Archives as Scholarly Sources: Issues, Practices and Perspectives" in Aarhus, Denmark in June 2015, the workshop is part of IA's ongoing efforts to support research use of web archives that also include [Archive-It Research Services](https://webarchive.jira.com/wiki/display/ARS/Archive-It+Research+Services) and other support services, collaborations, and partnerships with researchers, web scientists, and data engineering projects.

The workshop assumes some basic familiarity with the command line ("Terminal") and is only intended for those working on Mac or Linux operating systems. For an introduction to using the command line, see [The Command Line Crash Course](http://cli.learncodethehardway.org/book/).

## Initial Setup

The Initial Setup ensures that users have installed the tools and libraries necessary for later exercises.

1. [Install Java](#install-java)
2. [Install Python](#install-python)
3. [Install Git](#install-git)
4. [Download Workshop](#download-workshop)
5. [Download Libraries](#download-libraries)

##### Install Java #####

Please check if you have Java 7 installed by running:

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
export JAVA_HOME=$(/usr/libexec/java_home -v 1.7)
```

Running this command will set the Java home but not produce a response and will instead return to the normal command prompt. 

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

##### Install Git #####

Please check if you have Git installed by running:

```
git --version
```

If not installed, install it by running:

Linux

```
sudo apt-get install git
```

OS X

```
Follow these instructions for [installing git](https://git-scm.com/book/en/v2/Getting-Started-Installing-Git#Installing-on-Mac) on Mac.
```


##### Download Workshop #####

This will create a copy of the workshop repository on your computer.

After *git* is installed, run:

```
git clone https://github.com/vinaygoel/ars-workshop.git
```

Then "change directory" into the ars-workshop directory by running:

```
cd ars-workshop
```
All exercises will be run from this directory.

##### Download Libraries #####

This will install about a dozen different libraries necessary for the workshop exercises. All libraries should download in under two minutes (depending on download speeds)

To download software libraries needed for the workshop, run:

```
bin/download-libraries.sh
```

==================================
### Optional Exercise-0: Build Derivatives from WARC files ###

Exercise-0 illustrates for users how derivative datasets are generated from web archives using [Hadoop](https://en.wikipedia.org/wiki/Apache_Hadoop), a framework for "distributed processing of very large data sets on computer clusters." Given the size of even small web archive collections, processing these files to create derived datasets can be very computationally intensive. Hadoop efficiently handles such large-scale jobs using a process called [MapReduce](https://en.wikipedia.org/wiki/MapReduce). Internet Archive uses Hadoop on its cluster to generate derivative datasets from web archives and this exercise mimcs that process by allowing users to run similar "jobs" by installing Hadoop on their local computer.

1. [Set Exercise-0 enviroment variables](#set-exercise-0-enviroment-variables)
2. [Setup Passphraseless ssh](#setup-passphraseless-ssh)
3. [Setup Hadoop and Pig in Pseudo Distributed Mode](#setup-hadoop-in-pseudo-mode)
4. [Download Sample WARC files](#download-sample-warc-files)
5. [Build Derivatives in Hadoop](#build-derivatives-in-hadoop)


##### Set Exercise-0 enviroment variables #####

This step defines the directory paths to which Hadoop and other tools/scripts will be downloaded. Future scripts depend on these settings, so users are advised to update them or know how to access the default location. The default location is /tmp/ directory. For Mac users this is a "hidden" folder under the root directory (generally "Macintosh HD"). To view hidden folders in Finder, follow [these instructions](http://www.macworld.co.uk/how-to/mac-software/how-show-hidden-files-in-mac-os-x-finder-3520878/). 

Alternately, you can update the paths in the setup-exercise-0-env.sh file by opening it in a text editor and defining a new path. For instance, the default first value is:

```
export PSEUDO_MODE_INSTALL_DIR=/tmp
```

To update it to a different directory for instance, it could be changed to:

```
export PSEUDO_MODE_INSTALL_DIR=/Users/superdog/Desktop/ars-pseudo-mode-install
```

This is just an example. Essentially you are defining where the upcoming installs will be located. Future exercise steps and scripts will depend on these paths being accurate, so be sure they are correct and the path/directory already exists if you choose to change it. Be sure to save the file if you have edited it.

You will then confirm these paths are set by running the below. If you edit the paths later, you will need to re-run this command. Run:

```
source setup-exercise-0-env.sh
```

Running this command will set the paths but will not produce a response and will instead return to the normal command prompt. 

##### Setup Passphraseless ssh #####

Passphraseless ssh will allow you to run Hadoop jobs on your local computer without having to enter you user credentials each time. 

To enable ssh for OS X, follow the [instructions provided here](http://bluishcoder.co.nz/articles/mac-ssh.html)

Next, check that you can ssh to the localhost without a passphrase:

```
ssh localhost
```

If successful, the first time you will see a message with "Host key not found from database. Key fingerprint... " and will be asked, "Are you sure you want to continue connecting (yes/no)?" Enter yes.

If you cannot ssh to localhost without a passphrase, execute the following command:

```
bin/setup-passphraseless-ssh.sh
```  

##### Setup Hadoop and Pig in Pseudo Distributed Mode #####

In these steps you will install a local version (aka "pseudo-distributed") of Hadoop and will also install Pig, which is a language for writing large-scale data analysis jobs that run on Hadoop. Simply put, Pig scripts describe the jobs you want to run and Hadoop manages running the job. Though you are running Hadoop on a single node (aka, your computers) the processes is the same as running it in a "distributed" environment (aka many nodes).

Download and setup [Hadoop](http://hadoop.apache.org/) and [Pig](http://pig.apache.org/) - Pseudo-distributed mode:

```
bin/setup-hadoop-pseudo-mode.sh $HADOOP_INSTALL_DIR $PIG_INSTALL_DIR
```

Hadoop should take 1-3 minutes normally to download and install (depending on your bandwidth). Hadoop includes a GUI for managing its file system (HDFS: Hadoop Distributed File System, and you can browse the [web interface for the Hadoop Distributed File System](http://localhost:50070/)

##### Download Sample WARC files #####

Next you will download a single WARC file for processing by Pig and Hadoop. WARC files are the ISO-standard preservation file format for web archives and are essentially a convention for concatenating records download by a crawler during capture of web documents. See this page for more information about [the WARC file format](http://bibnum.bnf.fr/WARC/). Run:

```
bin/download-sample-warcs.sh $LOCAL_WARC_DIR
```

The WARC is a little under 1GB in size and normally will take 2-4 minutes to download (depending on your bandwidth).

##### Build Derivatives in Hadoop #####

In this step, you will build derivative datasets from this WARC using Hadoop. The datasets you will be generating are CDX, and Parsed text, which are used in providing access for replay and searching archived web resources, and WAT, LGA, and WANE datasets, which are derivative datasets Internet Archive makes available for research use as part of its [Archve-It Research Services](https://webarchive.jira.com/wiki/display/ARS/Datasets+Available). For more information:

* [CDX File Format](https://archive.org/web/researcher/cdx_file_format.php)
* Parsed text data - Full page text and links from html/text resources stored in [Sequence Files](http://wiki.apache.org/hadoop/SequenceFile)
* For information on research datasets, [see this wiki space](https://webarchive.jira.com/wiki/display/ARS/Datasets+Available)
  * WAT - Web Archive Transformation dataset
  * LGA - Longitudinal Graph Analysis dataset
  * WANE - Web Archive Named Entities dataset

What takes place when you run the command to build these derivatives:
* Uploads WARC files from Local directory to the Hadoop Distributed File System (HDFS)
* Runs Hadoop jobs to build the derivatives:
* Downloads derivatives from HDFS to local directory

To build these derivatives, run:

```
bin/build-derivatives.sh $LOCAL_WARC_DIR $LOCAL_DERIVATIVE_DIR $HDFS_DERIVATIVE_DIR
```

To stop all Hadoop services, run:
```
$HADOOP_HOME/sbin/stop-dfs.sh
```

==================================
## Setup for Exercises

To run the self-contained exercises, do the following:

1. [Set Exercises enviroment variables](#set-exercises-enviroment-variables)
2. [Setup Hadoop and Pig in Local Mode](#setup-hadoop-and-pig-in-local-mode)
3. [Setup Elasticsearch](#setup-elasticsearch)
4. [Setup Kibana](#setup-kibana)
5. [Download Workshop Derivatives](#download-workshop-derivatives)

##### Set Exercises enviroment variables #####

*Optional / If needed, update the values in setup-exercises-env.sh file*

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
bin/setup-elasticsearch.sh $ELASTICSEARCH_INSTALL_DIR
```

Run Elasticsearch in the background:

```
$ELASTICSEARCH_HOME/bin/elasticsearch -d
```

##### Setup Kibana #####

Download and setup [Kibana](https://www.elastic.co/products/kibana) by running:

```
bin/setup-kibana.sh $KIBANA_INSTALL_DIR
```

##### Download Workshop Derivatives #####

Download derivatives (WAT, WANE, LGA and CDX) for the [Ferguson Youtube Video Archiving Project](https://archive.org/details/fergusoncrawl&tab=collection?and[]=fergytv), a subset of the [Ferguson Tweets Collection] (https://archive.org/details/fergusoncrawl&tab=collection)

Also, included are a handful of sample WATs from the [NARA congress112th crawl](http://webharvest.gov/collections/congress112th/) for a quick run-through of the WAT exercises.

```
bin/download-workshop-derivatives.sh $ARS_DERIVATIVES_DIR
```

The derivatives are about 700 MB in size and will take about 5 minutes to download (depending on your bandwidth).

You will use these derivative datasets for the upcoming exercises.

==================================
## Exercises

### Exercise-1: Store CDX data into Elasticsearch ###

```
pig -x local -p I_CDX_DIR=$ARS_DERIVATIVES_DIR/cdx/ -p O_ES_INDEX_DIR=ars-cdx/cdx pig/store-cdx-data-into-elasticsearch.pig
```

### Exercise-2: Store WAT text data into Elasticsearch ###

The following job takes about 30 minutes to run on the Ferguson WAT data.

For a quick run-through using the sample NARA WATs, replace I_WAT_DIR=$ARS_DERIVATIVES_DIR/wat/ with I_WAT_DIR=$ARS_DERIVATIVES_DIR/sample-wat/ below.

```
pig -x local -p I_WAT_DIR=$ARS_DERIVATIVES_DIR/wat/ -p O_ES_INDEX_DIR=ars-wat-text/text pig/store-wat-text-data-into-elasticsearch.pig
```

### Exercise-3: Store WANE data into Elasticsearch ###

```
pig -x local -p I_WANE_DIR=$ARS_DERIVATIVES_DIR/wane/ -p O_ES_INDEX_DIR=ars-wane/entities pig/store-wane-data-into-elasticsearch.pig
```

### Exercise-4: Video Search using WAT data and Elasticsearch ###

Steps involved:
* Extract all URLs to video ("watch") pages from WATs
* For each video URL, generate a list of unique terms (using "anchor text" of links), and the number of links to this URL
* Store this data into Elasticsearch

The following job runs through these steps and takes about 30 minutes to run on the Ferguson WAT data.

For a quick run-through using the sample NARA WATs, replace I_WAT_DIR=$ARS_DERIVATIVES_DIR/wat/ with I_WAT_DIR=$ARS_DERIVATIVES_DIR/sample-wat/ below.

```
pig -x local -p I_WAT_DIR=$ARS_DERIVATIVES_DIR/wat/ -p I_VIDEO_URL_FILTER='.*youtube.com/watch.*' -p O_ES_INDEX_DIR=ars-wat-videos/videos pig/video-search-elasticsearch.pig
```

### Exercise-5: Use Kibana to explore data stored in Elasticsearch ###

Start the Kibana service:

```
$KIBANA_HOME/bin/kibana
```

Then, access the Kibana interface by [clicking here] (http://localhost:5601)

When you're done exploring, stop the Kibana service by typing Ctrl+c in the terminal.


### Exercise-6: GeoIP using WAT data ###

Extract IP addresses and generate latitude and longitude information using [MaxMind](http://dev.maxmind.com/geoip/)

The Ferguson dataset WARCs do not contain IP Address information, so let's use the NARA sample WAT dataset (which contains IP info) for this exercise.  

```
pig -x local -p I_WAT_DIR=$ARS_DERIVATIVES_DIR/sample-wat/ -p O_DATE_LAT_LONG_COUNT_DIR=$ARS_EXERCISES_RESULTS_DIR/date-lat-long-count/ pig/geoip-from-wat.pig
```

Convert this data into a CSV file for import into [CartoDB] (https://cartodb.com/)

```
cat $ARS_EXERCISES_RESULTS_DIR/date-lat-long-count/part* | ./cache/ipcsv.sh > $ARS_EXERCISES_RESULTS_DIR/date-lat-long.csv
```

You can generate a temporal map using this CSV file and the [Torque library of CartoDB] (http://blog.cartodb.com/torque-is-live-try-it-on-your-cartodb-maps-today/)

### Exercise-7: Degree Distribution of URLs using LGA data ###

Steps involved:
* Generate the in-degree (number of incoming links) and out-degree (number of outgoing links) for each URL
* Generate the distribution of in-degree and out-degree (i.e. how many URLs share the same degree value)

```
pig -x local -p I_LGA_DIR=$ARS_DERIVATIVES_DIR/lga/ -p I_DATE_FILTER='^201.*$' -p O_DEGREE_DISTRIBUTION_DIR=$ARS_EXERCISES_RESULTS_DIR/degree-distribution/ pig/url-degree-distribution.pig
```

Results:


*degree-distribution/url-indegree-outdegree*
-----------

The file(s) under this directory contain the following tab-separated fields: URL, in-degree and out-degree.
The data is ordered in descending order of in-degree.

To get the top 10 URLs with the highest in-degree:
```
head $ARS_EXERCISES_RESULTS_DIR/degree-distribution/url-indegree-outdegree/part*
```



*degree-distribution/indegree-numurls*
----------

The file(s) under this directory contain the following tab-separated fields: in-degree and num_urls, where num_urls is the number of URLs with the given in-degree. The data is ordered in descending order of num_urls.

To get the top 10 most common in-degrees:
```
head $ARS_EXERCISES_RESULTS_DIR/degree-distribution/indegree-numurls/part*
```



*degree-distribution/outdegree-numurls*
-----------
The file(s) under this directory contain the following tab-separated fields: out-degree and num_urls, where num_urls is the number of URLs with the given out-degree. The data is ordered in descending order of num_urls.

To get the top 10 most common out-degrees:
```
head $ARS_EXERCISES_RESULTS_DIR/degree-distribution/outdegree-numurls/part*
```

### Exercise-8: Domain Graph using LGA data ###
