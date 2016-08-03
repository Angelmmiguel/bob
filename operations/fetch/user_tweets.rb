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
