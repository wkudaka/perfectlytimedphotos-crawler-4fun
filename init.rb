require 'anemone'
require 'active_record'
require 'pg'

require_relative 'config/database'
require_relative 'models/photo'
require_relative 'crawler_xpath_and_regex'

SITE_NAME = "http://perfectlytimedphotos.com"

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