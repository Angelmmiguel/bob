# Get tweets from a search or an user
class Tweets
  # Readers
  attr_reader :source, :is_hashtag

  # Initialize the class with an account or hashtag
  def initialize(source, is_hashtag: false)
    @source = source
    @is_hashtag = is_hashtag
  end

  # Get the tweets from the source
  def get
    is_hashtag ? read_hashtag : read_user
  end

  private

  # Get tweets from user
  def read_user
    Client.instance.user_timeline(source)
  end

  # Get tweets from hashtag
  def read_hashtag

  end
end
