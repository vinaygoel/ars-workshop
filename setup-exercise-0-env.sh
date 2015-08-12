# Comment lines begin with a '#' symbol
# Exercise-0

# Hadoop pseudo mode install/data directory (change as needed)
export PSEUDO_MODE_INSTALL_DIR=`pwd`/pseudo-mode/install
export PSEUDO_MODE_DATA_DIR=`pwd`/pseudo-mode/data

# Please don't make any changes below this line

export LOCAL_WARC_DIR=$PSEUDO_MODE_DATA_DIR/ars-exercise-0-warcs
export LOCAL_DERIVATIVE_DIR=$PSEUDO_MODE_DATA_DIR/ars-exercise-0-derivatives
export HDFS_DERIVATIVE_DIR=$PSEUDO_MODE_DATA_DIR/ars-exercise-0-derivatives

# unset any of these env variables from before
export HADOOP_LIBEXEC_DIR=
export HADOOP_COMMON_HOME=
export HADOOP_YARN_HOME=
export HADOOP_MAPRED_HOME=
export HADOOP_BIN=

# env variables
export HADOOP_INSTALL_DIR=$PSEUDO_MODE_INSTALL_DIR/ars-hadoop-install
export PIG_INSTALL_DIR=$PSEUDO_MODE_INSTALL_DIR/ars-pig-install
export HADOOP_VERSION=hadoop-2.6.0
export PIG_VERSION=pig-0.14.0
export HADOOP_HOME=$HADOOP_INSTALL_DIR/$HADOOP_VERSION
export PIG_HOME=$PIG_INSTALL_DIR/$PIG_VERSION

if [ -z "$BASH_PROFILE_PATH" ]; then
    export BASH_PROFILE_PATH=$PATH
else
    export PATH=$BASH_PROFILE_PATH
fi
export PATH=$PIG_HOME/bin:$BASH_PROFILE_PATH
