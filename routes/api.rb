# encoding: utf-8
  get '/api/map/:scale/:maxmag/:ra/:dec/:width/:height/:isgrid/:iscline/:isboundry/:ismilky' do
    scale = params[:scale] 
    max_mag = params[:maxmag]
    ra = params[:ra]
    dec = params[:dec] 
    width = params[:width].to_i
    height = params[:height].to_i
    isgrid = params[:isgrid]
    iscline = params[:iscline]
    isboundry = params[:isboundry]
    ismilky = params[:ismilky]
    aobjects = database["SELECT ra,dec,mag,bayer,name,flamsteed,ccode,hd,type,mes FROM aobjects WHERE yale != '' OR mes != ' '"]
    map = buildMapData(aobjects, scale, ra, dec, width, height, isgrid, iscline, isboundry, ismilky, max_mag)
    content_type :json
    map
  end

  get '/api/constellations' do
    constellations = database["SELECT name, code, ra, dec FROM constellations"]
    content_type :json
    @constellations
  end

