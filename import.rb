#
# Utility for importing data from various catalogs
#

#encoding: utf-8
require 'open-uri'
require 'csv'
require './import_helpers'
require 'trollop'
require 'sequel'
require './database'

def messierimport
##Object  Type    RA (h)  DEC (▒) Magnitude       Size (arcminutes)       NGC#    Constellation   Detailed Type   Common Name
  dataset = database[:aobjects]
  lines = open("datasets/messier.txt"){ |f| f.read }
  lines.each_line do |l|
  data = l.split("\t")
  mes    = data[0]
  type   = data[1]
  ra     = data[2]
  dec    = data[3]
  mag    = data[4]
  size   = data[5]
  ngc    = data[6]
  con    = data[7]
  detail = data[8]
  name   = data[9]
  puts "#{mes}"
#   dataset.insert(:mes => mes,:ngc => ngc, :type => type,:const => con,:ra => ra,:dec => dec,:mag => mag, :name=> name, :detail=> detail, :size=> size)
  end
end

def constimport
  dataset = database[:constellations]
  lines = open("const.txt"){ |f| f.read }
  lines.each_line do |l|
    data = l.split("\t")
    name = data[3]
    code = data[2]
    ra   = data[7]
    dec  = data[8]
    puts "Inserting #{name},#{code},#{ra},#{dec}"
    dataset.insert(:name => name,:code => code, :ra => ra, :dec =>dec)
  end

end

def boundryimport
  export = "data/constellations/boundry.json"
  import = "datasets/constbnd.dat"
  file = File.open(export, "w")
  file.puts '{ "lines":{ '
  lines = open(import){ |f| f.read }
  cc = 0
  star = ""
  lines.each_line do |l| 
    data = l.split(" ")
    ra = data[0]
    dec = data[1]
    c1  = data[2]
    if data[3]
      c2 = data[3]
      star = star + "#{ra},#{dec} "
    else
      file.puts "\"line#{cc.to_s}\": \"#{star}\","
      star = ""
    end
    cc = cc +1
  end 
  file.puts "} }"
  file.close
end


def clineimport
  import = "data/constellations/linesv2.dat"
#  import = "/root/pp3-1.3.3/lines.dat"

  # json format { "lines":{ "line1":"19,34,24", "line3":"53,50,46,34", "line2":"50,58"} }
  lines = open(import){ |f| f.read }
  i = 0
  cc = 0
  c1 = ""
  c2 = ""
  file = File.open("data/constellations/lines2.json", "w")
  file.puts '{ "lines":{ '
  lines.each_line do |l|
    if l[0] != "#"
      data = l.split("  ")
      star = ""
      data.each do |d|
        d2 = d.split(" ")
        c1 = d2[0]
        if d2[1] != " "
          star = star + "#{c1} #{d2[1]},"
        end
      end
      star[-1] = ''
      if star != " "
        file.puts "\"line#{cc.to_s}\": \"#{star}\","
      end
      cc = cc+1
    end
  end
    file.puts "} }"
    file.close
end

def ngcimport
  dataset = database[:aobjects]
  lines = open("datasets/NGCIC.txt"){ |f| f.read }
  lines.each_line do |l|
    data = l.encode('UTF-8', :invalid => :replace).split("\t")
    ngc = data[0]
    type = data[13]
    con = data[7]
    mag = data[17]
    # RA 00h 07m 15.9s
    rdata = data[5].split(' ') 
    rh = rdata[0]
    rm = rdata[1]
    rs = rdata[2]
    ra = rh.to_f + (rm.to_f/60) + (rs.to_f/3600)
    ra = "%.02f" % ra
    # DEC -35<BA> 23' 36
    ddata = data[6].split(' ')
    d = ddata[0]
    s = 1
    if d[0] ='-'
      s = -1
    end
    d[0] = ''
    dm = ddata[1]
    ds = ddata[2]
    dec = d.to_f + (dm.to_f/60) + (ds.to_f/3600) * s
    dec = "%.02f" % dec 
    type = transtype(type)
    con  = transCon(con)
    puts "#{ra}, #{dec}, #{ngc}, #{type}, #{con}, #{mag}"
    duplicate = database["SELECT id FROM aobjects WHERE ngc ='NGC#{ngc}'"]
    if duplicate.count > 0
      puts "Duplicate NGC object found!"
    else
      puts "Inserting #{ngc}"
      dataset.insert(:ngc => ngc, :type => type,:const => con,:ra => ra,:dec => dec,:mag => mag)
    end
  end
end

def hygimport(opts)
  dataset = database[:aobjects]
  CSV.open('datasets/hyg.csv', headers: true, converters: :numeric).each do |row|
    const = ""
    hip      = row['HIP']
    hd       = row['HD']
    yale     = row['HR']
    gli      = row['Gliese']
    bayer    = row['BayerFlamsteed'].to_s
    flamsteed = ""
    if bayer[1] =~ /[[:digit:]]/
      flamsteed = bayer[0,2]
      puts flamsteed
      bayer[0] = ''
      bayer[0] = ''
    end
    if bayer[0] =~  /[[:digit:]]/ and bayer[1] !~  /[[:digit:]]/
      flamsteed = bayer[0,1]
      bayer[0] = ''
    end
    bayer = bayer.lstrip
    bayer = bayer.rstrip
    if bayer.length > 1
      const    = bayer[-3,3]
      ccode    = const 
      const = transCon(const)
      bayer = bayer
    end
    name     = row['ProperName']
    ra       = row['RA']
    dec      = row['Dec']
    distance = row['Distance']
    mag      = row['Mag']
    absmag   = row['AbsMag']
    spectrum = row['Spectrum']
    cindex   = row['ColorIndex']
    cX       = row['X']
    cY       = row['Y']
    cZ       = row['Z']
    if !opts[:dry]
      dataset.insert(:ic => ' ',:mes => ' ',:ngc => ' ',:hip => hip,:type => 'Star',:const => const,:ra => ra,:dec => dec,:mag => mag,:hd =>hd,:yale=> yale,:gliese=> gli, :name=> name,:bayer=> bayer,:distance=> distance,:cindex=> cindex,:spectrum=> spectrum,:absmag=> absmag,:cX=> cX,:cY=> cY,:cZ=> cZ, :flamsteed=> flamsteed, :ccode=> ccode)
      puts "Inserting new record #{hip}"
    end
  end
end

## Get CLI options
  def parse_options
    opts = Trollop::options do
      opt :ngc, "ngc"
      opt :hyg, "hyg"
      opt :dry, "dry"
      opt :line, "Constellation Lines"
      opt :con, "Constellation Import"
      opt :mes, "Messier Import"
      opt :bnd, "Boundry"

    end
    return opts
  end
@foo = database[:aobjects].all
opts = parse_options
if opts[:hyg]
  hygimport(opts)
end

if opts[:ngc]
  ngcimport
end

if opts[:line]
  clineimport
end

if opts[:con]
  constimport
end

if opts[:mes]
  messierimport
end

if opts[:bnd]
  boundryimport
end

