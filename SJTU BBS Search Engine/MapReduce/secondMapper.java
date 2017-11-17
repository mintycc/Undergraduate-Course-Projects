import java.io.*;
import java.util.*;
import java.lang.*;
import org.apache.hadoop.fs.*;
import org.apache.hadoop.conf.*;
import org.apache.hadoop.io.*;
import org.apache.hadoop.util.*;
import org.apache.hadoop.mapreduce.Mapper;
import org.apache.hadoop.mapreduce.Reducer;
import org.apache.hadoop.conf.Configuration;
import org.apache.hadoop.conf.Configured;
import org.apache.hadoop.mapreduce.Job;
import org.apache.hadoop.mapreduce.JobContext;
import org.apache.hadoop.mapreduce.lib.input.FileInputFormat;
import org.apache.hadoop.mapreduce.lib.output.FileOutputFormat;
import org.apache.hadoop.mapreduce.lib.input.TextInputFormat;
import org.apache.hadoop.mapreduce.lib.output.TextOutputFormat;
import org.apache.hadoop.mapreduce.lib.input.FileSplit;
import org.apache.hadoop.io.IntWritable;
import org.apache.hadoop.io.LongWritable;

public class secondMapper extends Mapper<LongWritable, Text, Text, Text> {
	public void map(LongWritable key, Text value, Context context) throws IOException, InterruptedException {
		String fileName = ((FileSplit)context.getInputSplit()).getPath().toString();
		String firstIndex = value.toString();
		String token = "";
		for (int i = 0; i < firstIndex.length(); ++i) {
			if (firstIndex.charAt(i) == '\t')
				break;
			token += firstIndex.charAt(i);
		}
		
		String infor = fileName + "#" + key.toString();
		context.write(new Text(token), new Text(infor));
		//System.out.println(token + "@@@@@@@@@@@@@" + value.toString());
		//while(true);
	}
	
	public void run(Context context) throws IOException, InterruptedException{
		setup(context);
		while (context.nextKeyValue()) {
			map(context.getCurrentKey(), context.getCurrentValue(), context);
		}
		cleanup(context);
	}
}
