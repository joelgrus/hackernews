There are way too many stories on Hacker News, and there's no option for "show me only the stories that Joel would like".  So I built one.  (Maybe "cobbled together" is more appropriate.)

I used Ruby 1.9.2 with the "mongo_mapper" gem.  If you want to scrape the HN daily archives to get old stories, you'll also need the "nokogiri" gem.  And if you want to post the results to blogger, you'll need the "blogger" and "maruku" gems.

Anyway, if one wanted to use this, one would install mongo (or already have it installed).  Then one would run "scrape_old.rb" to download the old HN daily archives.  And one would run "scrape_api.rb" to download the more recent stories.

Next one would run "judger.rb" and rate a lot of stories as to whether you liked or disliked them.  Once you're done judging, it will automatically build a model and predict for everything in the database and spit out some stats.

You can do what you want with the results.  I post mine to [Blogger](http://joelgrus-hackernews.blogspot.com/), using the code in "blogger.rb".  This runs automatically once an hour, as does "scrape_api.rb".

That's it.  The Porter Stemmer "stemmable.rb" is the canonical version that floats around the web.  The list in "stopwords.rb" I found on a website.  Everything else is by me, and you can use it for whatever you want to, although I'm not sure that you *would* want to.