require 'thread'

# Coordinate and execute operations
class OperationManager
  extend Forwardable
  def_delegators :queue, :<<, :push, :pop, :num_waiting, :size

  # Queue of operations!
  attr_reader :queue

  def initialize
    @queue = Queue.new
  end

  def start
    while(!empty?)
      $logger.remaining_operations(size)
      # Start operation
      operation = queue.pop
      $logger.start_operation(operation.name)
      operation.perform
      # Get results
      $logger.operation_result(operation.result)
    end
  end

  def empty?
    size == 0
  end

  # Singleton instance
  @@instance = OperationManager.new

  def self.instance
    @@instance
  end

  # Make new private!
  private_class_method :new
end
