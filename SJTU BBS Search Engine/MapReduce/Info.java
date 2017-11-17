import java.io.*;
import org.apache.hadoop.io.*;
import java.util.ArrayList;

public class Info implements WritableComparable<Info> {
	private LongWritable id;
	private DoubleWritable rank;
	private ArrayList<IntWritable> posBegin;
	private ArrayList<IntWritable> posEnd;
	
	private static int num1 = 13777;
	private static int num2 = 957777;
	
	public Info() {
		set(new LongWritable(), new DoubleWritable(), new ArrayList<IntWritable>(), new ArrayList<IntWritable>());
	}
	
	public Info(long _id, double _rank, int _posBegin, int _posEnd) {
		ArrayList<IntWritable> tempBegin = new ArrayList<IntWritable>();
		ArrayList<IntWritable> tempEnd = new ArrayList<IntWritable>();
		tempBegin.add(new IntWritable(_posBegin));
		tempEnd.add(new IntWritable(_posEnd));
		set(new LongWritable(_id), new DoubleWritable(_rank), tempBegin, tempEnd);
	}
	
	public void set(LongWritable _id, DoubleWritable _rank, ArrayList<IntWritable> _posBegin, ArrayList<IntWritable> _posEnd) {
		this.id = _id;
		this.rank = _rank;
		this.posBegin = _posBegin;
		this.posEnd = _posEnd;
	}
	
	public double getRank() {
		return rank.get();
	}
	
	public int getPosBegin(int pos) {
		return posBegin.get(pos).get();
	}
	
	public int getPosEnd(int pos) {
		return posEnd.get(pos).get();
	}
	
	public int getTotalPos() {
		return posBegin.size();
	}
	
	public void reRank(int num) {
		this.rank = new DoubleWritable(this.rank.get() / num);
	}
	
	public void addPos(int value, int _begin, int _end) {
		this.rank = new DoubleWritable(this.rank.get() + value);
		this.posBegin.add(new IntWritable(_begin));
		this.posEnd.add(new IntWritable(_end));
	}
	
	@Override
	public void write(DataOutput out) throws IOException {
		id.write(out);
		rank.write(out);
		
		IntWritable number = new IntWritable(this.getTotalPos());
		number.write(out);
		
		for (int i = 0; i < number.get(); ++i) {
			posBegin.get(i).write(out);
			posEnd.get(i).write(out);
		}
	}
	
	@Override
	public void readFields(DataInput in) throws IOException {
		id.readFields(in);
		rank.readFields(in);
		
		IntWritable number = new IntWritable();
		number.readFields(in);
		
		posBegin = new ArrayList<IntWritable>();
		posEnd = new ArrayList<IntWritable>();
		for (int i = 0; i < number.get(); ++i) {
			IntWritable temp = new IntWritable();
			temp.readFields(in);
			posBegin.add(new IntWritable(temp.get()));
			temp.readFields(in);
			posEnd.add(new IntWritable(temp.get()));
		}
	}
	
	@Override
	public int hashCode() {
		String thisTemp = this.toString();
		int hash = 0;
		for (int i = 0; i < thisTemp.length(); ++i)
			hash = (hash * num1 + thisTemp.charAt(i)) % num2;
		return hash;
	}
	
	@Override
	public boolean equals(Object o) {
		if (o instanceof Info) {
			Info info = (Info) o;
			ArrayList<IntWritable> remain = new ArrayList(posBegin);
			remain.removeAll(info.posBegin);
			if (remain.size() > 0)
				return false;
			remain = new ArrayList(posEnd);
			remain.removeAll(info.posEnd);
			if (remain.size() > 0)
				return false;
			return (id.equals(info.id)) && (rank.equals(info.rank));
		}
		return false;
	}
	
	@Override
	public String toString() {
		String position = "";
		int total = this.getTotalPos();
		for (int i = 0; i < total; ++i) {
			if (i > 0)
				position += "%";
			position += posBegin.get(i).toString() + "|" + posEnd.get(i).toString();
		}
		return id.toString() + ":" + rank.toString() + ":" + position;
	}
	
	@Override
	public int compareTo(Info info) {
		int cmp = id.compareTo(info.id);
		if (cmp != 0)
			return cmp;
		cmp = rank.compareTo(info.rank);
		if (cmp != 0)
			return cmp;
		int number = this.getTotalPos();
		for (int i = 0; i < number; ++i)
		{
			cmp = posBegin.get(i).compareTo(info.posBegin.get(i));
			if (cmp != 0)
				return cmp;
			cmp = posEnd.get(i).compareTo(info.posEnd.get(i));
			if (cmp != 0)
				return cmp;
		}
		return 0;
	}
}
