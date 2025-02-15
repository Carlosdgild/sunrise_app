# frozen_string_literal: true

# +ApplicationJob+ abstract definition
class ApplicationRecord < ActiveRecord::Base
  primary_abstract_class
end
