require "bundler/setup"
require "sinatra"

require './modules/request_handler'
require './modules/file_storage'

module EasyCache
  class App < Sinatra::Base

    get "/" do

      begin
        RequestHandler.url_for(params[:url], params[:geometry])
      rescue StandardError
        status 500
      end

    end

    run! if app_file == $0

  end
end
