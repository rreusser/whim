require "bundler/setup"
require "sinatra"
require 'json'

require './modules/request_handler'
require './modules/file_storage'
require './modules/cache'
require './modules/key_generator'

module Whim
  class App < Sinatra::Base

    class << self
      def connect!
        Whim::Cache.connect!
        Whim::RemoteFile.connect!
      end
    end

    configure do
      @@debug = ENV['DEBUG'] == 'true'
      @@rescued_exceptions = @@debug ? [] : [StandardError]
    end


    def sanitized_params(params)
      original_url = params[:url]
      geometry = params[:geometry] || "100x100"
      format = params[:format] || 'jpg'

      # Fail if no URL:
      raise StandardError.new('No URL provided') if original_url.nil?

      {
        original_url: original_url,
        geometry: geometry,
        format: format
      }
    end


    get "/" do

      begin

        p = sanitized_params(params)

        # Fetch URL from cache or by processing:
        url = RequestHandler.url_for(p[:original_url], p[:geometry], p[:format]).to_s


        # Return image tag if debug mode:
        @@debug ? "<img src='#{url}'>" : redirect(url)

      rescue *@@rescued_exceptions => e

        puts "Exception: #{e.message}"
        status 500

      end

    end


    get "/stats/image" do

      p = sanitized_params(params)

      begin
        
        content_type :json

        key = Key.generate( p[:original_url], p[:geometry], p[:format] )
        {
          url: p[:original_url],
          key: key,
          request_count: Cache.requests_for(key)
        }.to_json

      rescue *@@rescued_exceptions => e

        puts "Exception: #{e.message}"
        status 500

      end

    end


    get "/stats" do
      content_type :json
      Cache.stats.to_json
    end



    run! if app_file == $0

  end
end
