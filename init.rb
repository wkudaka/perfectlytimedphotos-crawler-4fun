require 'anemone'


=begin
to remember:

examples of links with details:

http://perfectlytimedphotos.com/perfectly-timed-photo/popular/7281-that-wasnt-out-it-was-clea

http://perfectlytimedphotos.com/unmoderated-perfectly-timed-photo/unmoderated/139218-perfectly-timed-photo

http://perfectlytimedphotos.com/perfectly-timed-photo/popular/41390-spider-cat-spider-cat-do

http://perfectlytimedphotos.com/perfectly-timed-photo/recent/222413-i-can-t-believe-rob-ate-the




examples of links with lists:

http://perfectlytimedphotos.com/popular/perfectly-timed-photo

http://perfectlytimedphotos.com/popular/perfectly-timed-photo/2

http://perfectlytimedphotos.com/newest/perfectly-timed-photo

http://perfectlytimedphotos.com/unmoderated/recent/perfectly-timed-photo

http://perfectlytimedphotos.com/newest/perfectly-timed-photo/2


=end



SITE_NAME = "http://perfectlytimedphotos.com"

# Patterns
POPULAR_PICTURE_DETAIL = %r[(popular)+\/[[\w|-]]{10,}+$]
NEWEST_PICTURE_DETAIL = %r[(perfectly-timed-photo\/recent)+\/[[\w|-]]{10,}+$]
UNMODERATED_PICTURE_DETAIL = %r[(unmoderated)+\/[[\w|-]]{10,}+$]

POPULAR_PICTURE_LIST = %r[(popular\/perfectly-timed-photo)\/*\d*\/*$]
NEWEST_PICTURE_LIST = %r[(newest\/perfectly-timed-photo)\/*\d*\/*$]
UNMODERATED_PICTURE_LIST = %r[(unmoderated\/recent\/perfectly-timed-photo)\/*\d*\/*$]

DETAIL_PICTURE_PATTERN = Regexp.union [POPULAR_PICTURE_DETAIL, NEWEST_PICTURE_DETAIL]
LIST_PICTURE_PATTERN = Regexp.union [POPULAR_PICTURE_LIST, NEWEST_PICTURE_LIST]

IGNORE_LIST_PATTERN = Regexp.union [UNMODERATED_PICTURE_DETAIL, UNMODERATED_PICTURE_LIST]

LIST_TO_CRAWL = Regexp.union [DETAIL_PICTURE_PATTERN, LIST_PICTURE_PATTERN]

#XPATH
IMAGE_TITLE = "//div[@id='top-comment-container']/h2[@id='top-comment']"
IMAGE_PATH = "//div[@id='image-container']/a/img"

IMAGE_LIST = "//a[@class='thumbnail']/img"

Anemone.crawl(SITE_NAME) do |anemone|

  	anemone.skip_links_like IGNORE_LIST_PATTERN
 
	# Filter a page's links down to only those you want to crawl
	anemone.focus_crawl do |page|
		page.links.keep_if { |link| link.to_s.match(LIST_TO_CRAWL) }
	end
 
	anemone.on_pages_like(DETAIL_PICTURE_PATTERN) do |page|
	  title = page.doc.at_xpath(IMAGE_TITLE).text rescue "not found"
	  image_path = page.doc.at_xpath(IMAGE_PATH)["src"] rescue "not found"
	  
	  puts "#{page.url} - #{title} - #{image_path}"
	end

	anemone.on_pages_like(LIST_PICTURE_PATTERN) do |page|
	  #implement....
	  puts "test ---- #{page.doc.xpath(IMAGE_LIST).inspect}"
	end

 	anemone.on_every_page do |page|
	
	end
 
	anemone.after_crawl do |page|
	
	end
 
end