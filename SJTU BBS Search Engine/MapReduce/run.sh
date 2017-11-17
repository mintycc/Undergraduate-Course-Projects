javac -cp $hadoop_CLASSPATH bbsSJTU.java
javac -cp $hadoop_CLASSPATH RegexPathFilter.java
javac -cp $hadoop_CLASSPATH firstMapper.java
javac -cp $hadoop_CLASSPATH firstPartitioner.java
javac -cp $hadoop_CLASSPATH firstReducer.java
javac -cp $hadoop_CLASSPATH Info.java
javac -cp $hadoop_CLASSPATH secondMapper.java
javac -cp $hadoop_CLASSPATH secondReducer.java
javac -cp $hadoop_CLASSPATH JobBuilder.java
javac -cp $hadoop_CLASSPATH aJob.java
jar -cvf aJob.jar ./*.class
hdfs dfs -rm -r firstOutput
hdfs dfs -rm -r secondOutput
hadoop jar aJob.jar aJob /fSJTUk.txt firstOutput firstOutput secondOutput
