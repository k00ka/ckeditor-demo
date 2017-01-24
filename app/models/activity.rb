class Activity < ActiveRecord::Base
  belongs_to :activity_definition
  attr_accessible :responses, :activity_definition_id
  serialize :responses

end
