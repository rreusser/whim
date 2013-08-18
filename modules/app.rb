require "bundler/setup"
require "sinatra"

require './modules/request_handler'
require './modules/file_storage'
require './modules/cache'

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

    get "/" do

      begin

        # Get the parameters:
        original_url = params[:url]
        geometry = params[:geometry] || "100x100"
        format = params[:format] || 'jpg'


        # Fail if no URL:
        raise StandardError.new('No URL provided') if original_url.nil?


        # Fetch URL from cache or by processing:
        url = RequestHandler.url_for(original_url, geometry, format).to_s


        # Return image tag if debug mode:
        @@debug ? "<img src='#{url}'>" : redirect(url)

      rescue *@@rescued_exceptions => e

        puts "Exception: #{e.message}"
        status 500

      end


    end

    run! if app_file == $0

  end
end
