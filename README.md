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
2. [Install Docker](#install-docker)
3. [Download Workshop](#download-workshop)
4. [Download Workshop Derivatives](#download-workshop-derivatives)

##### Install Git #####

Please check if you have `Git` installed by running:

```
git --version
```

If not installed, install it by running:

Linux

```
sudo apt-get install git
```

OS X

Follow these instructions for [installing git](https://git-scm.com/book/en/v2/Getting-Started-Installing-Git#Installing-on-Mac) on Mac.

##### Install Docker #####

[Install Docker](https://docs.docker.com/engine/installation/) by following specific instructions for your OS.

Please check if you have `docker` installed by running:

```
docker -v
```

##### Download Workshop #####

This will create a copy of the workshop repository on your computer.

Run:

```
git clone https://github.com/vinaygoel/ars-workshop.git
```

Then "change directory" into the ars-workshop directory, and download software libraries and the docker container needed for the workshop:

```
cd ars-workshop && bin/download-libraries.sh && docker pull vinaygoel/ars-docker-notebooks
```

##### Download Workshop Derivatives #####

Download derivatives (`WAT`, `WANE`, `LGA` and `CDX`) for the [Ferguson Youtube Video Archiving Project](https://archive.org/details/fergusoncrawl&tab=collection?and[]=fergytv), a subset of the [Ferguson Tweets Collection](https://archive.org/details/fergusoncrawl&tab=collection)

Also, included are some sample WATs from [Archive-It's](https://archive-it.org/) [Charlie Hebdo Collection](https://archive-it.org/collections/5190) and [Occupy Movement Collection](https://archive-it.org/collections/2950) for a quick run-through of the WAT exercises.

```
bin/download-workshop-derivatives.sh data/
```

The derivatives total about 1 GB in size and will take around 10 minutes to download (depending on your bandwidth).

You will use these derivative datasets for the upcoming exercises.


==================================
## Exercises

You will run the following exercises in an ARS Docker container. To start the container, run the following from the `ars-workshop` directory:

```
docker run -i -t -p 9200:9200 -p 5601:5601 -p 8888:8888 -v `pwd`:/ars-workshop -v `pwd`/data:/ars-data -v `pwd`/elasticsearch-index-data:/ars-elasticsearch-index-data vinaygoel/ars-docker-notebooks
```

The above command mounts the project and data directories so that any changes made by you will be saved even after the container is killed.

Next, start up the [Elasticsearch](https://www.elastic.co/products/elasticsearch), [Kibana](https://www.elastic.co/products/kibana) and [Jupyter Notebook](http://jupyter.readthedocs.io/en/latest/) services by running:
```
source /set-environment.sh && /start-services.sh && cd /ars-workshop
```

You are now ready!

### Exercise-1: Store CDX data into Elasticsearch ###

Extract all fields from the CDX dataset and index them into Elasticsearch.

```
pig -x local -p I_CDX_DIR=/ars-data/cdx/*cdx* -p O_ES_INDEX_DIR=ars-cdx/cdx pig/store-cdx-data-into-elasticsearch.pig
```

The job creates an Elasticsearch index named `ars-cdx` containing the extracted CDX data.

Example query to search for captures of MIME type `video/mp4`:

```
curl 'http://localhost:9200/ars-cdx/_search?q=mime:"video/mp4"&pretty=true'
```

### Exercise-2: Store WAT text data into Elasticsearch ###

From every HTML document, extract `URL`, `timestamp`, `title text` and `meta text` and index these fields into Elasticsearch.

Option-1: About 30 minutes to process the Ferguson WAT data

```
pig -x local -p I_WAT_DIR=/ars-data/wat/*.wat.gz -p O_ES_INDEX_DIR=ars-wat-text/text pig/store-wat-text-data-into-elasticsearch.pig
```

Option-2: For a faster run-through, use the sample "Charlie Hebdo Collection" WATs

```
pig -x local -p I_WAT_DIR=/ars-data/sample-wat/*.wat.gz -p O_ES_INDEX_DIR=ars-wat-text/text pig/store-wat-text-data-into-elasticsearch.pig
```

The job (either option-1 or option-2) creates an Elasticsearch index named `ars-wat-text` containing the extracted WAT text data.

Example query to search for captures containing the term `obama`:

```
curl 'http://localhost:9200/ars-wat-text/_search?q=obama&pretty=true'
```


### Exercise-3: Store WANE data into Elasticsearch ###

Create an index mapping for the WANE data (to use keyword analyzer)

```
curl -XPOST http://localhost:9200/ars-wane -d @ars-es-mappings/ars-wane-mapping.json
```

Extract named entities (Persons, Locations and Organizations) from the WANE dataset and index them into Elasticsearch.

```
pig -x local -p I_WANE_DIR=/ars-data/wane/ -p O_ES_INDEX_DIR=ars-wane/entities pig/store-wane-data-into-elasticsearch.pig
```

The job creates an Elasticsearch index named `ars-wane` containing the extracted WANE data. This will take some time as the Feruson WANE dataset is fairly large.


### Exercise-4: Video Search using WAT data and Elasticsearch ###

Steps involved:
* Extract all URLs to video (`watch`) pages from WATs
* For each video URL, generate a list of unique terms (using `anchor text` of links), and the number of links to this URL
* Store this data into Elasticsearch

Option-1: About 30 minutes to run through these steps on the Ferguson WAT data

```
pig -x local -p I_WAT_DIR=/ars-data/wat/*.wat.gz -p I_VIDEO_URL_FILTER='.*youtube.com/watch.*' -p O_ES_INDEX_DIR=ars-wat-videos/videos pig/video-search-elasticsearch.pig
```

Option-2: For a faster run-through, use the sample "Charlie Hebdo Collection" WATs

```
pig -x local -p I_WAT_DIR=/ars-data/sample-wat/*.wat.gz -p I_VIDEO_URL_FILTER='.*youtube.com/watch.*' -p O_ES_INDEX_DIR=ars-wat-videos/videos pig/video-search-elasticsearch.pig
```

The job (either option-1 or option-2) creates an Elasticsearch index named `ars-wat-videos`

Example query to search for videos with incoming links that contain the anchor term `police`:

```
curl 'http://localhost:9200/ars-wat-videos/_search?q=anchor_term:police&pretty=true'
```

### Exercise-5: Use Kibana to explore data stored in Elasticsearch ###

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

### Exercise-6: GeoIP using WAT data ###

In this exercise, we will extract IP addresses and generate latitude and longitude information using a dataset available through [MaxMind](http://dev.maxmind.com/geoip/)

The Ferguson dataset WARCs do not contain IP Address information, so let's use the "Charlie Hebdo Collection" sample WAT dataset (which contains IP info) for this exercise.

```
pig -x local -p I_WAT_DIR=/ars-data/sample-wat/*.wat.gz -p O_DATE_LAT_LONG_COUNT_DIR=/ars-data/results/date-lat-long-count/ pig/geoip-from-wat.pig
```
The above command generates a dataset with the following tab-separated fields: `Date`, `Latitude`, `Longitude` and `count`, where count is the number of occurrences of these co-ordinates in the data. 

Next, let's convert this data into a CSV file for import into [CartoDB](https://cartodb.com/)

```
cat /ars-data/results/date-lat-long-count/part* | ./bin/ipcsv.sh > /ars-data/results/date-lat-long.csv
```

You can generate a temporal map using this CSV file and the [Torque library of CartoDB](http://blog.cartodb.com/torque-is-live-try-it-on-your-cartodb-maps-today/)

### Exercise-7: Degree Distribution of URLs using LGA data ###

Steps involved:
* Generate the in-degree (number of incoming links) and out-degree (number of outgoing links) for each URL
* Generate the distribution of in-degree and out-degree (i.e. how many URLs share the same degree value)

```
pig -x local -p I_LGA_DIR=/ars-data/lga/ -p I_DATE_FILTER='^201.*$' -p O_DEGREE_DISTRIBUTION_DIR=/ars-data/results/degree-distribution/ pig/url-degree-distribution.pig
```

#### Results

##### degree-distribution/url-indegree-outdegree

The file(s) under this directory contain the following tab-separated fields: `URL`, `in-degree` and `out-degree`.
The data is ordered in descending order of in-degree.

To get the top 10 URLs with the highest in-degree:
```
head /ars-data/results/degree-distribution/url-indegree-outdegree/part*
```

#####degree-distribution/indegree-numurls

The file(s) under this directory contain the following tab-separated fields: `in-degree` and `num_urls`, where num_urls is the number of URLs with the given in-degree. The data is ordered in descending order of num_urls.

To get the top 10 most common in-degrees:
```
head /ars-data/results/degree-distribution/indegree-numurls/part*
```

#####degree-distribution/outdegree-numurls

The file(s) under this directory contain the following tab-separated fields: `out-degree` and `num_urls`, where num_urls is the number of URLs with the given out-degree. The data is ordered in descending order of num_urls.

To get the top 10 most common out-degrees:
```
head /ars-data/results/degree-distribution/outdegree-numurls/part*
```

### Exercise-8: Domain Graph using LGA data ###

Generate a domain graph dataset that contains the following tab-separated fields: `source_domain`, `destination_domain` and `num_links`, where num_links is the number of links from pages of the source_domain to pages in the destination_domain.

```
pig -x local -p I_LGA_DIR=/ars-data/lga/ -p I_DATE_FILTER='^201.*$' -p O_DOMAIN_GRAPH_DIR=/ars-data/results/domain-graph/ pig/generate-domain-graph.pig
```

Next, let's convert this data into a [GEXF file](http://gexf.net/format/) for import into graph visualizations tools like [Gephi](http://gephi.github.io)

```
cat /ars-data/results/domain-graph/part* | ./bin/generate-gexf.py > /ars-data/results/domain-graph.gexf
```

### Exercise-9: Analyze WAT data using Jupyter Notebooks ###

You can analyze ARS data with Python by accessing the [Jupyter notebook dashboard](http://localhost:8888/) on your browser. In the dashboard, navigate to the `/ars-workshop/notebooks/` folder and open the `WAT-Analysis.ipynb` notebook. The WAT datasets will be available under `/ars-data/`

When you're done with the exercises, type in `exit` in the terminal to quit the container. All your datasets and results will be available under the `data` folder in your current working directory.
