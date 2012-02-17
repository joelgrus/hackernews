# post any new stories to blogger
# using credentials from the yaml file .blogger in your home directory

require 'twitter' 
require 'maruku'
require_relative 'story'
require_relative 'model'
require "blogger"
require "yaml"

puts Time.now

# this is for conditionally formatting the probabilities,
# although it turns out that blogger just ignores it
def color_from_prob(p)
# want 100% to be green 0,255,0
# want 0% to be red 255,0,0

  rgb = [255 * (1-p),255 * p, 0]
  hex = rgb.map{|i| sprintf("%02x", i).upcase}.join
  return hex
end

new_stories = Story.where(:tweeted => nil).sort(:hnid.desc).take(200)

puts "found #{new_stories.size} new stories"

model = Model.load

# now need to order by joel_probability descending

joel_probs = new_stories.map{|s| model.classify(s,true)}

sorted_stories = joel_probs.zip(new_stories).sort{|s1,s2| s2.first <=> s1.first}

content = sorted_stories.map do |joel_prob,s|

  color = color_from_prob joel_prob
  title = s.link_title.gsub("&","&amp;").gsub("<","&lt;").gsub(">","&gt;")
  hn_link = "http://news.ycombinator.com/item?id=#{s.hnid}"
  link = /^http/ =~ s.link_url ? s.link_url : hn_link

  body = %Q[**#{sprintf("%.3f",joel_prob)}** [#{title}](#{link}) [*comments*](#{hn_link})\n]
  # body = "<div>"
  # body += %Q[<span style="color:#{color}">#{"%.3f" % joel_probability}</span> ]
  # body += %Q[<a href="#{link}">#{title}</a> ]
  # body += %Q[<small><a href ="#{hn_link}">comments</a></small>]
  # body += "</div>"

  body
end.join("\n")

title = "Hacker News stories for #{Time.now.strftime("%l %p on %A %b %d, %Y").strip}"

params = YAML::load(File.open("#{ENV['HOME']}/.blogger"))

account = Blogger::Account.new(URI.escape(params["username"],"@+"),URI.escape(params["password"], "@+"))
blogid = params["blogid"]
userid = params["userid"]

post = Blogger::Post.new(:title => title,:formatter => :maruku)
post.content = content


begin
  
  account.post(blogid,post) if new_stories.size > 0

  new_stories.each do |s|
    s.tweeted = true
    s.tweeted_at = Time.now
    s.save
  end
  
rescue Exception => e
  puts e.inspect
  puts new_stories.map{|s| s.link_title}.join("\n")
end
