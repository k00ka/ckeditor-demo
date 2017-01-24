module ActivitiesHelper
  def activity_html(activity)
    return activity.activity_definition.html_blob
    tags = activity.activity_definition.html_blob.split("<")
    output = ""
    #capture do
      output += tags.shift
      tags.each do |tag|
        output += "<#{tag}" and next unless tag.split(" ").first == "input"
        name = tag.match(/.*name="([^"]*)".*/)[1]
        value = activity.responses[name] || ""
        the_rest = tag.sub(/input/,"").sub(/ name="[^"]*"/, "").sub(/ value="[^"]*"/, "")
        output += "<input name=\"activity[responses][#{name}]\" value=\"#{value}\" #{the_rest}"
      end
    #end
    output
  end
end
