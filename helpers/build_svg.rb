def buildSvg(json, grid_data, width, height, scale, fn, maxmag)
  require 'rasem'
  epoch = (Time.now.to_f * 1000).to_i
  backgroundColor = "#00008A"
  ## Define Colors of elements
  backgroundColor = "#000000" #"#00008A"
  gridColor = "#a9a9a9"
  gridWidth = "1.25"
  gridStyle = ""
  boundryColor = "#15bb00"
  boundryWidth = "1.75"
  boundryStyle = "4,4,4,4"
  milkyColor = "#a9a9a9"
  constColor = "#a5a1a1" #"#f5f5f5"
  constWidth = "1.75"
  constStyle = ""
  eclipticStyle = "4,4,4,4"
  eclipticColor = "#a9a9a9"
  eclipticWidth = "1.0" 
  starColor     = "#fff"
  objectColor      = "#fff"
  objSize       = "10"
  objectLabelFontSize = "12px"
  ngcObjectLabelFontSize = "10px"
  ngcObjectColor    = "#a9a9a9"
  starScale     = 1.5
  starLabelColor    = "#fff"
  starLabelFontSize = "12px"
  legendColor   = "#000"
  legendFontSize = "15px"
  labelData = []
  labels = open("datasets/labels.csv"){ |f| f.read }
  labels.each_line do |l|
    labelData << l
  end
  lines = JSON.parse(json)
  grid  = JSON.parse(grid_data)
  File.open("public/image/#{fn}.svg", "w") do |f|
    Rasem::SVGImage.new(width,height, f) do |f|
      rectangle 0,0,width,height, :fill=>backgroundColor
      i = 0
      while i < lines.count
        type = lines[i]["t"]
        case type
        when "Star"
          x = lines[i]["x"]
          y = lines[i]["y"]
          mag = lines[i]["mag"]
          label = lines[i]["label"]          
          rad = 0
          w   = 0
          if mag < 0.20 
            rad = 4.75
            w = 5
          end
          if mag > 0.20 && mag < 1
            rad = 4.0
            w = 5
          end
          if mag > 1.0 && mag < 1.50
            rad = 3.5
            w = 4
          end
          if mag > 1.50 && mag < 2
            rad = 3.0
          end
          if mag > 2 && mag < 2.5
            rad = 2.3
          end
          if mag > 2.5 && mag < 3
            rad = 1.8
          end
          if mag > 3 && mag < 3.5
            rad = 1.25 
          end
          if mag > 3.5 && mag < 4
            rad = 0.75
          end
          if mag > 4.0 && mag < 4.5 
            rad = 0.6
          end
          if mag > 4.5 && mag <5.5 
            rad = 0.45 
          end
          if mag > 5.5 && mag < 6.5
            rad = 0.35 
          end
          if mag > 6.5
            rad = 0.15
          end
          if mag < maxmag.to_f
            circle x,y,rad*starScale, :stroke=>starColor, :fill=>starColor
          end
          if mag < 3
            lx,ly = labeloffset(labelData,lines[i]["label"])
            offset = 3
            if lx == "end"
              offset = -10
            end
            yoffset = 0
            if ly == "hanging"
              yoffset =20 
            end
            label = translate(label)
            text x+(rad+offset), y-(rad+3)+yoffset, label,:text_anchor=>lx, :dominant_baseline=>ly, :fill=>starLabelColor, :font_size=>starLabelFontSize, :font_family=>"sans-serif"
          end
        when "tick"
          # Insert 
        when "m"
          rad = 4 - (4 * scale)
          alpha =lines[i]["grey"].to_f/1000 
          circle lines[i]["x"],lines[i]["y"],rad, :fill=>milkyColor, :opacity=>alpha 
        when "line"
          pos  = lines[i]["pos"]
          x1 = pos.split(",")[0]
          y1 = pos.split(",")[1]
          g = lines[i]["g"]
          if pos != "new"
            if lines[i+1]["pos"] != "new"
              pos2 = lines[i+1]["pos"].split(",")
              x2 = pos2[0]
              y2 = pos2[1]
              # Default Line Color
              linecolor = "#fff"
              linewidth = "1.0"
              linestyle = ""
              case g
              when "1" # Grid LInes
                linecolor = gridColor
                linewidth = gridWidth
              when "2"
                linecolor = gridColor
                linewidth = gridWidth
              when "3"  # Ecliptic LIne
                linecolor = eclipticColor
                linewidth = eclipticWidth
                linestyle = eclipticStyle
              when "4" # Boundry Lines
                linecolor = boundryColor
                linewidth = boundryWidth
                linestyle = boundryStyle
              else # Constellation Lines
                linecolor = constColor
                linewidth = constWidth
              end
               line x1,y1,x2,y2, :stroke=>linecolor, :stroke_width=>linewidth, :stroke_dasharray=>linestyle
            end
          end
        else
          rad = 4 * starScale
          if lines[i]["mag"] < 10 
            if type == "Galaxy"
              ellipse lines[i]["x"],lines[1]["y"],rad*2,rad,:fill=>"none", :stroke=>objectColor, :stroke_width=>"1.0"
            else
              circle lines[i]["x"],lines[i]["y"],rad, :fill=>"none", :stroke=>objectColor, :stroke_width=>"1.0" 
            end
            lx,ly = labeloffset(labelData,lines[i]["label"])          
            offset = 3
            if lx == "end"
              offset = -10
            end
            yoffset = 0
            if ly == "hanging"
              yoffset = 20
            end
            if lines[i]["label"] =~/NGC/
              text lines[i]["x"]+(rad+offset),lines[i]["y"]-(rad), lines[i]["label"], :text_anchor=>lx, :dominant_baseline=>ly, :fill=>ngcObjectColor, :font_size=>ngcObjectLabelFontSize
            else
              text lines[i]["x"]+(rad+offset),lines[i]["y"]-(rad), lines[i]["label"], :text_anchor=>lx, :dominant_baseline=>ly, :fill=>objectColor, :font_size=>objectLabelFontSize
            end
          end
        end
        i=i+1
      end
      rectangle 0,0,width,height, :stroke_width=>"75", :stroke=>"#fff",:fill_opacity=>"0.0", :stroke_opacity=>"1.0"
      i=0
      while i < grid.count
        if grid[i]["t"] == "tick"
          pos  = grid[i]["pos"]
          x1 = pos.split(",")[0]
          y1 = pos.split(",")[1]
          if grid[i]["g"] == "dec" and y1.to_i > 15 and y1.to_i < height-15
            text 5,y1, grid[i]["d"], :fill=>legendColor, :text_anchor=>"start", :dominant_baseline=>ly, :font_size=>legendFontSize, :font_family=>"sans-serif"
          end
          if grid[i]["g"] == "ra" and x1.to_i > 15 and x1.to_i < width-15
            text x1,25, grid[i]["d"], :fill=>legendColor, :text_anchor=>"middle", :alignment_baseline=>"hanging", :font_size=>legendFontSize, :font_family=>"sans-serif"
          end
        end
        
        i=i+1
      end
    end
  end
  puts "Writing SVG to s3"
  s3 = AWS::S3.new
  b = s3.buckets['fuzzy-lana']
  o = b.objects["#{fn}.svg"]
  o.write(:file => "public/image/#{fn}.svg")
  o.acl = :public_read
  convrt = convertMapLocal(fn,"png")
  puts "Debug: ending build_svg"
  return "{\"map\":\"#{fn}\"}"
end

def checkmap(name)
  s3 = AWS::S3.new
  puts "Checking for existing map #{name}"
  if s3.buckets['fuzzy-lana'].objects["#{name}.svg"].exists?
    return true
  end
  return false
end

def labeloffset(labelData, label)
  x = "start"
  y = "auto"
  if label !=""
    labelData.each do |l|
      if label == l.split(",")[0]
        x = l.split(",")[1]
        y = l.split(",")[2]
        break
      end
    end
  end
  return x,y.chomp
end

def translate(label)
  label = label.gsub("Alp","\u0391")
  label = label.gsub("Bet","\u0392")
  label = label.gsub("Gam","\u0393")
  label = label.gsub("Eps","\u0395")
  label = label.gsub("The","\u0398")
  label = label.gsub("Zet","\u0396")
  label = label.gsub("Del","\u0394")
  label = label.gsub("Mu","\u039C")
  label = label.gsub("Nu","\u039D")
  label = label.gsub("Pi","\u03A0")
  label = label.gsub("Lam","\u039B")
  label = label.gsub("Rho","\u03A1")
  label = label.gsub("Iot","\u0399")
  label = label.gsub("Eta","\u0397")
  label = label.gsub("Kap","\u039A")
  return label
end

