class User
  attr_reader :username, :profile

  def initialize(username, store)
    @username = username
    @store = store
    # Get the user
    @profile = $clients.twitter.user(username).to_h

    if @store.users.key? @profile[:id]
      @followers = @store.users[@profile[:id]][:followers_data]
      @following = @store.users[@profile[:id]][:following_data]
    else
      @store.store_user(@profile)
    end

    @store.current = @profile[:id].to_s
  end

  def followers(limit: 24)
    return @followers if @followers && @followers.count >= limit
    followers = $clients.twitter.followers(username)
    @followers = []
    total = 0
    followers.each do |follower|
      @followers << follower.to_h
      total += 1
      break if total >= limit
    end
    @store.store_followers(@profile, @followers)
    @followers
  end

  def following(limit: 24)
    return @following if @following && @following.count >= limit
    following = $clients.twitter.friends(username)
    @following = []
    total = 0
    following.each do |friend|
      @following << friend.to_h
      total += 1
      break if total >= limit
    end
    @store.store_following(@profile, @following)
    @following
  end

  def timeline(limit: 200, retweets: false)
    return @timeline if @timeline && @timeline.count >= limit
    tweets = $clients.twitter.user_timeline(username, count: limit, include_rts: retweets)
    @tweets = []
    tweets.each do |tweet|
      @tweets << tweet.to_h
    end
    @store.store_tweets(@tweets)
    @tweets
  end
end
