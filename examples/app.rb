#!/usr/bin/env ruby
$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)

require 'vifi'
require 'sinatra'

set :bind, '0.0.0.0'
set :port, 3141

get "/update_source", provides: 'text/event-stream' do
  stream(:keep_open) do |out|
    data = Hash.new
    loop do
      data[:label] = Time.now.strftime("%r")
      data[:value] = WillowRun::Status.new.getinfo.agrctlrssi
      out << "data: #{data.to_json}" + "\r\n\n"
      sleep 2
    end
  end
end

get "/" do
  Vifi.build_chart + Vifi.build_updater
end
