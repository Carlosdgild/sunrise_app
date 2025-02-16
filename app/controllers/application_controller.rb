# frozen_string_literal: true

class ApplicationController < ActionController::API
  include Jsonable
  include Errorable
end
