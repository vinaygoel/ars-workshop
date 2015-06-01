# Comment lines begin with a '#' symbol

# installation and data directories (change as needed)
export ARS_EXERCISES_INSTALL_DIR=`pwd`/install
export ARS_EXERCISES_DATA_DIR=`pwd`/data

#data directories
export ARS_EXERCISES_DERIVATIVES_DIR=$ARS_EXERCISES_DATA_DIR/ars-exercises-derivatives
export ARS_EXERCISES_RESULTS_DIR=$ARS_EXERCISES_DATA_DIR/ars-exercises-results

#installation directories
export HADOOP_PIG_LOCAL_INSTALL_DIR=$ARS_EXERCISES_INSTALL_DIR/ars-hadoop-pig-local-install
export ELASTICSEARCH_INSTALL_DIR=$ARS_EXERCISES_INSTALL_DIR/ars-elasticsearch-install
export ELASTICSEARCH_HOME=$ELASTICSEARCH_INSTALL_DIR/elasticsearch-1.5.2
export KIBANA_INSTALL_DIR=$ARS_EXERCISES_INSTALL_DIR/ars-kibana-install
export KIBANA_HOME=$KIBANA_INSTALL_DIR/kibana-4.0.2

#setting env variables
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
