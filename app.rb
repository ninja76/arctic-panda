# encoding: utf-8
require 'rubygems'
require 'sinatra'
require 'sinatra/assetpack'
require 'json/ext'
require 'slim'
require 'sequel'
require 'aws-sdk'
require './database'
require 'shoryuken'


Sequel::Database.extension :pagination
Sinatra::Application.register Sinatra::AssetPack
require File.expand_path(File.dirname(__FILE__) + '/config/config.aws.rb')

class MyApp < Sinatra::Application
  enable :sessions

  register Sinatra::AssetPack
  enable :inline_templates
  assets do
    serve '/js',     from: 'public/js'        # Default
    serve '/css',    from: 'public/css'       # Default
    serve '/image',  from: 'public/image'     # Default

    css :bootstrap, [
      "//netdna.bootstrapcdn.com/bootstrap/3.1.1/css/bootstrap.min.css",
      "//netdna.bootstrapcdn.com/bootstrap/3.1.1/css/bootstrap-theme.min.css",
      "/css/bootswatch.min.css"
    ]

    js :jsapp, [ "//ajax.googleapis.com/ajax/libs/jquery/1.11.0/jquery.min.js",
     "//netdna.bootstrapcdn.com/bootstrap/3.1.1/js/bootstrap.min.js",
     "//d3js.org/d3.v3.min.js",
     "/js/jquery.nouislider.min.js",
     "/js/astro.js"
    ]

    css_compression :simple
    js_compression :jsmin
    prebuild true
  end

  configure do
    puts "#{environment} #{database}"
    set :author, "Bryan"
    set :desc, "Ruby Sinatra Astronomical Catalog"
    set :public_dir, File.dirname(__FILE__) + '/public'
    set :views, File.dirname(__FILE__) + '/templates'
    set :site, "www.roxlr.com:9292"
    set :s3url, "http://fuzzy-lana.s3.amazonaws.com"
    #LOGGER = Logger.new("sinatra.log")
    enable :logging, :dump_errors, :inline_templates
    set :raise_errors, true
  end

end

class MyWorker
	@app = MyApp.new
	database = ""
	include Shoryuken::Worker
	    shoryuken_options queue: 'arctic_panda', auto_delete: true
	    def perform(sqs_msg, hash); 
		data = JSON.parse(hash)
		#fileName = generateFileName(data["ra"],data["dec"], data[:iscline], data["ismilky"], data["isboundry"], data["scale"], data["mag"], data["ngcmag"], data["isgrid"])
                map = submit_job(data)
	    end
end
@root = ::File.dirname(__FILE__)

require_relative 'models/init'
require_relative 'routes/init'
require_relative 'helpers/init'
