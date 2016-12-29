class ActivityDefinition < ActiveRecord::Base
  attr_accessible :html_blob

  def short_description
    self.html_blob.gsub(/<[^>]*>/, " ").slice(0..20)
  end
end
