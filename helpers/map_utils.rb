def buildGridData(scale, c_ra, c_dec, width, height)
  m_PI = 3.141592653589793
  m_PI_2 = m_PI / 2
  output = []
  scans_per_cm= 20 
  point_distance= 5.0
  scans_per_fullcircle = scans_per_cm/scale*2.0*m_PI;
  steps = ((point_distance*m_PI/180.0)*(scans_per_fullcircle/(2.0*m_PI)))+2;
  within_curve = false;
  matrix,smatrix = local_transform(c_ra,c_dec,scale)
  declination = -80
  mark = ''
  tick_output = []
  while declination < 90
    number_of_points= Math.cos(declination*m_PI/180.0)*scans_per_fullcircle
    i = 0 
    while i < number_of_points  
      ra = i/number_of_points*24.0
      x,y,z = polar_transform(ra,declination, matrix, smatrix, width, height)
      if z > 0.0
        entry = "#{x.to_i},#{y.to_i}"
        output <<  {:pos => entry,:t =>"line",:g =>"1"}
        if x.to_i < 0 and mark == ''
          puts "Mark: #{declination}, #{x}, #{y}"
          entry = "0,#{y.to_i}" 
          tick_output <<  {:pos => entry,:t =>"tick",:g =>"dec", :d => "%02d" % declination}
          mark = "found"
        end
      else
        output << {:pos => 'new', :t =>"line"}
      end
      i = i +1
    end
    mark = ''
    output << {:pos => 'new', :t =>"line"} 
    declination = declination+10
  end
  rectascension = 0 
  while rectascension < 24 
    number_of_points= scans_per_fullcircle/2.0;
    i = 0
    while i < number_of_points
      dec = i/number_of_points*160.0-80.0
      x,y,z = polar_transform(rectascension,dec, matrix, smatrix, width, height)
      if z >  0.0
        entry = "#{x.to_i},#{y.to_i}"
        output <<  {:pos => entry,:t =>"line",:g =>"1"}
      else
        output << {:pos => 'new', :t =>"line"}
      end
      if y.to_i < 0 and y.to_i > -10.0 and mark == '' and z > 0.0
          puts "Mark: RA #{rectascension}, #{x}, #{y}, #{z}"
          entry = "#{x.to_i},0" 
          tick_output <<  {:pos => entry,:t =>"tick",:g =>"ra", :d => "%02d" % rectascension}
          mark = "found"
        end
      i = i +1
    end
    mark = ''
    output << {:pos => 'new', :t =>"line"}
    rectascension = rectascension +1   
  end
  return output + tick_output
end

def buildMapData (objects, scale, rectascension, declination, width, height, isgrid, iscline, isboundry, ismilky, mag)
  # First check if a map already exists with the specified parameters
  ## build file name
  scale = sprintf('%.2f', scale)
  mag = sprintf('%.1f', mag)
  fn = "#{rectascension.to_i}#{declination.to_i}#{iscline}#{ismilky}#{isboundry}#{scale}#{mag}#{isgrid}"
  fn = fn.gsub('.','_')
  if checkmap(fn) == true
    puts "Map found in Cache! #{fn}"
    return "{\"map\":\"#{fn}\"}"
  end
  puts "New map requested"
  scale = scale.to_f
  output = []
  width =  width.to_i 
  height = height.to_i
  avgX = 0
  avgY = 0
  centerX = -0 
  centerY = -0 
  m_PI = 3.141592653589793
  m_PI_2 = m_PI / 2 
  dbl_EPSILON = 2.2204460492503131
  rectascension = rectascension.to_f 
  declination = declination.to_f 
  grad_per_cm = scale.to_f #0.05
  matrix,smatrix = local_transform(rectascension,declination,grad_per_cm)
  objects = objects.to_a
   objects.each do |key|
     if key[:ra]
       x,y,z = polar_transform(key[:ra],key[:dec], matrix, smatrix, width, height)
       m  = key[:mag].to_f
       b  = key[:bayer]
       n  = key[:name]
       f  = key[:flamsteed]
       c  = key[:ccode]
       h  = key[:hd]
       t  = key[:type]
       m2  = key[:mes]
       label = ""
       label = b
       if n
         label = n
       end
       if !n
         label = b
       end
       if m2 != " " 
         label = m2
       end
       if x < width+200 and y < height+200 and x > 0-200 and y > 0-200 and z > -0.00 
         output  << {:x => x.to_i, :y => y.to_i, :mag => m, :label => label, :f => f, :c => c, :t => t, :h => h} 
       end
     end
   end
     grid_data = []
     line_data = []
     mway_data = []
     ecliptic_data = []
     boundry_data = []
     if isgrid == "1"
       grid_data = buildGridData(scale,rectascension,declination,width,height)
     end
     if iscline == "1"
       line_data = constellation_lines(output.to_json)
     end
     ecliptic_data = buildEcliptic(rectascension,declination,scale,width,height)
     if ismilky == "1"
       mway_data = buildMilkyWay(rectascension,declination,scale,width,height)
     end
     #scale_data = buildScaleData(rectascension,declination,scale,width,height)
     if isboundry == "1"
       boundry_data = constellation_boundry(rectascension,declination,scale,width,height)
     end
     all_data = mway_data + ecliptic_data + grid_data + line_data + boundry_data + output
     ## Send data to get converted into a Map/SVG
     map = buildSvg(all_data.to_json, grid_data.to_json, width, height, scale, fn, mag)
     map
end

def constellation_boundry(rectascension,declination,scale,width,height)
  boundries = []
  matrix,smatrix = local_transform(rectascension,declination,scale)
  import = "datasets/constbnd.dat"
  lines = open(import){ |f| f.read }
  cc = 0
  star = ""
  lines.each_line do |l|
    data = l.split(" ")
    ra = data[0]
    dec = data[1]
    c1  = data[2]
    if !data[3]
      boundries << {:pos => 'new', :t =>"line", :g =>"4"}
    end
    x,y,z = polar_transform(ra.to_f,dec.to_f, matrix, smatrix, width, height)
    if z > -0.10 
      entry = "#{x.to_i},#{y.to_i}"
      boundries << {:pos => entry,:t => "line",:g => "4"}
    else
      boundries << {:pos => 'new', :t =>"line", :g =>"4"}
    end
  end
  boundries << {:pos => 'new', :t =>"line", :g =>"4"}
  boundries
end

def constellation_lines(map_objects)
  importfile = "data/constellations/lines2.json"
  c_lines = []
  mo = JSON.parse(map_objects)
  found = false
  puts "opening file"
  if File.file?(importfile)
    puts "parsing data"
    json = File.read(importfile)
    lines = JSON.parse(json)
    lines.each_value do |value|
      hd = ""
      value.each do |l|
        stars = l[1].split(',')
        stars.each do |s|
          hd = ""
          derp = s.split(" ")
          constellation = derp[0]
          num = derp[1]
          if num
            if num[0,2] == "HD"
              hd = num
              hd[0] = ''
              hd[0] = ''
            end
          end
          mo.each do |o|
            if o["t"] == "Star" and o["f"] == num and constellation.casecmp(o["c"]) == 0
              entry = "#{o["x"]},#{o["y"]}"
              c_lines << {:pos => entry,:t =>"line", :g =>"0"}
     	      break
 	    end
            if hd == o["h"]
              entry = "#{o["x"]},#{o["y"]}"
              c_lines << {:pos => entry,:t =>"line"}
              break
            end 
          end              
        end
        c_lines << {:pos => 'new', :t =>"line", :g =>"0"}
      end
    end
  end
  c_lines
end

def buildEcliptic(rectascension,declination,scale,width,height)
  output = []
  m_PI = 3.141592653589793
  epsilon= 23.44*m_PI/180.0;
  scans_per_cm= 10
  point_distance= 5.0
  scans_per_fullcircle = scans_per_cm/scale*2.0*m_PI;
  matrix,smatrix = local_transform(rectascension,declination,scale)
  number_of_points= scans_per_fullcircle
  within_curve= false;
  i=0
  while i < number_of_points
    phi0= i/number_of_points*2.0*m_PI;
    m_sin_phi0= -Math.sin(phi0);
    phi= Math.atan2(m_sin_phi0*Math.cos(epsilon),Math.cos(phi0));
    delta= Math.asin(m_sin_phi0*Math.sin(epsilon));
    x,y,z = polar_transform(phi*12.0/m_PI,delta*180.0/m_PI, matrix, smatrix, width, height)
    if x > 0 and y < height and x < width and y > 0 and z > 0.00 
      entry = "#{x.to_i},#{y.to_i}"
      output <<  {:pos => entry,:t =>"line",:g =>"3"}
    end
    if x < 0 and y > height and x > width and y < 0
       break;
    end
    if z < 0
      output << {:pos => 'new', :t =>"line"} 
    end 
    i=i+1
  end
  output << {:pos => 'new', :t =>"line"}
  output
end

def buildMilkyWay(c_ra ,c_dec, scale, width, height)
  output = []
  matrix,smatrix = local_transform(c_ra,c_dec,scale)
  lines = open("datasets/milkyway.dat"){ |f| f.read }
  lines.each_line do |l|
    data = l.split(" ")
    ra = data[0]
    dec = data[1]
    grey = data[2]
    x,y,z = polar_transform(ra.to_f,dec.to_f, matrix, smatrix, width, height) 
    if z > 0
      output  << {:x => x.to_i, :y => y.to_i, :grey => grey,:t => "m"}
    end
  end
  radius = 0.212
  c = 1.0/scale * 180/3.141592653589793
  radius = radius * c/2.54 * 72.27
  output
end

def buildScaleData(c_ra,c_dec,scale,width,height)
  output = []
  matrix,smatrix = local_transform(c_ra,c_dec,scale)
##### RA SCALE TICKS
  rectascension = 0 
  while rectascension < 24 
    x1,y1,z1 = polar_transform(rectascension,c_dec, matrix, smatrix, width, height)
    if z1 > -0.25
      entry = "#{x1},#{y1}"
      output <<  {:pos => entry,:t =>"tick",:g =>"ra", :d => "%02d" % rectascension}
    end
    rectascension = rectascension +1
  end
##### RA CENTER LINE
  x,y,z = polar_transform(c_ra,c_dec, matrix, smatrix, width, height)
  entry = "0,#{y.to_i}"
  output <<  {:pos => entry,:t =>"line",:g =>"2"}
  entry = "#{width},#{y.to_i}"
  output <<  {:pos => entry,:t =>"line",:g =>"2"}
  output << {:pos => 'new', :t =>"line"}
##### DEC SCALE TICKS
  dec = -80
  while dec < 90 
    x1,y1,z1 = polar_transform(c_ra,dec, matrix, smatrix, width, height)
  #/  if z1 > -0.25
      entry = "#{x1},#{y1}"
      output <<  {:pos => entry,:t =>"tick",:g =>"dec", :d => "%02d" % dec}
  #/  end
    dec = dec +10
  end
##### DEC CENTER LINE
  x,y,z = polar_transform(c_ra,c_dec, matrix, smatrix, width, height)
  entry = "#{x.to_i},0"
  output <<  {:pos => entry,:t =>"line",:g =>"2"}
  entry = "#{x.to_i},#{height}"
  output <<  {:pos => entry,:t =>"line",:g =>"2"}
  output << {:pos => 'new', :t =>"line"}
 return output
end

def local_transform(rectascension,declination,grad_per_cm)
  matrix = []
  smatrix = []
  m_PI = 3.141592653589793
  m_PI_2 = m_PI / 2
  phi= -(rectascension+12)*15*m_PI/180.0;
  delta= declination*m_PI/180.0;
  alpha= -delta+m_PI_2;
  rad_per_cm= grad_per_cm*m_PI/180.0;
  matrix[0]= Math.sin(phi)
  matrix[1]= Math.cos(phi)
  matrix[2]= 0.0;
  matrix[3]= Math.cos(phi)*Math.cos(alpha);
  matrix[4]= -Math.sin(phi)*Math.cos(alpha);
  matrix[5]= Math.sin(alpha);
  matrix[6]= -Math.cos(phi)*Math.sin(alpha);
  matrix[7]= Math.sin(phi)*Math.sin(alpha);
  matrix[8]= unscaled22= Math.cos(alpha);
  smatrix[0] = matrix[0] /rad_per_cm
  smatrix[1] = matrix[1] /rad_per_cm
  smatrix[2] = matrix[2] /rad_per_cm
  smatrix[3] = matrix[3] /rad_per_cm
  smatrix[4] = matrix[4] /rad_per_cm
  smatrix[5] = matrix[5] /rad_per_cm
  smatrix[6] = matrix[6] /rad_per_cm
  smatrix[7] = matrix[7] /rad_per_cm
  smatrix[8] = matrix[8] /rad_per_cm
  return matrix,smatrix
end

def polar_transform(ra,dec, matrix,smatrix, width, height)
  m_PI = 3.141592653589793
  m_PI_2 = m_PI / 2
  phi= ra*15*m_PI/180.0
  delta= dec*m_PI/180.0
  cos_delta= Math.cos(delta)
  x0= cos_delta*Math.cos(phi)
  y0= cos_delta*Math.sin(phi)
  z0= Math.sin(delta)
  z1= matrix[6]*x0+matrix[7]*y0+matrix[8]*z0
  zt= 1.0-z1
  stretch= 1.0+zt*
  (1.0/3.0+zt*
  (2.0/15.0+zt*
  (2.0/35.0+zt*
  (8.0/315.0+zt*
  (8.0/693.0)))))
  x1= smatrix[0]*x0+smatrix[1]*y0;
  y1= smatrix[3]*x0+smatrix[4]*y0+smatrix[5]*z0
  x= x1*stretch+width/2.0
  y= -y1*stretch+height/2.0
  return x,y,z1
end

