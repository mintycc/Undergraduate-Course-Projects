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
import org.apache.hadoop.mapreduce.Mapper;
import org.apache.hadoop.io.IntWritable;
import org.apache.hadoop.io.LongWritable;

public class firstReducer extends Reducer<Text, Info, Text, Text> {
	public void reduce(Text key, Iterable<Info> values, Context context) throws IOException, InterruptedException{
		//System.out.println("In reduce");
		ArrayList<Info> storeV = new ArrayList<Info>();
		int count = 0;
		for (Info value : values) {
			count ++;
			storeV.add(value);
		}
		//System.out.println(count);
		String multiInfo = "";
		for (Info value : storeV) {
			//System.out.println(value.getRank() + value.getTotalPos() + value.toString());
			value.reRank(count);
			//System.out.println(value.getRank() + value.getTotalPos() + value.toString());
			if (value.toString().length() > 0) {
				if (multiInfo.length() > 0)
					multiInfo += ";";
				multiInfo += value.toString();
			}
		}
		if (multiInfo.length() > 0)
			context.write(key, new Text(multiInfo));
	}
}
