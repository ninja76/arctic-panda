require 'sinatra'
require 'sinatra/sequel'

root = ::File.dirname(__FILE__)

configure :development do
 set :database, "sqlite:///#{root}/data/astro.db"
 set :show_exceptions, true
end

configure :production do
# set :database, URI.parse(ENV['DATABASE_URL'] || 'postgres:///localhost/mydb')
 set :database, "sqlite:///#{root}/data/astro.db"
 set :show_exceptions, true
end
puts "the objects table doesn't exist" if !database.table_exists?('aobjects')

migration "create the objects table" do
  database.create_table :aobjects do
    primary_key :id
    text        :ngc
    text	:ic
    text	:name
    text	:type
    float	:ra
    float	:dec
    text	:const
    text	:ccode
    float	:distance
    text	:hip
    text	:hd
    text	:yale
    text	:gliese
    text	:spectrum
    text	:cindex
    text	:bayer
    float	:mag
    text	:absmag
    float	:cX
    float	:cY
    float	:cZ
    text	:mes
  end
end

migration "alter objects" do
  database.alter_table :aobjects do
    add_column :flamsteed, :text 
    add_column :detail,    :text
    add_column :size,      :text
  end
end

migration "create the constellations table" do
  database.create_table :constellations do
    primary_key :id
    text        :name
    text	:desc
    float       :ra
    float       :dec
  end
end

migration "alter constellations" do
  database.alter_table :constellations do
    add_column :lines, :text
    add_column :code,  :text
  end
end

migration "create the jobs status table" do
  database.create_table :jobs do
    primary_key :id
    text        :jobid
    bool        :done
  end
end

Sequel::Model.db.extension(:pagination)
