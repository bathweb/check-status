require File.expand_path(File.dirname(__FILE__)) + "/base_test.rb"
require 'net/http'
require 'net/https'

class WebsiteTest < BaseTest

    @type = "website"
    attr_reader :name, :addr

    def initialize(name, addr)
        @name = name
        @addr = addr
    end

    def run_test
        url = URI.parse(@addr)
        # can add proxy here if we need it later
        http = Net::HTTP.new(url.host, url.port)

        # switch to ssl if required
        if (url.scheme == "https") then
            http.use_ssl = true
        end

        @result = "website:down"

        begin
            res = http.request(Net::HTTP::Get.new(url.request_uri))

            if (res.code.to_i >= 300 && res.code.to_i < 400) then
                @result = "website:redirecting"
            elsif (res.code.to_i < 300) then 
                @result = "website:up"
            end            
        rescue => e
            # swallow
        end
                
        return [@name, @addr, @result]
    end

end
