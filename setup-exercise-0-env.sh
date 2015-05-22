# Comment lines begin with a '#' symbol

# Exercise-0

# Hadoop pseudo mode and Pig installation directory (change as needed)
export HADOOP_INSTALL_DIR=/tmp/ars-hadoop-install
export PIG_INSTALL_DIR=/tmp/ars-pig-install

export HADOOP_HOME=$HADOOP_INSTALL_DIR/hadoop-2.6.0
export PIG_HOME=$PIG_INSTALL_DIR/pig-0.14.0
export PATH=$PIG_HOME/bin:$PATH

#Data directories (change as needed)
export LOCAL_WARC_DIR=/tmp/ars-exercise-0-warcs
export LOCAL_DERIVATIVE_DIR=/tmp/ars-exercise-0-derivatives
export HDFS_DERIVATIVE_DIR=/tmp/ars-exercise-0-derivatives
