Archive Research Services Workshop
==================================

This workshop is to provide researchers, developers, and general users an introduction to data mining and computational tools and methods for working with web archives. Originally created by `Internet Archive` for an in-person training event at the [RESAW conference](http://resaw.eu/events/international-conference-aarhus-june-2015/) "Web Archives as Scholarly Sources: Issues, Practices and Perspectives" in Aarhus, Denmark on June 2015, the workshop is part of IA's ongoing efforts to support research use of web archives that also include [Archive-It Research Services](https://webarchive.jira.com/wiki/display/ARS/Archive-It+Research+Services) and other support services, collaborations, and partnerships with researchers, web scientists, and data engineering projects.

The workshop assumes some basic familiarity with the command line ("Terminal") and is only intended for those working on Mac or Linux operating systems. For an introduction to using the command line, see [The Command Line Crash Course](http://cli.learncodethehardway.org/book/).

The datasets you will be working with are `CDX`, which are used in providing access for replay through the Wayback Machine, and `WAT`, `LGA`, and `WANE` datasets, which are derivative datasets Internet Archive makes available for research use as part of its [Archive-It Research Services](https://webarchive.jira.com/wiki/display/ARS/Datasets+Available). For more information:

* [CDX File Format](https://archive.org/web/researcher/cdx_file_format.php)
* For information on research datasets, [see this wiki space](https://webarchive.jira.com/wiki/display/ARS/Datasets+Available)
  * WAT - Web Archive Transformation dataset
  * LGA - Longitudinal Graph Analysis dataset
  * WANE - Web Archive Named Entities dataset

## Initial Setup

The Initial Setup ensures that users have installed the tools and libraries necessary for later exercises.

1. [Install Git](#install-git)
2. [Install and Run Docker](#install-docker)
3. [Download Workshop](#download-workshop)

##### Install Git #####

Install Git by following these [instructions](https://git-scm.com/book/en/v2/Getting-Started-Installing-Git)

##### Install and Run Docker #####

Install and Run Docker for your OS ([Mac](https://docs.docker.com/docker-for-mac/), [Windows](https://docs.docker.com/docker-for-windows/) or [Linux](https://docs.docker.com/engine/installation/linux/ubuntulinux/)) 

##### Download Workshop #####

Download workshop materials on your computer by running:
```
git clone https://github.com/vinaygoel/ars-workshop.git &&
cd ars-workshop && bin/download-libraries.sh &&
docker pull vinaygoel/ars-docker-notebooks
```

## Exercises


### Stage WARCs for analysis ###

Create a directory named `ars-data` and download or copy your own WARCs into the directory `ars-data/warcs`. Derivatives and results will be generated under this `ars-data` directory.

You will run the workshop exercises inside a Docker container. To start the ARS container, run:
```
export path_to_ars_data_directory=<path/to/ars/data/directory>
bin/start-container.sh ${path_to_ars_data_directory}
source /set-environment.sh
```

You are now all set to run through the exercises!

### Exercise-0: Build derivatives from WARC data ###

```
/ars-workshop/bin/build-derivatives-local.sh /ars-data/warcs/ /ars-data/derivatives/
```
The above command will build the following derivatives from your WARCs: `CDX`, `WAT`, `Parsed Text` (parsed out text and links from WARCs), `WANE`, and `LGA`. These derivatives will be generated in sub-directories under `ars-data/derivatives/`

### Exercise-1: Store Derivative data into Elasticsearch ###

* `CDX`: Extract all fields from the CDX dataset and index them into Elasticsearch.
  * Create an Elasticsearch index named `ars-cdx` containing the extracted CDX data.
* `WAT`: From every HTML document, extract `URL`, `timestamp`, `title text` and `meta text` and index these fields into Elasticsearch.
  * Create an Elasticsearch index named `ars-wat-text` containing the extracted WAT text data.
* `WANE`: Extract named entities (Persons, Locations and Organizations) from the WANE dataset and index them into Elasticsearch.
  * Create an Elasticsearch index named `ars-wane` containing the extracted WANE data.

Run the following command to accomplish the above tasks:
```
/ars-workshop/bin/store-derivatives-into-elasticsearch.sh /ars-data/derivatives/
```

`CDX`: Example query to search for captures of MIME type `video/mp4`:

```
curl 'http://localhost:9200/ars-cdx/_search?q=mime:"video/mp4"&pretty=true'
```

`WAT`: Example query to search for captures containing the term `obama`:

```
curl 'http://localhost:9200/ars-wat-text/_search?q=obama&pretty=true'
```

etc.

### Exercise-2: Build a simple Video Search service using WAT data and Elasticsearch ###

Steps involved:
* Extract all URLs to Youtube video (`watch`) pages from WATs
* For each video URL, generate a list of unique terms (using `anchor text` of links), and the number of links to this URL
* Create an Elasticsearch index named `ars-wat-videos`

```
cd /ars-workshop/ && pig -x local -p I_WAT_DIR=/ars-data/derivatives/wat/*.wat.gz -p I_VIDEO_URL_FILTER='.*youtube.com/watch.*' -p O_ES_INDEX_DIR=ars-wat-videos/videos pig/video-search-elasticsearch.pig
```

### Exercise-3: Use Kibana to explore data stored in Elasticsearch ###

Access the [Kibana interface](http://localhost:5601), a web frontend service to analyze data stored in Elasticsearch:

The first screen you arrive at will ask you to configure an **index pattern**. An index pattern describes to Kibana how to access your data. Here you will fill in the index pattern for each of the indexes generated in previous exercises.

* `ars-cdx` as your index pattern for CDX data (contains timestamped information)
* `ars-wat-text` as your index pattern for WAT text data (contains timestamped information)
* `ars-wane` as your index pattern for WANE data (contains timestamped information)
* `ars-wat-videos` as your index pattern for the video search data (no timestamp information)

For the indexes that have time information, Kibana reads the Elasticsearch mapping to find the time fields - select one from the list. For our indexes, the time field is named `timestamp`.

Hit *Create*.

Now that you've configured an index pattern, you can click on the *Discover* tab in the navigation bar at the top of the screen and try out searches to explore your data.

For more information, see the [Kibana 4 Tutorial](https://www.timroes.de/2015/02/07/kibana-4-tutorial-part-1-introduction/)

### Exercise-4: GeoIP using WAT data ###

In this exercise, we will extract IP addresses and generate latitude and longitude information using a dataset available through [MaxMind](http://dev.maxmind.com/geoip/)

The Ferguson dataset WARCs do not contain IP Address information, so let's use the "Charlie Hebdo Collection" sample WAT dataset (which contains IP info) for this exercise.

```
cd /ars-workshop/ && pig -x local -p I_WAT_DIR=/ars-data/derivatives/wat/*.wat.gz -p O_DATE_LAT_LONG_COUNT_DIR=/ars-data/results/date-lat-long-count/ pig/geoip-from-wat.pig
```
The above command generates a dataset with the following tab-separated fields: `Date`, `Latitude`, `Longitude` and `count`, where count is the number of occurrences of these co-ordinates in the data. 

Next, let's convert this data into a CSV file for import into [CartoDB](https://cartodb.com/)

```
cat /ars-data/results/date-lat-long-count/part* | /ars-workshop/bin/ipcsv.sh > /ars-data/results/date-lat-long.csv
```

You can generate a temporal map using this CSV file and the [Torque library of CartoDB](http://blog.cartodb.com/torque-is-live-try-it-on-your-cartodb-maps-today/)

### Exercise-5: Degree Distribution of URLs using LGA data ###

Steps involved:
* Generate the in-degree (number of incoming links) and out-degree (number of outgoing links) for each URL
* Generate the distribution of in-degree and out-degree (i.e. how many URLs share the same degree value)

```
cd /ars-workshop/ && pig -x local -p I_LGA_DIR=/ars-data/derivatives/lga/ -p I_DATE_FILTER='^201.*$' -p O_DEGREE_DISTRIBUTION_DIR=/ars-data/results/degree-distribution/ pig/url-degree-distribution.pig
```

#### Results

##### degree-distribution/url-indegree-outdegree

The file(s) under this directory contain the following tab-separated fields: `URL`, `in-degree` and `out-degree`.
The data is ordered in descending order of in-degree.

To get the top 10 URLs with the highest in-degree:
```
head /ars-data/results/degree-distribution/url-indegree-outdegree/part*
```

##### degree-distribution/indegree-numurls

The file(s) under this directory contain the following tab-separated fields: `in-degree` and `num_urls`, where num_urls is the number of URLs with the given in-degree. The data is ordered in descending order of num_urls.

To get the top 10 most common in-degrees:
```
head /ars-data/results/degree-distribution/indegree-numurls/part*
```

##### degree-distribution/outdegree-numurls

The file(s) under this directory contain the following tab-separated fields: `out-degree` and `num_urls`, where num_urls is the number of URLs with the given out-degree. The data is ordered in descending order of num_urls.

To get the top 10 most common out-degrees:
```
head /ars-data/results/degree-distribution/outdegree-numurls/part*
```

### Exercise-6: Domain Graph using LGA data ###

Generate a domain graph dataset that contains the following tab-separated fields: `source_domain`, `destination_domain` and `num_links`, where num_links is the number of links from pages of the source_domain to pages in the destination_domain.

```
cd /ars-workshop/ && pig -x local -p I_LGA_DIR=/ars-data/derivatives/lga/ -p I_DATE_FILTER='^201.*$' -p O_DOMAIN_GRAPH_DIR=/ars-data/results/domain-graph/ pig/generate-domain-graph.pig
```

Next, let's convert this data into a [GEXF file](http://gexf.net/format/) for import into graph visualizations tools like [Gephi](http://gephi.github.io)

```
cat /ars-data/results/domain-graph/part* | /ars-workshop/bin/generate-gexf.py > /ars-data/results/domain-graph.gexf
```

### Exercise-7: Analyze WAT data using Jupyter Notebooks ###

Start a notebook instance by running:
```
cd /ars-workshop/notebooks/ && /ars-workshop/bin/start-jupyter-notebook.sh
```
Enter the Jupyter notebook URL returned by the command in your browser. In the dashboard, open the `WAT-Analysis.ipynb` notebook. Your WAT datasets will be available under `/ars-data/derivatives/wat`. After working through the notebook, you can type Ctrl-c on the command line to stop the notebook server.

When you're done with all the exercises, type in `exit` in the terminal to quit the ARS container.
