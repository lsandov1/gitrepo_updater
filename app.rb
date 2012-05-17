require 'rubygems'
require 'bundler'

Bundler.require

#require 'sinatra'
require 'json'
require 'open-uri'

helpers do

  def exec(path, cmd) 
    cmd = "/bin/bash -c \". $HOME/.profile; cd #{path} && #{cmd}\""
    puts "Executing Command: #{cmd}"
    `#{cmd}`
  end

  def create_path(path) Dir.mkdir_p(path, 0700) end

  def update_restart(github_username, github_repository_name)
    data={}
    open('data.json') {|f| data = JSON.parse(f.read) }
    key = "#{github_username}/#{github_repository_name}"
    if data[key]
      data[key].each do |item|
        path        = item["local_path"]
        restart_cmd = item["restart_cmd"]
        begin
          if path
            if File.directory? path
              puts "Pulling"
              exec(path, "git pull")
              exec(path, restart_cmd) unless restart_cmd.empty?
            else
              puts "Cloning"
              FileUtils.mkdir_p path
              exec(path,"git clone git@github.com:#{key} .")
              exec(path, restart_cmd) unless restart_cmd.empty?
            end
          end
        rescue =>e
          puts e.message
        end
      end
    end
  end
end

post '/' do
  payload = JSON.parse(params["payload"])
  repository = payload["repository"]
  github_repository_name = repository["name"]
  github_username = repository["owner"]["name"]
  update_restart github_username, github_repository_name
  ''
end
