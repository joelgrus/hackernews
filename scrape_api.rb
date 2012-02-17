# scrape new stories from the unofficial hacker news api
# the API is broken half the time, so this needs to be made more robust

require 'open-uri'
require 'json'
require_relative "story"
require_relative "utils"
require_relative "model"

base_url = "http://news.ycombinator.com/newest"

puts Time.now

def scrape(max_pages = 1, base_url)
  new_stories = []
  url = base_url
  found_known_story = false
  model = Model.load


  (1..max_pages).each do |i|

    puts "opening page #{i}: #{url}"
    
    r = open(url).readline
    
    puts "found #{r.size} characters"
    
    doc = JSON.parse r

    nextId = doc["nextId"]

    doc["items"].each do |item|

      itemid = item["id"]

      if Story.where(:hnid => itemid).count > 0
        found_known_story = true
        puts "known story: #{itemid}"
      else      
        story = Story.new
        story.hnid = itemid
        story.link_url = item["url"]
        story.link_title = item["title"]
        story.domain = domain(item["url"])
        story.scraped_at = Time.now
        story.user = item["postedBy"]
        story.prediction = model.classify(story) if model
        new_stories << story
      end
    end
    
    break if found_known_story
    break unless nextId

    url = "#{base_url}/#{nextId}"
    puts "moving ahead to #{url}"
  end
  
  puts "found #{new_stories.size} new stories"
  new_stories.each do |s|
    s.save
    puts "new story:"
    puts s.hnid
    puts s.link_title
    puts s.link_url
  end
end


begin
  scrape(20,"http://api.ihackernews.com/new")
rescue
  puts "new failed, try again later"
end