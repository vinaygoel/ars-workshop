# OS X
export JAVA_HOME=$(/usr/libexec/java_home)

# For Linux, uncomment the following line:
#export JAVA_HOME=/usr

# Hadoop and Pig installation directories (change as needed)
export HADOOP_INSTALL_DIR=/tmp/ars-hadoop-install
export PIG_INSTALL_DIR=/tmp/ars-pig-install

# Hadoop, Pig and PATH environment variables
export HADOOP_HOME=$HADOOP_INSTALL_DIR/hadoop-2.6.0
export PIG_HOME=$PIG_INSTALL_DIR/pig-0.14.0
export PATH=$PIG_HOME/bin:$PATH

# Data directories (change as needed)
export LOCAL_WARC_DIR=/tmp/ars-workspace-warcs
export LOCAL_DERIVATIVE_DIR=/tmp/ars-workspace-derivatives
export HDFS_DERIVATIVE_DIR=/tmp/ars-workspace-derivatives
