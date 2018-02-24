require 'rainbow'
require 'terminal-table'

#
# Fetch tweets from an user
#
class UserTweets < Operation
  # Get the user and the parameters
  def initialize(user)
    @user = user
  end

  def name
    "Fetch tweets of #{@user}"
  end

  # Fetch the data and index it to elastic search
  def perform
    tweets = $clients.twitter.user_timeline(@user)
    @num_tweets = tweets.size

    # Detect new entrypoints
    non_retweets = tweets.select { |t| !t.retweet? }
    hashtags = non_retweets.map(&:hashtags).flatten.group_by(&:text)
    users = non_retweets.map(&:user_mentions).flatten.group_by(&:screen_name)
    urls = non_retweets.map(&:urls).flatten.group_by { |u| u.url.to_s }

    # Index tweets
    tweets.each do |tweet|
      $clients.elasticsearch.index(
        index: 'tweets',
        type: 'tweet',
        id: tweet.id,
        body: tweet.to_h)
    end
  end

  def result
    "New #{@num_tweets} tweets from #{@user}!"
  end
end
