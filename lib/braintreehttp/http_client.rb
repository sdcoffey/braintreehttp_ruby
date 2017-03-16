require 'json'
require 'ostruct'

module BraintreeHttp

  class DefaultHttpClient

    def initialize
      @injectors = []
    end

    def user_agent
      return "Ruby HTTP/1.1"
    end

    def add_injector(inj)
      @injectors << inj
    end

    def execute(request)
      @injectors.each do |injector|
        injector.inject(request)
      end

      if !request["User-Agent"]
        request["User-Agent"] = user_agent
      end

      connection = Net::HTTP.new(request.uri.host)

      #connection.open_timeout = @config.http_open_timeout
      #connection.read_timeout = @config.http_read_timeout
      connection.start do |http|
        parse_response(http.request(request))
      end
    end

    def parse_response(response)

      status_code = response.code
      body = response.body
      if status_code.to_i >= 200 and status_code.to_i < 300
        json_body = JSON.parse(body)
        body = OpenStruct.new(json_body)

        OpenStruct.new({
          :status_code => status_code,
          :data => body,
          :headers => response.to_hash,
        })
      end
    end

  end
end
