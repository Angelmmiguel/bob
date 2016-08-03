# Main script. It requires all dependencies and run the project
require 'pry'
require 'pry-nav'
require 'twitter'

# Utils
require_relative 'utils/logger'

# Models
require_relative 'models/config'
require_relative 'models/client'
require_relative 'models/seed'

# Operations
require_relative 'operations/operation'
require_relative 'operations/operation_manager'
require_relative 'operations/fetch/hashtag_tweets'
require_relative 'operations/fetch/user_tweets'

# Show welcome! :D
$logger.welcome
$logger.seed_info
$logger.elastic_status

# Load operations
manager = OperationManager.instance

# Load from seed
$seed.accounts.each do |account|
  operation = UserTweets.new account
  manager << operation
end

$seed.hashtags.each do |hashtag|
  operation = HashtagsTweets.new hashtag
  manager << operation
end

# Run!
manager.start

#binding.pry

$logger.out
