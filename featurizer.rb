# turns a story into a set of features

require "set"
require_relative "stopwords"
require_relative "story"
require_relative "utils"
require_relative "stemmable"

class String
  include Stemmable
end


class Story
  def features()
  
    feature_set = Set.new
    
    #words
    regex_splitter = /[^a-z0-9\-'+#]/
    title = self.link_title.downcase
    words = title.split(regex_splitter).select{|w| !w.empty?}
      
    words.select{|w| !is_stopword w}
         .each {|w| feature_set.add "word_#{w.stem}"}
    
    # bigrams
    bigrams = words.each_cons(2)
                .select{|pair| (!is_stopword pair[0]) or (!is_stopword pair[1])}
                .map{|pair| pair[0].stem + "_" + pair[1].stem}
    
    bigrams.each {|b| feature_set.add "bigram_#{b}"}
    
    #domain
    
    feature_set.add "domain_#{self.domain}"
    
    #user
    
    feature_set.add "user_#{self.user}" if self.user
    
    #user_in_domain

    user_in_domain = self.domain.include? self.user if self.user
    feature_set.add "userindomain" if user_in_domain
       
    # is_pdf
    feature_set.add("pdf") if /\.pdf/i =~ self.link_url
    
    # is_question
    feature_set.add("isquestion") if /\?$/ =~ self.link_title
    
    # dollar_amount
    feature_set.add("dollaramount") if /\$[0-9]+/ =~ self.link_title
    
    # hours amount
    feature_set.add("hoursamount") if /\b[1-9][0-9]* hours?\b/i =~ self.link_title

    # years amount
    feature_set.add("yearsamount") if /\b[1-9][0-9]* years?\b/i =~ self.link_title
    
    # yc class
    feature_set.add("ycclass") if /YC [A-Z][0-9]{2}/i =~ self.link_title
    
    # in quotes
    feature_set.add("inquotes") if /^".*"$/ =~ self.link_title
    
    return feature_set
  end
end

