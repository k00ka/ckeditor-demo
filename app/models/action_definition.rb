class ActionDefinition < ActiveRecord::Base
  belongs_to :organization
  has_many :actions, inverse_of: :action_definition, dependent: :destroy
  attr_accessible :html_blob, :level, :organization_id, :hide_from_mentor
  scope :mentor_visible, -> { where(hide_from_mentor: false) }
end
