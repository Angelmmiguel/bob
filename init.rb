# Main script. It requires all dependencies and run the project
require 'pry'
require 'pry-nav'
require 'twitter'
require 'tty-prompt'
require 'tty-spinner'

# Utils
require_relative 'utils/logger'

# Models
require_relative 'models/config'
require_relative 'models/client'
require_relative 'models/user'
require_relative 'models/store'

# Operations
require_relative 'operations/operation'
require_relative 'operations/operation_manager'
require_relative 'operations/fetch/hashtag_tweets'
require_relative 'operations/fetch/user_tweets'

# Show welcome! :D
$logger.welcome

# Prompt
prompt = TTY::Prompt.new
spinner = TTY::Spinner.new

# Load operations
manager = OperationManager.instance

# Connect to elasticsearch
$logger.title('Connecting to ElasticSearch')
spinner.auto_spin
connected = $clients.wait_for_elastic_search
if connected
  spinner.stop('Connected!')
else
  spinner.stop('Error connecting elasticsearch')
  exit 1
end

$logger.linebreak

store = if File.exists? 'data/output.json'
          res = prompt.yes?('We detected stored data. Do you want to load it?')
          res ? Store.new(load: 'data/output.json') : Store.new
        else
          # Store :D
          Store.new
        end

begin
  loop do
    type = prompt.select("Main menu", %w(User Hashtag Query Exit))

    begin
      case type
      when 'User'
        username = prompt.ask("Tell me the username you want to investigate")
        user = User.new(username, store)
        loop do
          $logger.current(user.username)
          action = prompt.select("Select the action to perform", ['Profile', 'Timeline', 'Followers', 'Following', 'Back'])
          # Perform operations
          case action
          when 'Profile'
            $logger.profile user.profile
          when 'Timeline'
            limit = prompt.ask("How many? (Max 800)", convert: :int, default: 100)
            $logger.tweets user.timeline(limit: limit)
          when 'Following'
            limit = prompt.ask("How many?", convert: :int, default: 24)
            $logger.users(user.following(limit: limit), store)
          when 'Followers'
            limit = prompt.ask("How many?", convert: :int, default: 24)
            $logger.users(user.followers(limit: limit), store)
          when 'Back'
            $logger.linebreak
            break
          end
        end
      when 'Query'
        loop do
          action = prompt.select("Select the action to perform", ['Users created in the last 3 months', 'Back'])
          case action
          when 'Users created in the last 3 months'
            users = store.created_in_last(3 * Logger::SECONDS_IN_MONTH)
            $logger.percent('Users:', users.count, store.users.count)
            $logger.users(users, store)
          when 'Back'
            $logger.linebreak
            break
          end
        end
      when 'Exit'
        break
      end
    rescue Twitter::Error::NotFound
      $logger.user_not_found(username)
    rescue Twitter::Error::TooManyRequests
      $logger.too_many_requests
    end
  end
rescue TTY::Prompt::Reader::InputInterrupt
  # Handle interrupt
end

$logger.exporting_data
spinner.auto_spin
store.export
spinner.stop('Done!')

$logger.out

# Run!
# manager.start

