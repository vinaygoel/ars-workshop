# Comment lines begin with a '#' symbol

# OS X
export JAVA_HOME=$(/usr/libexec/java_home)
# For Linux, comment the above line, and uncomment the following line:
#export JAVA_HOME=/usr

# Pig, Elasticsearch installation directory (change as needed)
export PIG_INSTALL_DIR=/tmp/ars-pig-install
export ELASTICSEARCH_INSTALL_DIR=/tmp/ars-elasticsearch-install

# Pig, Elasticsearch and PATH environment variables
export PIG_HOME=$PIG_INSTALL_DIR/pig-0.14.0
export PATH=$PIG_HOME/bin:$PATH
export ELASTICSEARCH_HOME=$ELASTICSEARCH_INSTALL_DIR/elasticsearch-1.5.2
