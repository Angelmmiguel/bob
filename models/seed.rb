require 'yaml'

# Inicialize the config of the project.
class Seed
  attr_reader :accounts, :hashtags

  def initialize
    path = File.join(__dir__, '../config/seed.yml')
    config = YAML::load_file(path)
    # Initialize
    @accounts = config['accounts']
    @hashtags = config['hashtags']
  end

  # Singleton instance
  @@instance = Seed.new

  def self.instance
    @@instance
  end

  # Make new private!
  private_class_method :new
end

# Load config as global
$seed = Seed.instance
