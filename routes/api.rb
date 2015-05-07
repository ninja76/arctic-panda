# encoding: utf-8
  get '/api/map/:scale/:maxmag/:ra/:dec/:width/:height/:isgrid/:iscline/:isboundry/:ismilky/:ngcmaglimit' do
    scale = params[:scale] 
    max_mag = params[:maxmag]
    ngc_max_mag = params[:ngcmaglimit]
    ra = params[:ra]
    dec = params[:dec] 
    width = params[:width].to_i
    height = params[:height].to_i
    isgrid = params[:isgrid]
    iscline = params[:iscline]
    isboundry = params[:isboundry]
    ismilky = params[:ismilky]
    #aobjects = database["SELECT ra,dec,mag,bayer,name,flamsteed,ccode,hd,type,mes,ngc FROM aobjects WHERE yale != '' OR (type != 'Star' AND mag < #{ngc_max_mag})"]
    result = queue_submit(scale, ra, dec, width, height, isgrid, iscline, isboundry, ismilky, max_mag, ngc_max_mag);
    #map = buildMapData(aobjects, scale, ra, dec, width, height, isgrid, iscline, isboundry, ismilky, max_mag, ngc_max_mag)
    content_type :json
    headers( "Access-Control-Allow-Origin" => "*" )
    headers( "Access-Control-Allow-Headers" => "*" )
    if result.split(':')[0] == "cache"
      { :status => 'cached', :jobId => result.split(':')[1] }.to_json
    else
      { :status => 'success', :jobId => result }.to_json
    end
  end

  get '/api/constellations' do
    constellations = database["SELECT name, code, ra, dec FROM constellations"]
    puts constellations.to_a.to_json

    content_type :json
    constellations.to_a.to_json
  end

