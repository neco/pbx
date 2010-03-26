require 'extlib'
require 'haml'
require 'ostruct'
require 'sass'
require 'sinatra/base'

autoload :Clearpath, 'lib/clearpath'
autoload :HuntGroup, 'lib/hunt_group'

class PBX < Sinatra::Base
  set :haml, { :attr_wrapper => '"' }

  set :clearpath, OpenStruct.new.tap { |clearpath|
    clearpath.username = 'turnover@cpmvp.net'
    clearpath.password = '060381drew'
  }

  configure :development do
    set :database_uri, "sqlite3://#{Dir.pwd / 'db.sqlite3'}".freeze
  end

  configure :test do
    set :database_uri, "sqlite3://#{Dir.pwd / 'test.sqlite3'}".freeze
  end

  configure :production do
    set :database_uri, ENV['DATABASE_URL']
  end

  get '/hunt-groups' do
    @hunt_groups = HuntGroup.all
    haml :hunt_groups
  end

  post '/hunt-groups/:id' do |id|
    @hunt_group = HuntGroup.get(id)

    state_event = case params[:mode].downcase.to_sym
    when :day then :wake
    when :night then :sleep
    end

    @hunt_group.update(:state_event => state_event)
    redirect '/hunt-groups'
  end

  get '/stylesheets/master.css' do
    headers 'Content-Type' => 'text/css; charset=utf-8'
    sass :master
  end
end
