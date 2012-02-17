# the class that represents story objects in the database

require 'mongo_mapper'

MongoMapper.database = 'hackernews'

class Story
  include MongoMapper::Document
  
  key :hnid, Integer
  key :link_url, String
  key :link_title, String
  key :domain, String
  key :user, String
  
  key :scraped_at, Time
  key :tweeted_at, Time
  
  key :like, Boolean
  key :tweeted, Boolean
  key :prediction, Float
  
  scope :untweeted, where(:tweeted => false)
  
  def inspect
    "hnid: #{self.hnid}\n#{link_title}\n#{link_url}"
  end
end

Story.ensure_index [[:tweeted,1],[:tweeted_at,-1]]
Story.ensure_index [[:like,1]]
Story.ensure_index [[:hnid,1]], :unique => true


