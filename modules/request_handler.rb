require './modules/cache'
require './modules/image_processor'
require 'digest'

module EasyCache

  class RequestHandler

    class << self
      def url_for original_url, geometry

        key = "#{Digest::MD5.hexdigest(original_url+geometry)}/#{File.basename(original_url)}"

        begin
          url = Cache.fetch key
          puts "Cache hit for #{original_url} resized to #{geometry}"

        rescue Cache::Miss

          image = Image.new(original_url)
          image.process! ( geometry )

          result = RemoteFile.new(key, image.blob)
          result.store!

          url = Cache.store key, result.url

          puts "Cache miss for #{original_url} resized to #{geometry}"

        end


        if ENV['DEBUG']=='true'
          "<img src=\"#{url.to_s}\" alt=\"#{File.basename(original_url)}\">"
        else
          redirect url.to_s
        end

      end

    end

  end
end
