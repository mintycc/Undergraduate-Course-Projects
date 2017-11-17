import java.io.*;
import java.util.*;
import org.apache.hadoop.fs.*;
import org.apache.hadoop.conf.*;
import org.apache.hadoop.io.*;
import org.apache.hadoop.util.*;
import org.apache.hadoop.mapreduce.Mapper;
import org.apache.hadoop.mapreduce.Reducer;
import org.apache.hadoop.conf.Configuration;
import org.apache.hadoop.conf.Configured;
import org.apache.hadoop.mapreduce.Job;
import org.apache.hadoop.mapreduce.lib.input.FileInputFormat;
import org.apache.hadoop.mapreduce.lib.output.FileOutputFormat;
import org.apache.hadoop.mapreduce.lib.input.TextInputFormat;
import org.apache.hadoop.mapreduce.lib.output.TextOutputFormat;
import org.apache.hadoop.io.IntWritable;
import org.apache.hadoop.io.LongWritable;

public class aJob extends Configured implements Tool {
	public int run(String[] args) throws Exception {
		String[] firstArgs = {args[0], args[1]};
		Job jobFirst = JobBuilder.jobFirst(this, getConf(), firstArgs);
		if (jobFirst == null) {
			return -1;
		}
		
		if (jobFirst.waitForCompletion(true) == false) {
			return 1;
		}
		
		String[] secondArgs = {args[2], args[3]};
		Job jobSecond = JobBuilder.jobSecond(this, getConf(), secondArgs);
		if (jobSecond == null) {
			return -1;
		}
		return jobSecond.waitForCompletion(true)? 0 : 1;
		
	}
	
	public static void main(String[] args) throws Exception {
		int exitCode = ToolRunner.run(new aJob(), args);
		System.exit(exitCode);
	}
}
