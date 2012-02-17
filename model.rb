# class to build a naive bayes model
# and save it to disk or load it back

require_relative 'story'
require_relative 'featurizer'

def split(stories,test_split)
  test = []
  train = []
  
  stories.each do |s|
    if rand < test_split
      test << s
    else
      train << s
    end
  end
  
  return [train,test]
end


class Model
  attr_accessor :created_at, :positives, :negatives, :feature_counts  

  def test(liked,disliked)
  
    results = liked.map{|s| [self.classify(s),1]} + 
           disliked.map{|s| [self.classify(s),0]}
    
    total_pos = results.select{|r| r[1] == 1}.size
    20.downto(0).map do |n|
      pct = n.to_f / 20
      true_pos = results.select{|r| r[0] >= pct and r[1] == 1}.size
      false_pos = results.select{|r| r[0] >= pct and r[1] == 0}.size
      precision = true_pos.to_f / (true_pos + false_pos)
      recall = true_pos.to_f / total_pos
      [pct,true_pos + false_pos,precision,recall]
    end
  end

  
  def train(min_feature_freq = 3,test_split = 0.2,verbose=false)

    liked = Story.where(:like => true)
    disliked = Story.where(:like => false)

    liked_train,liked_test = split(liked,test_split)
    disliked_train,disliked_test = split(disliked,test_split)
    
    puts "training: #{liked_train.size + disliked_train.size} examples"
    puts "test: #{liked_test.size + disliked_test.size} examples"
    
    liked_features = Hash[ liked_train.to_a.map{|story| story.features.to_a}.flatten
                  .group_by{|feat| feat}
                  .map{|k,v| [k,v.size]} ]

    disliked_features = Hash[ disliked_train.to_a.map{|story| story.features.to_a}.flatten
                  .group_by{|feat| feat}
                  .map{|k,v| [k,v.size]} ]
                  
    all_features = (liked_features.keys + disliked_features.keys).uniq
                  .map{|k| {:feature => k,
                            :positives => liked_features.fetch(k,0),
                            :negatives => disliked_features.fetch(k,0),
                            :total => liked_features.fetch(k,0) + disliked_features.fetch(k,0)} }
                  .select{|f| f[:total] >= min_feature_freq}

  # pseudo_counts:
  
    all_features.each do |f|
      f[:positives] += 2
      f[:negatives] += 2
      f[:total] += 4
    end

    # and turn into a hash
    
    self.feature_counts = Hash[ all_features.map do |dict| 
                                  feature = dict[:feature]
                                  dict.delete(:feature)
                                  [feature,dict]
                                end]
        
    self.created_at = Time.now
    self.positives = all_features.map{|f| f[:positives]}.sum
    self.negatives = all_features.map{|f| f[:negatives]}.sum
    
    if verbose
      puts self.feature_counts.inspect
      puts self.positives
      puts self.negatives
    end

    test(liked_test,disliked_test).each do |pct,num,precision,recall|
      puts "#{pct}\t#{num}\t#{precision}\t#{recall}"
    end
    
  end
  
  def log_p_feature(feature)
    
    p_feature_given_positive = self.feature_counts[feature][:positives].to_f / self.positives.to_f
    p_feature_given_negative = self.feature_counts[feature][:negatives].to_f / self.negatives.to_f
    return Math.log(p_feature_given_positive / p_feature_given_negative)
  end
  
  def classify(story,verbose=false)
    
    features = story.features
    puts features.inspect if verbose
  
    base_odds = self.positives.to_f / self.negatives.to_f 
    
    usable_features = features.select{|f| self.feature_counts.has_key? f}
    feature_odds = usable_features.map{|f| log_p_feature(f)}
    
    if verbose
      
      puts "#{Math.log(base_odds).round(3)}\t -- base log odds"
      
      usable_features.zip(feature_odds).each do  |f,lo| 
        puts "#{lo.round(3)}\t -- #{f}" 
      end
    end
          
    odds = base_odds * Math.exp(feature_odds.sum)
    # odds are p / n = p / 1 - p, so that
    # p = (1 - p) * odds
    # p (1 + odds) = odds
    
    p = odds / (1 + odds)
    
    puts p if verbose
    
    return p
    
  end
    
  def save(filename=File.join(File.dirname(__FILE__), 'model.mod' ))
    File.open(filename,'w') { |f| f.write(YAML::dump(self)) }
  end
  
  def self.load(filename=File.join(File.dirname(__FILE__), 'model.mod' ))
    if File.exists? filename
      return YAML.load(File.read(filename))
    else
      return nil
    end
  end
end

