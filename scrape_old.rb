# scrapes the archives of hn daily to get old data for training

require "nokogiri"
require "open-uri"
load "story.rb"
load "utils.rb"

root_url = "http://www.daemonology.net/hn-daily" #2012-01.html"

def month_pages(root_url)
  doc = Nokogiri::HTML(open(root_url))
  doc.xpath("//div[@class='marginlink']/a").to_a
            .map { |node| node["href"] }
            .select { |url| url =~ /[0-9]{4}\-[0-9]{2}\.html/ }
            .map { |url| "#{root_url}/#{url}" }
end


def scrape(url)
  doc = Nokogiri::HTML(open(url))

  storylinks = doc.xpath("//li/span[@class='storylink']/a")
  commentlinks = doc.xpath("//li/span[@class='commentlink']/a")

  if storylinks.size === commentlinks.size
    (storylinks.zip commentlinks).map do |sl,cl|
      description = sl.text
      url = sl["href"]
      hnurl = cl["href"]

      [description,url,hnurl]
    end
  end
end

month_pages(root_url).each do |url|
  puts "scraping url"
  scrape(url).each do |desc,url,hnurl|
    puts desc
    puts url
    puts hnurl
    story = Story.new
    story.hnid = hnid_from_url(hnurl)
    story.link_url = url
    story.link_title = desc
    story.domain = domain(url)
    story.scraped_at = Time.now
    puts "saving"
    story.save   
    puts
  end
end