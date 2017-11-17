# -*- coding: utf-8 -*-

# Define your item pipelines here
#
# Don't forget to add your pipeline to the ITEM_PIPELINES setting
# See: http://doc.scrapy.org/en/latest/topics/item-pipeline.html

from scrapy import signals
# from scrapy import log
from Crawler.items import CrawlerItem
from scrapy.exporters import JsonLinesItemExporter
from scrapy.exceptions import DropItem
import json
import codecs

class aCrawlerPipeline(object):
	def __init__(self, crawler):
		super(aCrawlerPipeline, self).__init__() #self, crawler)
		self.seen = set()
		self.crawler = crawler
		#self.fileT = codecs.open('itemsT.json', 'w', encoding='utf8')

	@classmethod
	def from_crawler(cls, crawler):
		pipeline = cls(crawler)
		crawler.signals.connect(pipeline.spider_opened, signals.spider_opened)
		crawler.signals.connect(pipeline.spider_closed, signals.spider_closed)
		return pipeline

	def spider_opened(self, spider):
		self.file = codecs.open('items.json', 'w', encoding='utf-8')
		#self.exporter = JsonLinesItemExporter(self.file)
		#self.exporter.start_exporting()

	def spider_closed(self, spider):
		self.file.close()
		
	def process_item(self, item, spider):
		if (item['url']) and (item['forum']) and (item['author']) and (item['title']) and (item['content']):
			if (str(item['url'])) in self.seen:
				raise DropItem("Duplicate item found: %s" % item)
			else:
				self.seen.add(str(item['url']))
				line = json.dumps(dict(item)) + "\n"
				self.file.write(line.decode('unicode_escape'))
				#self.fileT.write(line.decode('unicode_escape'))
				#self.exporter.export_item(item)
				return item
		else:
			raise DropItem("Missing some content!")
