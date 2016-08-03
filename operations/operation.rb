#
# Basic operation class. It defines the interface and the common methods.
#
class Operation
  #
  # All operations must include a perform method. This method will be executed
  # by the main program.
  #
  def perform
    raise 'This method must be defined'
  end
end
