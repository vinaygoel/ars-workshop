Archive Research Services Workshop
==================================

## Initial Setup

These tools use Hadoop and Pig.

1. [Setup Passphraseless ssh](#setup-passphraseless-ssh)
2. [Setup Hadoop in Pseudo Distributed Mode](#setup-hadoop-pseudo-mode)
3. [Setup Pig](#setup-pig)
4. [Download Fat JARs](#download-fat-jars)
5. [Download Sample WARC files](#download-sample-warc-files)

### Setup Passphraseless ssh ###

Check that you can ssh to the localhost without a passphrase:

```
ssh localhost
```

If you cannot ssh to localhost without a passphrase, execute the following command:

```
setup/setup-passphraseless-ssh.sh
```  

### Setup Hadoop in Pseudo Distributed Mode ###

If you don't currently have Hadoop installed, execute the following command:

```
setup/setup-hadoop-pseudo-mode.sh /path/to/hadoop/install/dir
```

Please set the HADOOP_HOME environment variable as specified by the script.

### Setup Pig ###

If you don't currently have Hadoop installed, execute the following command:

```
setup/setup-pig.sh /path/to/pig/install/dir
```

Please set PIG_HOME and PATH environment variables as specified by the script.

### Download Fat JARs ###

Execute the following command:

```
setup/download-fat-jars.sh
```

### Download Sample WARC files ###

Execute the following command:

```
setup/download-sample-warcs.sh path/to/local/warc/dir 
```
