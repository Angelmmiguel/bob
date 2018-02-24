require 'yaml'

# Inicialize the config of the project.
class Config
  attr_reader :twitter, :elasticsearch

  def initialize
    %w(twitter elasticsearch).each do |config|
      path = File.join(__dir__, "../config/#{config}.yml")
      instance_variable_set("@#{config}", YAML::load_file(path))
    end
  end

  # Singleton instance
  @@instance = Config.new

  def self.instance
    @@instance
  end

  # Make new private!
  private_class_method :new
end

# Load config as global
$config = Config.instance
