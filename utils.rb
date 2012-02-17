# a couple of useless utils

require 'set'

def hnid_from_url(hnurl)
  # hnurl is something like http://news.ycombinator.com/item?id=3571958
  /id=([0-9]+)/.match(hnurl)
  return $1.to_i
end

NEED_SUBDOMAIN = Set.new ["wordpress.com","co.uk"]

def domain(url,default = "ycombinator.com")
  return default unless url[0...4] === "http"
  /https?:\/\/([^\/]+)/.match(url)
  pieces = $1.split(".")
  d = pieces.last(2).join(".")
  d = pieces.last(3).join(".") if NEED_SUBDOMAIN.include? d
  return d
end
