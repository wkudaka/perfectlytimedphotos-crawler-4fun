class Photo < ActiveRecord::Base
  

  validates :image_url, presence: true
  validates :image_thumbnail_url, presence: true
  validates :image_title, presence: true
  validates :image_type, presence: true
  validates :photo_crawled_site_id, presence: true
  validates :original_detail_url, presence:true



end