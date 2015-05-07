def queue_submit(scale, ra, dec, width, height, isgrid, iscline, isboundry, ismilky, max_mag, ngc_max_mag)
  fileName = generateFileName(ra, dec, iscline, ismilky, isboundry, scale, max_mag, ngc_max_mag, isgrid)
  # Check cache before submitting a new job
  if checkmap(fileName) == true
    return "cache:#{fileName}"
  end
  puts "DEBUG: ngc_max_mag #{ngc_max_mag}"
  result = MyWorker.perform_async(fileName: fileName, scale: scale, ra: ra, dec: dec, width: width, height: height, isgrid: isgrid, iscline: iscline, isboundry: isboundry, ismilky: ismilky, max_mag: max_mag, ngc_max_mag: ngc_max_mag)
  return fileName
end

def submit_job(data)
   puts "getting objects from database"
   puts "DEBUG submit_job #{data["ngc_max_mag"]}"

   aobjects = Aobject.where{(yale != '') | ((type != 'Star') & (mag < data["ngc_max_mag"]))}
   aobjects = Aobject.where("yale != '' OR (type != 'Star' AND mag < #{data["ngc_max_mag"]})") #{(yale != '') | ((type != 'Star') & (mag < data["ngc_max_mag"]))}
   puts "Object Dump: #{aobjects.inspect}"
   map = buildMapData(data["fileName"], aobjects, data["scale"], data["ra"], data["dec"], data["width"], data["height"], data["isgrid"], data["iscline"], data["isboundry"], data["ismilky"], data["max_mag"], data["ngc_max_mag"])
   puts "STEP 99: #{map}" 
end
