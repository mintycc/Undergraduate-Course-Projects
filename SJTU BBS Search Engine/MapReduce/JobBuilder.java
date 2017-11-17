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

public class JobBuilder {
	public static Job jobFirst(Tool tool, Configuration conf, String[] args) throws IOException {
		if (args.length < 2) {
			printUsage(tool, "<input> <output>");
			return null;
		}
		
		Job job = new Job(conf, "jobFirst");
		job.setJarByClass(tool.getClass());
		
		FileInputFormat.addInputPath(job, new Path(args[0]));
		FileOutputFormat.setOutputPath(job, new Path(args[1]));
		
		job.setInputFormatClass(TextInputFormat.class);
		
		job.setMapperClass(firstMapper.class);
		
		job.setMapOutputKeyClass(Text.class);
		job.setMapOutputValueClass(Info.class);
		
		job.setPartitionerClass(firstPartitioner.class);
		
		job.setReducerClass(firstReducer.class);
		
		job.setOutputKeyClass(Text.class);
		job.setOutputValueClass(Text.class);
		
		job.setOutputFormatClass(TextOutputFormat.class);
		
		job.setNumReduceTasks(30);
		
		return job;
	}
	
	public static Job jobSecond(Tool tool, Configuration conf, String[] args) throws IOException {
		if (args.length < 2) {
			printUsage(tool, "<input> <output>");
			return null;
		}
		
		Job job = new Job(conf, "jobSecond");
		job.setJarByClass(tool.getClass());
		
		String uri = args[0];
		FileSystem fs = FileSystem.get(new Path(uri).toUri(), conf);
		
		FileStatus[] status = fs.listStatus(new Path(uri), new RegexPathFilter(".*\\/part\\-r\\-[0-9]*"));
		for (FileStatus fStatus : status) {
			if (fStatus.isDir() == false)
				FileInputFormat.addInputPath(job, new Path(fStatus.getPath().toUri().getPath()));
		}
		FileOutputFormat.setOutputPath(job, new Path(args[1]));
		
		job.setInputFormatClass(TextInputFormat.class);
		
		job.setMapperClass(secondMapper.class);
		
		job.setMapOutputKeyClass(Text.class);
		job.setMapOutputValueClass(Text.class);
		
		job.setReducerClass(secondReducer.class);
		
		job.setOutputKeyClass(Text.class);
		job.setOutputValueClass(Text.class);
		
		job.setOutputFormatClass(TextOutputFormat.class);
		
		return job;
	}
	
	public static void printUsage(Tool tool, String extraArgsUsage) {
		System.err.printf("Usage: %s [genericOptions] %s\n\n", tool.getClass().getSimpleName(), extraArgsUsage);
		GenericOptionsParser.printGenericCommandUsage(System.err);
	}
}
