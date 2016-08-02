require 'rainbow'

# Logger!
class Logger
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

  # Seed info
  def seed_info
    puts title("Your seed")
    puts "Accouts: \t#{Rainbow($config.seed['accounts'].join).green}"
    puts "Hashtags: \t#{Rainbow($config.seed['hashtags'].join).green}"
  end

  # Elastic status
  def elastic_status
    puts title("Elastic health")
    status = $clients.elasticsearch.cluster.health
    puts "Name: \t\t#{status['cluster_name']}"
    puts "Status: \t#{Rainbow(status['status']).green}"
    puts "Nodes: \t\t#{status['number_of_nodes']}"
    puts "Active shards: \t#{status['active_shards_percent_as_number']}%"
  end

  # Separator
  def separator
    "----------------"
  end

  # Finish
  def out
    puts "\n#{Rainbow('Bye bye human!').magenta}"
  end

  # Make new private!
  private_class_method :new

  private

  def title(text)
    "\n" + Rainbow(text).cyan + "\n" + separator
  end
end

# Load config as global
$logger = Logger.instance
