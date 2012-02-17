# show the most common features, 
# the most positive features,
# and the most negative features

require_relative "story"
require_relative "featurizer"

liked = Story.where(:like => true)
disliked = Story.where(:like => false)


liked_features = Hash[ liked.to_a.map{|story| story.features.to_a}.flatten
                  .group_by{|feat| feat}
                  .map{|k,v| [k,v.size]} ]

disliked_features = Hash[ disliked.to_a.map{|story| story.features.to_a}.flatten
                  .group_by{|feat| feat}
                  .map{|k,v| [k,v.size]} ]
                  
all_features = (liked_features.keys + disliked_features.keys).uniq
                  .map{|k| [k,
                            liked_features.fetch(k,0),
                            disliked_features.fetch(k,0),
                            liked_features.fetch(k,0) + disliked_features.fetch(k,0)] }
                            
                  
puts "top 25 features"                  
topf = all_features.sort{|r1,r2| r2.last <=> r1.last}.take(25)
topf.each do |f|
  puts f.inspect
end
puts

puts "top 25 positive features"                  
topf = all_features.sort{|r1,r2| (r2[1] - r2[2]) <=> (r1[1] - r1[2])}.take(25)
topf.each do |f|
  puts f.inspect
end
puts 

puts "top 25 negative features"                  
topf = all_features.sort{|r1,r2| (r2[2] - r2[1]) <=> (r1[2] - r1[1])}.take(25)
topf.each do |f|
  puts f.inspect
end
