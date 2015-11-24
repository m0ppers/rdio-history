require 'rake'
require 'highline/import'
require 'colorize'
require './lib/rdio-history'
require 'rspec/core/rake_task'
require 'json'

RSpec::Core::RakeTask.new(:spec)

desc "Ask the user for their Rdio username"
task :get_user do
  @username = ask("Enter an rdio username: ")
end

desc "Auth then retreive the most recent songs"
task :default => [:get_user] do
  f = Rdio::History::Fetcher.new(@username)
  
  history = []
  $i = 0
  while slice = f.fetch do
    $i += 1
    puts $i
    
    File.open("data_" + $i.to_s + ".json","w+") do |f|
      f.write(slice.to_json)
    end

    slice.each do |song|
      puts "#{song.track_name} - #{song.artist_name} # #{song.time} ## => #{song.count}"
    end
  end
end

desc "Fetch a single long lived session"
task :get_session do
  session = Rdio::Session::Fetcher.get_session
  puts "authorization_key: #{session[:authorization_key]}"
  puts "authorization_cookie: #{session[:authorization_cookie]}"
end

task :test => :spec

task :session do
  Rdio::Session::Fetcher.get_session('chanian')
end
