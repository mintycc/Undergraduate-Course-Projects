# SJTU BBS Search Engine

![](https://img.shields.io/badge/Hadoop-2.9.0-blue.svg?style=flat-square) ![](https://img.shields.io/badge/Stanford%20Segmenter-3.8.0-green.svg?style=flat-square)
![](https://img.shields.io/badge/Language-Java%20|%20Python-yellowgreen.svg?style=flat-square) 
![](https://img.shields.io/badge/Platform-Linux-lightgray.svg?style=flat-square)

## 1. Project Introduction

To consolidate the knowledge learnt in course **Distributed Programming**, I implemented a local search engine of [SJTU-BBS](http://bbs.sjtu.edu.cn) supported by **Apache Hadoop**.

This search engine includes three parts: one **crawler**, one **segementer** and one **map-reducer**. 

Basically speaking, crawler crawls passages from  websites, segementer splits passages into keywords and map-reducer sorts keywords into indexes to be used in searching.

The project was developed and tested on **Linux** platform, mainly written in **Java** and **Python**.

## 2. Technique Details

### a. Crawler

	./Crawler

This crawler collects passages and related information from `https://bbs.sjtu.edu.cn` and stores all of them into one file.

Several information are required in one passage: URL, Hot, Author, Title and Content.

### b. Segmenter

	./Segmenter

Because the main language of these passages is Chinese, we need one Chinese segmenter to split sentences into keywords. The segmenter used here is [Stanford Word Segmenter](https://nlp.stanford.edu/software/segmenter.shtml).

There points to be noticed here:

1. Data should be JSON format. In order to make whole passage stay in one line, we should replace line breaks by "$" and put them back after processing.
2. Information like "URL" will also be splitted, so `handle.cpp` is written here to handle those extra spaces. 
3. Another `pune.cpp` to maintain the formats.

### c. Map-reducer

	./MapReduce

After splitting words, the first map-reducer is used here to produce inverted index. This index includes all keywords followed by URLs this particular keyword appears in.

However, this single index file itself maybe too large to search through. To speed up the searching operation, we split this index file into several little indexes according to partitioner, then build a second level index for them by the second map-reducer.

## 3. Hot to Use

Make sure you have installed Python, Hadoop and Stanford Word Segmenter on your computer.

### 1. Crawler

Enter crawler folder, input command:

    scrapy crawl aSpider >output.txt

### 2. Segmenter

Enter segmenter folder, first run Stanford Word Segmenter, then input commands:

    make handle
    ./handle <input_file> <output_file>
    make pune
    ./pune <input_file> <output_file>

### 3. MapReducer

Upload input files and code to HDFS.

Enter map-reducer folder, open `run.sh`, change `<input_file>` in code to your input path.

Then type in `run` to run the map-reducer.