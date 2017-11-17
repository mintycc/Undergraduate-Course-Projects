import org.apache.hadoop.mapreduce.Partitioner;
public class firstPartitioner<K, V> extends Partitioner<K, V> {
	public static int lastID = 0;
	@Override
	public int getPartition(K key, V value, int partitionNum) {
		this.lastID++;
		int thisID = (this.lastID % partitionNum);
		return thisID;
	}
}
