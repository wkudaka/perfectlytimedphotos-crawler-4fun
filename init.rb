require 'anemone'
require 'active_record'
require 'pg'

require_relative 'config/database.rb'
require_relative 'models/photo.rb'

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

IGNORE_LIST_PATTERN = Regexp.union [UNMODERATED_PICTURE_DETAIL, UNMODERATED_PICTURE_LIST, LIST_PICTURE_PATTERN]

LIST_TO_CRAWL = Regexp.union [DETAIL_PICTURE_PATTERN]

#XPATH
IMAGE_TITLE = "//div[@id='top-comment-container']/h2[@id='top-comment']"
IMAGE_PATH = "//div[@id='image-container']/a/img"
PHOTO_ID = "//meta[@name='identifier']"
PAGE_TYPE = "//*[@id='main-nav']/li[@class='active']/a"


IMAGE_LIST = "//a[@class='thumbnail']/img"

Anemone.crawl(SITE_NAME) do |anemone|

  anemone.skip_links_like IGNORE_LIST_PATTERN
 
	anemone.focus_crawl do |page|
		page.links.keep_if { |link| link.to_s.match(LIST_TO_CRAWL) }
	end
 
	anemone.on_pages_like(DETAIL_PICTURE_PATTERN) do |page|

	  title = page.doc.at_xpath(IMAGE_TITLE).text rescue nil
	  image_path = page.doc.at_xpath(IMAGE_PATH)["src"] rescue nil
	  photo_id = page.doc.at_xpath(PHOTO_ID)["content"] rescue nil
	  page_type = page.doc.at_xpath(PAGE_TYPE).text rescue nil
	  page_url = page.url.to_s

	  if photo_id.present?
	  	photo = Photo.where(:photo_crawled_site_id => photo_id.to_i).first

	  	if photo.nil?
	  		photo = Photo.new
	  	end

		  photo.image_url = image_path
		  photo.image_title = title
		  photo.image_type = page_type
		  photo.photo_crawled_site_id = photo_id
		  photo.original_detail_url = page_url


		  if image_path.present?
		  	photo.image_thumbnail_url = image_path.gsub %r[(resized)\/], "icon/"

		  end

		  if photo.valid?
		  	photo.save!
		  	puts "Photo with id:#{photo.id} saved!"
		  end
		  
	  end  

	end


 	anemone.on_every_page do |page|
	
	end
 
	anemone.after_crawl do |page|
	
	end
 
end