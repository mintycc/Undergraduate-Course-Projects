import java.io.*;
import java.util.*;
import org.apache.hadoop.fs.*;
import org.apache.hadoop.conf.*;
import org.apache.hadoop.io.*;
import org.apache.hadoop.util.*;
import org.apache.hadoop.conf.Configuration;
import org.apache.hadoop.conf.Configured;
import org.apache.hadoop.mapreduce.lib.input.FileInputFormat;
import org.apache.hadoop.mapreduce.lib.output.FileOutputFormat;

public class RegexPathFilter implements PathFilter {
	private final String regex;
	
	public RegexPathFilter(String regex) {
		this.regex = regex;
	}
	
	public boolean accept(Path path) {
		return path.toString().matches(regex);
	}
}
