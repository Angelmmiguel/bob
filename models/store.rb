require 'json'

class Store
  attr_reader :users, :tweets, :hashtags
  attr_accessor :current

  def initialize(load: nil)
    if load.nil?
      # Store them by id :)
      @users = {}
      @tweets = {}
      @hashtags = {}
    else
      data = JSON.parse(File.read(load), symbolize_names: true)
      @users = data[:users]
      @tweets = data[:tweets]
      @hashtags = data[:hashtags]
    end
  end

  def store_user(user)
    return if @users.key? user[:id]
    @users[user[:id]] = user
    @users[user[:id]][:followers_data] = []
    @users[user[:id]][:following_data] = []
    @users[user[:id]][:tweets_data] = []
  end

  def store_followers(user, followers)
    store_user(user) unless @users.key? user[:id]
    followers.each do |follower|
      next if @users[user[:id]][:followers_data].include? follower[:id]
      @users[user[:id]][:followers_data] << follower[:id]
      store_user(follower)
    end
  end

  def store_following(user, following)
    store_user(user) unless @users.key? user[:id]
    following.each do |friend|
      next if @users[user[:id]][:following_data].include? friend[:id]
      @users[user[:id]][:following_data] << friend[:id]
      store_user(friend)
    end
  end

  def store_tweets(tweets)
    tweets.each do |tweet|
      u = tweet[:user]
      store_user(u)
      @users[tweet[:user][:id]][:tweets_data] << tweet[:id]
      tweet[:user] = u[:id]
      @tweets[tweet[:id]] = tweet
      if tweet[:entities][:hashtags].size > 0
        tweet[:entities][:hashtags].each do |hash|
          @hashtags[hash[:text]] ||= []
          @hashtags << {
            user: u,
            tweet: tweet[:id]
          }
        end
      end
    end
  end

  def users_following(user)
    @users.select { |k, u| k.to_s != current && u[:following_data].include?(user[:id]) }.values
  end

  def users_followed_by(user)
    @users.select { |k, u| k.to_s != current && u[:followers_data].include?(user[:id]) }.values
  end

  def users_following_or_followed_by(user)
    @users.select { |k, u| k.to_s != current && u[:followers_data].include?(user[:id]) || u[:following_data].include?(user[:id]) }.values
  end

  def created_in_last(seconds)
    time_from_now = Time.now - seconds
    @users.select { |_, u| time_from_now < Time.parse(u[:created_at]) }.values.sort_by { |u| -Time.parse(u[:created_at]).to_i }
  end

  def export
    export_data = {
      users: users,
      tweets: tweets,
      hashtags: hashtags
    }
    File.open("data/output.json","w") do |f|
      f.write(export_data.to_json)
    end
  end
end
