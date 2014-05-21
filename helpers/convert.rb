require 'cloudconvert'
require 'open-uri'

def convertMap(inputfile,format)
  s3 = AWS::S3.new
  b = s3.buckets['fuzzy-lana']
  Cloudconvert.configure do |config|
      config.api_key  = "vYJiWB0UUNw3Houf6SJs_WNNzL4YNgGuyRAxCoMuqvr51wBPVKZbvvjgLj9wldloK4PxIN20ku0PySualC3F1w"
  end
  conversion = Cloudconvert::Conversion.new
  inputformat = "svg"
  outputformat = format
  file_path = "#{settings.s3url}/#{inputfile}.svg"
  puts "Attempting to convert #{file_path} to #{format}"
  # to start file conversion (options parameter is optional)
  conversion.convert(inputformat, outputformat, file_path)  
  while conversion.status["step"] != "finished"
    puts conversion.status
  end
  open("public/image/#{inputfile}.#{format}",'wb') do |file|
    puts "Saving #{conversion.download_link} to public/image/#{inputfile}.#{format}"
    file << open(conversion.download_link).read 
  end

  o = b.objects["#{inputfile}.#{format}"]
  o.write(:file => "public/image/#{inputfile}.#{format}")
  o.acl = :public_read 
  url = o.url_for(:read)
  puts "DOne. Returning success #{url}"
  return "success"
end

def convertMapLocal(inputfile,format)
  s3 = AWS::S3.new
  b = s3.buckets['fuzzy-lana']
  
  convert = `/usr/bin/cairosvg public/image/#{inputfile}.svg -f #{format} -o public/image/#{inputfile}.#{format}`
  o = b.objects["#{inputfile}.#{format}"]
  o.write(:file => "public/image/#{inputfile}.#{format}")
  o.acl = :public_read
  url = o.url_for(:read)
  puts "DOne. Returning success #{url}"
  return "success"

end

