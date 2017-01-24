class Action < ActiveRecord::Base
  belongs_to :action_definition, inverse_of: :actions
  belongs_to :relationship, inverse_of: :actions
  attr_accessible :responses, :action_definition_id, :relationship_id
  serialize :responses
end
