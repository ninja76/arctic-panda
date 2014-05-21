#Comparing ORI,xi with Ori,Xi   (70)
def find_flamsteed(bayer)
  bayer1,bayer2 = bayer.chomp.split("\t")
  lines = open("data/constellations/data.txt"){ |f| f.read }
  lines.each_line do |l|
    data = l.split("|")
    flamsteed = data[0]
    b = data[1]
    hd = data[2]
    if b
      b.chomp!
      if b.length > 3
        cID = b[-3,4].chomp()
        b[-1] = ''
        b[-1] = ''
        b[-1] = ''
      else
        cID = b
      end
      if !bayer2
        puts "\n"
        return
      end     
      if bayer1 and bayer2
        bayer2 = bayer2.gsub(/\^/,'')
        b = b.gsub(' ', '')
        if bayer1.casecmp(cID) == 0 and bayer2[0,4].casecmp(b.rstrip) == 0
          if flamsteed == ""
            hd = hd.chomp
            flamsteed = "HD#{hd}"
            flamsteed.chomp
          end
          print "#{bayer1} #{flamsteed}  "
          return
        end
        if bayer1.casecmp(cID) == 0 and bayer2[0,3].casecmp(b.rstrip) == 0
          if flamsteed == ""
            hd = hd.chomp
            flamsteed = "HD#{hd}"
            flamsteed.chomp
          end
          print "#{bayer1} #{flamsteed}  "
          return
        end
       if  bayer2[0,3][0] =~ /[[:digit:]]/
         
         if bayer1.casecmp(cID) == 0 and bayer2.rstrip == flamsteed
           print "#{bayer1} #{flamsteed}  "
           return
         end
       end
      end
    end
  end   
end


lines = open("datasets/constellation_lines.txt"){ |f| f.read }
output = ""
lines.each_line do |l|
  if l
    find_flamsteed(l)
  else
  end
end

