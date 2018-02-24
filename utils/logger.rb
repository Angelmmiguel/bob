require 'rainbow'
require 'terminal-table'

# Logger!
class Logger
  # Globals
  SECONDS_IN_MONTH = 2_592_000

  # Singleton instance
  @@instance = Logger.new

  def self.instance
    @@instance
  end

  # Bob welcome with Ascii art included :D
  def welcome
    ascii_art = <<EOF

        <----->
       <  (0)  >         My is BOB (Bot of Bots)
       |   -   |          I'm here to find bots in Twitter!
      < ------- >
      o         o         https://github.com/Angelmmiguel/bob
      o  B o B  o
     o           o
   o o o o o o o o o
   o l l l l l l l o
   o o o o o o o o o
EOF
    # Display it
    puts Rainbow(ascii_art).magenta
  end

  # Elastic status
  def elastic_status
    title("Elastic health")
    status = $clients.elasticsearch.cluster.health
    puts "Name: \t\t#{status['cluster_name']}"
    puts "Status: \t#{Rainbow(status['status']).green}"
    puts "Nodes: \t\t#{status['number_of_nodes']}"
    puts "Active shards: \t#{status['active_shards_percent_as_number']}%"
  end

  # Finish
  def exporting_data
    title 'Exporting data'
  end

  def out
    puts "\n#{Rainbow('Bye bye human!').magenta}"
  end

  # Generic
  # -----------------------

  def title(text)
    puts "\n" + Rainbow(text).cyan + "\n" + separator
  end

  def linebreak
    puts "\n"
  end

  # Separator
  def separator
    "----------------"
  end

  def too_many_requests
    puts "\n#{Rainbow('Too many requests to the Twitter API, please wait a bit 🐦').magenta}\n"
  end

  def user_not_found(user)
    puts "\nSorry, but the user #{Rainbow('user').magenta.bold} does not exist 😱\n"
  end

  def percent(text, value, total)
    res = "\n#{text}\t #{Rainbow(value).bold} / #{Rainbow(total).bold} "
    res += Rainbow("(#{((value.to_f / total) * 100).ceil} %)").bold.magenta
    puts res
  end

  # Operations
  # -----------------------

  def remaining_operations(num)
    puts "\nRemaining operations: \t#{Rainbow(num.to_s).green}"
  end

  def start_operation(name)
    puts "\nStarting: \t#{Rainbow(name).green}"
  end

  def operation_result(result)
    puts "Results:"
    puts result
  end

  # Models
  # -----------------------

  def current(text)
    puts "\n#{Rainbow(text).cyan.bold}"
  end

  def profile(user)
    linebreak
    data = [
      ["Name\t", user[:name]],
      ['Username', user[:screen_name]],
      ["URL\t", "https://twitter.com/#{user[:screen_name]}"],
      ['Joined in', Time.parse(user[:created_at]).strftime('%m / %Y')],
      ['Location', user[:location]],
      ['Description', user[:description]],
      ["Tweets\t", user[:statuses_count]],
      ['Followers', user[:followers_count]],
      ['Following', user[:friends_count]]
    ]

    data.each { |d| puts "#{Rainbow(d.first).bold} \t#{d.last}"}
  end

  def users(users, store)
    head = ['Username', 'Joined', 'Tweets', 'Followers', 'Following', 'Followed by', 'Also following'].map { |str| Rainbow(str).bold }
    result = [head]
    result << :separator
    users.each do |user|
      followed_by = store.users_following(user)
      also_following = store.users_followed_by(user)
      t = Time.parse(user[:created_at])
      date = (Time.now - 3 * SECONDS_IN_MONTH < t) ? Rainbow(t.strftime('%d / %m / %Y')).red.bold : t.strftime('%d / %m / %Y')
      result << [
        user[:screen_name],
        date,
        user[:statuses_count],
        user[:followers_count],
        user[:friends_count],
        followed_by.size > 0 ? Rainbow(followed_by.map { |u| u[:screen_name]}.join(', ')).magenta.bold : '-',
        also_following.size > 0 ? Rainbow(also_following.map { |u| u[:screen_name]}.join(', ')).magenta.bold : '-'
      ]
    end
    # Display as a table
    puts Terminal::Table.new rows: result
    linebreak
  end

  def tweets(tweets)
    head = ['Text', 'Retweets', 'Favs', 'Hashtags', 'Tweeted at'].map { |str| Rainbow(str).bold }
    result = [head]
    result << :separator
    tweets.each do |tweet|
      text = tweet[:text]
      if text.size > 60
        splitted = text.split(' ')
        text = [splitted[0..(splitted.size / 2).ceil].join(' '), splitted[((splitted.size / 2).ceil + 1)..-1].join(' ')]
      end
      Array(text).each_with_index do |t, i|
        result << [
          t,
          i == 0 ? tweet[:retweet_count] : '',
          i == 0 ? tweet[:favorite_count] : '',
          i == 0 ? tweet[:entities][:hashtags].map { |h| h[:text] } : '',
          i == 0 ? Time.parse(tweet[:created_at]).strftime('%d / %m / %Y') : ''
        ]
      end
      result << :separator
    end

    # Display as a table
    puts Terminal::Table.new rows: result
    linebreak
  end

  # Make new private!
  private_class_method :new
end

# Load config as global
$logger = Logger.instance
