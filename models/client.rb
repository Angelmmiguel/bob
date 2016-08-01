require 'twitter'

# Singleton class for twitter client
class Client
  # Singleton instance
  @@instance = Twitter::REST::Client.new do |config|
    config.consumer_key        = CONFIG.twitter['key']
    config.consumer_secret     = CONFIG.twitter['secret']
    config.access_token        = CONFIG.twitter['token']
    config.access_token_secret = CONFIG.twitter['token_secret']
  end

  def self.instance
    @@instance
  end

  # Make new private!
  private_class_method :new
end
