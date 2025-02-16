# frozen_string_literal: true

# CustomStandardError
class CustomStandardError < StandardError
  attr_reader :message, :status

  def initialize(message = 'Something went wrong', status = :internal_server_error)
    @message = message
    @status = status
    super(message)
  end
end
