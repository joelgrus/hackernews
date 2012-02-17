# load the default model, and make predictions for every story in the database

require_relative "story"
require_relative "model"


def back_predict(only_new = true,verbose=true)

  model = Model.load

  stories = only_new ? Story.where( :prediction => nil ) : Story.all
  
  puts "found #{stories.count} stories to classify"
  
  stories.each do |story|
    
    puts story.inspect if verbose
    
    story.prediction = model.classify(story,verbose)
    story.save
  end
end

def worst_predictions(n = 25)
  false_positives = Story.where( :prediction.gt => 0, :like => false ).sort( :prediction.desc ).take(n)
  false_negatives = Story.where( :prediction.gt => 0, :like => true ).sort( :prediction ).take(n)

  puts "worst false negatives:"
  false_negatives.each do |s|
    puts s.inspect
    puts s.prediction
    puts
  end
  
  puts "worst false positives:"
  false_positives.each do |s|
    puts s.inspect
    puts s.prediction
    puts
  end
end
  
if __FILE__ == $PROGRAM_NAME
  back_predict
  worst_predictions
end  
    