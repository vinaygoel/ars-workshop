# Comment lines begin with a '#' symbol
# Exercise-0

# Hadoop pseudo mode install/data directory (change as needed)
export PSEUDO_MODE_DIR=`pwd`/pseudo-mode

# Please don't make any changes below this line

export PSEUDO_MODE_INSTALL_DIR=$PSEUDO_MODE_DIR/install
export PSEUDO_MODE_DATA_DIR=$PSEUDO_MODE_DIR/data

export LOCAL_WARC_DIR=$PSEUDO_MODE_DATA_DIR/ars-exercise-0-warcs
export LOCAL_DERIVATIVE_DIR=$PSEUDO_MODE_DATA_DIR/ars-exercise-0-derivatives
export HDFS_DERIVATIVE_DIR=$PSEUDO_MODE_DATA_DIR/ars-exercise-0-derivatives

# env variables
export HADOOP_INSTALL_DIR=$PSEUDO_MODE_INSTALL_BASE_DIR/ars-hadoop-install
export PIG_INSTALL_DIR=$PSEUDO_MODE_INSTALL_BASE_DIR/ars-pig-install
export HADOOP_HOME=$HADOOP_INSTALL_DIR/hadoop-2.6.0
export PIG_HOME=$PIG_INSTALL_DIR/pig-0.14.0
export PATH=$PIG_HOME/bin:$PATH
