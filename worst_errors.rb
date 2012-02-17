require_relative "story"

false_positives = Story.where(:like => false).sort(:prediction.desc)
false_negatives = Story.where(:like => true).sort(:prediction)

puts "*** worst false positives ***"
false_positives.take(25).each do |s|
  puts s.prediction
  puts s.inspect
  puts 
end

puts "*** worst false negatives ***"
false_negatives.take(25).each do |s|
  puts s.prediction
  puts s.inspect
  puts 
end
