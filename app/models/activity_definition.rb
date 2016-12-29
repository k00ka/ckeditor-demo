class ActivityDefinition < ActiveRecord::Base
  attr_accessible :html_blob

  def name
    self.html_blob.gsub(/<[^>]*>/, " ").slice(0..20)
  end
end
