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

import com.google.gson.*;

public class firstMapper extends Mapper<LongWritable, Text, Text, Info> {	
	private HashMap<String, Info> token = new HashMap<String, Info>();
	
	private void dealToken(long id, String sentence, int value) {
		String now = "";
		for (int i = 0; i <= sentence.length(); ++i) {
			//System.out.println(sentence.length() + "?" + i + "]" + now);
			if ((i == sentence.length()) || ((i != sentence.length()) && (sentence.charAt(i) == ' '))) {
				if (now != "") {
					Info preValue = token.get(now);
					if (preValue == null)
						token.put(now, new Info(id, value, i - now.length(), i));
					else
						preValue.addPos(value, i - now.length(), i);
					now = "";
				}
			}
			else now += sentence.charAt(i);
		}
	}
	
	private void emitToken(Context context) throws IOException, InterruptedException {
		for (Map.Entry<String, Info> iterator : token.entrySet()) {
			context.write(new Text(iterator.getKey()), iterator.getValue());
		}
	}
	
	public void map(LongWritable key, Text value, Context context) throws IOException, InterruptedException {
			token.clear();
			bbsSJTU sjtu = new bbsSJTU(value.toString());
			long id = key.get();
			String title = sjtu.getTitle();
			String content = sjtu.getContent();
			//System.out.println(title + "!" + content);
		
			dealToken(id, title, 5);
			dealToken(id, content, 1);
		
			for (Map.Entry<String, Info> iterator : token.entrySet()) {
				context.write(new Text(iterator.getKey()), iterator.getValue());
			}
	}
	
	public void run(Context context) throws IOException, InterruptedException{
		setup(context);
		while (context.nextKeyValue()) {
			map(context.getCurrentKey(), context.getCurrentValue(), context);
		}
		cleanup(context);
	}
}
