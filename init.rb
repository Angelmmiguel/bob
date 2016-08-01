# Main script. It requires all dependencies and run the project
require 'pry'
require 'pry-nav'
require 'twitter'

require_relative 'models/config'
require_relative 'models/client'

require_relative 'collectors/tweets'

puts CONFIG.twitter

tweets = Tweets.new('laux_es')
data = tweets.get

binding.pry
