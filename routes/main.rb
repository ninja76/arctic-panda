# encoding: utf-8
#class MyApp < Sinatra::Application
  
  get '/' do
    slim :landing
  end

  get '/search/:term' do
    term = params[:term]
    puts "Performing search"
    @aobjects = Aobject.grep([:name, :const, :mes, :ngc, :type, :bayer, :flamsteed, :ccode, :hd, :hip, :yale],%W(%#{term}%),:case_insensitive=>true)
    slim :index
  end

  post '/new' do
    t = Aobject.new(params)
      if t.save
        redirect '/'
      else
        "Error saving doc"
      end 
  end
#end
