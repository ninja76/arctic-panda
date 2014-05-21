helpers do
  def meta
      html="<meta charset=\"utf-8\" /><meta name=\"viewport\" content=\"width=device-width, initial-scale=1.0, minimum-scale=1.0\"/>\n"
      html << "<meta name=\"description\"content=\"#{settings.desc}\"  />\n" if settings.desc
      html << "<meta name=\"author\" content=\"#{settings.author}\" />\n" if settings.author
  end

  #Define js resources
  def javascripts
    settings.js.flatten.uniq.map do |script|
      "<script src=\"#{script}\"></script>\n"
    end.join
  end

  #Define CSS resources
  def styles
        settings.css.flatten.uniq.map do |stylesheet| 
          "<link href=\"#{stylesheet}\" media=\"screen, projection\" rel=\"stylesheet\" />\n"
        end.join    
    end
end
