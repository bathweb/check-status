#!/bin/ruby

require 'rubygems'
require 'haml'
require 'sinatra'
require 'rss/parser'
require 'rufus/scheduler'

require_relative 'test_runner.rb'

class MyApp < Sinatra::Base

    # config
    script_location = File.expand_path(File.dirname(__FILE__))

    # set up web routes
    tests = TestRunner.new(script_location)

    get '/run' do
        tests.run_tests
        tests.create_output
        redirect '/'
    end

    get '/output' do
        send_file tests.output_file
    end

    get '/' do

        # Read the feed into rss_content
        rss_content = ""
        open(tests.output_file, "r") do |f|
           rss_content = f.read
        end

        # Parse the feed, dumping its contents to rss
        rss = RSS::Parser.parse(rss_content, false)

        title = "Is it up?"
        date = "Last updated: " + Time.parse(rss.channel.lastBuildDate.to_s).strftime("%H:%M:%S %d/%m/%Y")
        haml :index, :format => :html5, :locals => {:title => title, :date => date, :rss => rss}
    end

    get '/bigscreen' do

        status = :ok

        # Read the feed into rss_content
        rss_content = ""
        open(tests.output_file, "r") do |f|
           rss_content = f.read
        end

        # Parse the feed, dumping its contents to rss
        rss = RSS::Parser.parse(rss_content, false)

        title = "Is it up?"
        date = "Last updated: " + Time.parse(rss.channel.lastBuildDate.to_s).strftime("%H:%M:%S %d/%m/%Y")

        rss.items.each { |i| 
            if i.description.include?('down')
                status = :broken
            end 
        }     

        if status == :ok 
            haml :bigscreen, :format => :html5, :locals => {:title => title, :date => date, :rss => rss}
        else
            haml :index, :format => :html5, :locals => {:title => title, :date => date, :rss => rss}
        end

    end

    get '/test' do
        "test3"
    end

    # set up scheduling - refactor to a different file?
    scheduler = Rufus::Scheduler.start_new

    scheduler.every '10m' do
        tests.run_tests
        tests.create_output
        tests.send_alerts
    end

end
 