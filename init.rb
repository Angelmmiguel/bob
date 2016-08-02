# Main script. It requires all dependencies and run the project
require 'pry'
require 'pry-nav'
require 'twitter'

# Utils
require_relative 'utils/logger'

require_relative 'models/config'
require_relative 'models/client'

require_relative 'collectors/tweets'

# Show welcome! :D
$logger.welcome
$logger.seed_info
$logger.elastic_status

#tweets = Tweets.new('laux_es')
#data = tweets.get

#binding.pry
$logger.out
