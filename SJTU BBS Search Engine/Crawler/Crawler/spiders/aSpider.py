from scrapy.selector import Selector
from scrapy.http import Request
from scrapy.spiders import CrawlSpider
from scrapy.loader import ItemLoader
from scrapy.linkextractors import LinkExtractor
from Crawler.items import CrawlerItem 

class aSpider(CrawlSpider):
	name = 'aSpider' #The name of this spider
	allow_domain = ['bbs.sjtu.edu.cn'] #All the URLs should belong to these domain names
	start_urls = ['https://bbs.sjtu.edu.cn/bbsall',
				  'https://bbs.sjtu.edu.cn'] #A list of URLs where the spider will begin to crawl from
	link_extractor = {
		'page': LinkExtractor(allow = '\w+/bbsdoc,board,\w+\.html$'),
		#'page_down': SgmlLinkExtractor(allow = '/bbsdoc,board,\w+,page,\d+\.html$'), I thought it is useless now since I cannot find any URL that can match this rule
		'content': LinkExtractor(allow = '\w+/bbscon,board,\w+,file,M\.\d+\.A\.html$'),
	}  #The link extractors
	_x_path = { #I modified the numbers in the brackets since I thought the original numbers were wrong. Maybe I will find out that it was I who was wrong and change them back soon.
		'forum': '//center/text()[1]',
		'author': '//pre/a/text()',
		'title': '//head/title/text()',
		'content': '//pre/text()[2]',
	}

	def parse(self, response):
		for link in self.link_extractor['page'].extract_links(response):
			self.log('aSpider parse page' + link.url)
			yield Request(url = link.url, callback = self.parse_page, meta = {'dont_redirect': True, 'handle_httpstatus_list': [302]})

	def parse_page(self, response):
		for link in self.link_extractor['content'].extract_links(response):
			self.log('aSpider parse content' + link.url)
			yield Request(url = link.url, callback = self.parse_content, meta = {'dont_redirect': True, 'handle_httpstatus_list': [302]})

	def parse_content(self, response):
		CrawlerItemLoader = ItemLoader(item = CrawlerItem(), response = response)
		url = str(response.url)

		CrawlerItemLoader.add_value('url', url)
		CrawlerItemLoader.add_xpath('forum', self._x_path['forum'])
		CrawlerItemLoader.add_xpath('author', self._x_path['author'])
		CrawlerItemLoader.add_xpath('title', self._x_path['title'])
		CrawlerItemLoader.add_xpath('content', self._x_path['content'])

		return CrawlerItemLoader.load_item()
