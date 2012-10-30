#!/bin/ruby

require 'rubygems'
require 'test_runner.rb'
require 'sinatra'


# config
script_location = File.expand_path(File.dirname(__FILE__))
tests = TestRunner.new(script_location)

get '/run' do
    tests.run_tests
    tests.create_output
    puts "done"
end

get '/output' do
    send_file File.join(settings.public_folder, 'index.html')
end