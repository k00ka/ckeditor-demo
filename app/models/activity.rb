class Activity < ActiveRecord::Base
  belongs_to :activity_definition
  attr_accessible :responses, :activity_definition_id
  serialize :responses

  def activity_html
    tags = self.activity_definition.html_blob.split("<")
    tags.shift
    outputString = ""

    tags.each do | tag |
      if tag.include? "input"
        name = tag.match(/.*name="([^"]*)".*/)[1]
        output = tag.gsub(/\sname="[^"]*"/, " name=\"activity[responses][#{name}]\"").gsub(/\svalue="[^"]*"/, " value=\"#{self.responses[name] rescue nil}\"")
        outputString += "<" + output
      else
        outputString += "<" + tag
      end
    end
    outputString
  end
end
