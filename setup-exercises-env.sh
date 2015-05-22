# Comment lines begin with a '#' symbol

# Hadoop-2 / Pig and Elasticsearch local installation directories (change as needed)
export HADOOP_PIG_LOCAL_INSTALL_DIR=/tmp/ars-hadoop-pig-local-install
export ELASTICSEARCH_INSTALL_DIR=/tmp/ars-elasticsearch-install
export ELASTICSEARCH_HOME=$ELASTICSEARCH_INSTALL_DIR/elasticsearch-1.5.2
export ARS_DERIVATIVES_DIR=/tmp/ars-exercises-derivatives

export HADOOP_INSTALL_DIR=$HADOOP_PIG_LOCAL_INSTALL_DIR/hadoop-2-local-mode
export HADOOP_HOME=$HADOOP_INSTALL_DIR/hadoop
export HADOOP_COMMON_HOME=$HADOOP_INSTALL_DIR/hadoop
export HADOOP_LIBEXEC_DIR=$HADOOP_COMMON_HOME/libexec
export HADOOP_YARN_HOME=$HADOOP_INSTALL_DIR/hadoop-yarn
export HADOOP_MAPRED_HOME=$HADOOP_INSTALL_DIR/hadoop-mapreduce
export HADOOP_BIN=$HADOOP_COMMON_HOME/bin/hadoop
export PIG_HOME=$HADOOP_INSTALL_DIR/pig
export YARN_COMMON_HOME=$HADOOP_YARN_HOME
export YARN_HOME=$HADOOP_YARN_HOME
export PATH=$HADOOP_COMMON_HOME/bin:$HADOOP_YARN_HOME/bin:$HADOOP_INSTALL_DIR/pig/bin:$PATH
