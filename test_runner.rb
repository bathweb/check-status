require 'rss/maker'
require 'yaml'
require 'twitter'

class TestRunner

    attr_reader :script_location, :test_location, :output_file

    def initialize(script_location)
        @script_location = script_location
        @test_location = @script_location + "/tests/" # location of test files
        @output_file = @script_location + "/public/output/service_status.rss" # local file to write

        # load all test types
        Dir.new(script_location + "/types/").entries.each { |file|
            if file =~ /.+\.rb$/ then
                require "#{script_location}/types/#{file}"
            end
        }

        # somewhere to put the output
        @results = Array.new

        # check for output directory - create if doesn't exist
        if (!(File.exists?(File.dirname(@output_file)) && File.directory?(File.dirname(@output_file)))) then
            Dir.mkdir(File.dirname(@output_file))
        end

        # check for output file - create if doesn't exist
        if (!(File.exists?(@output_file))) then
            create_output()
        end
        
    end

    def run_tests

        # reset the output array
        @results = Array.new
    
        # for each file do 
        Dir.new(@test_location).entries.each { |file|
            
            # only read files ending in .yml
            if file =~ /.+\.yml$/ then 

                # eugh...
                test = read_yaml_file(@test_location + file)
                
                if (test["type"] == "website") then 
                    w = WebsiteTest.new(test["name"], test["url"])
                    @results << w.run_test
                elsif (test["type"] == "mysql") then
                    m = MysqlTest.new
                    @results << m.run_test
                elsif (test["type"] == "oracle") then
                    o = OracleTest.new
                    @results << o.run_test
                else
                    @results << ["other", "http://www.example.com", false.to_s]
                end
            end
            # end the for each
        }

        # sort the output by first element
        @results.sort_by!{|k|k[0]}.reverse!

    end

    def create_output
    
        # create the output RSS feed 
        version = "2.0" # ["0.9", "1.0", "2.0"]

        content = RSS::Maker.make(version) do |m|
            m.channel.title = "Run, DMC, run!"
            m.channel.link = "http://www.bath.ac.uk/"
            m.channel.description = "Status of the services run by Digital Marketing and Communications"
            m.channel.lastBuildDate = Time.now
            m.items.do_sort = true # sort items by date
            
            # for each result, add an entry in the output feed
            @results.each { |result|
                i = m.items.new_item
                i.title = result[0]
                i.link = result[1]
                i.description = result[2]
                i.date = Time.now    
            }
            
        end

        File.open(output_file,"w") do |f|
            f.write(content)
        end
        
    end

    def send_alerts

        # if a test failed, send an alert to Twitter
        @results.each { |result|
            if result[2] == "website:down" then
                Twitter.update("Website DOWN: #{result[0]} (#{result[1]}) is unavailable #{Time.now.strftime('%d/%m/%y %H:%M')}")
            end
        }

    end

    private
    
        def read_yaml_file(filename)
            test = YAML::load_file(filename)
            return test
        end

end



