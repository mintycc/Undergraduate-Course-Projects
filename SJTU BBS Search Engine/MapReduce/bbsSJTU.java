import java.io.*;
import org.apache.hadoop.io.*;
import java.util.ArrayList;

public class bbsSJTU {
	private String url;
	private String content;
	private String author;
	private String title;
	private String forum;
	
	private int find(String input, int start, int value) {
		for (; (start >= 0) && (start < input.length()); start += value) {
			if (input.charAt(start) == '"')
				return start;
		}
		return -1;
	}
	
	public bbsSJTU() {
		url = null;
		content = null;
		author = null;
		title = null;
		forum = null;
	}
	
	public bbsSJTU(String input) {
		int length = input.length();
		int i = 0;
		ArrayList<Integer> position = new ArrayList<Integer>();
		position.add(input.indexOf("\"url\""));
		position.add(input.indexOf("\"content\""));
		position.add(input.indexOf("\"title\""));
		position.add(input.indexOf("\"forum\""));
		position.add(input.indexOf("\"author\""));
		
		//System.out.println(input);
		i = find(input, position.get(0) + 5, 1);
		int j = find(input, position.get(1) - 1, -1);
		//System.out.println(position.get(0) + "," + position.get(1) + "," + i + "," + j);
		url = input.substring(i + 1, j);
		
		i = find(input, position.get(1) + 9, 1);
		j = find(input, position.get(2) - 1, -1);
		//System.out.println(i + "," + j);
		content = input.substring(i + 1, j);
		
		i = find(input, position.get(2) + 7, 1);
		j = find(input, position.get(3) - 1, -1);
		//System.out.println(i + "," + j);
		title = input.substring(i + 1, j);
		
		i = find(input, position.get(3) + 7, 1);
		j = find(input, position.get(4) - 1, -1);
		//System.out.println(i + "," + j);
		forum = input.substring(i + 1, j);
		
		i = find(input, position.get(4) + 8, 1);
		j = find(input, input.length() - 1, -1);
		//System.out.println(i + "," + j);
		author = input.substring(i + 1, j);
	}
	
	public String getUrl() {
		return url;
	}
	
	public String getContent() {
		return content;
	}
	
	public String getTitle() {
		return title;
	}
}
