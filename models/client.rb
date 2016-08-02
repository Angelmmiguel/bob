require 'twitter'
require 'elasticsearch'

# Singleton class for twitter client
class Clients
  # Singleton instance
  attr_reader :twitter, :elasticsearch

  def initialize
    @twitter = Twitter::REST::Client.new do |config|
      config.consumer_key        = $config.twitter['key']
      config.consumer_secret     = $config.twitter['secret']
      config.access_token        = $config.twitter['token']
      config.access_token_secret = $config.twitter['token_secret']
    end

    @elasticsearch = Elasticsearch::Client.new(
      host: "#{$config.elasticsearch['host']}:#{$config.elasticsearch['port']}")
  end

  @@instance = Clients.new

  def self.instance
    @@instance
  end

  # Make new private!
  private_class_method :new
end

$clients = Clients.instance
