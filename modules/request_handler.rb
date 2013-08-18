require './modules/cache'
require './modules/image_processor'
require './modules/key_generator'

module Whim

  class RequestHandler

    class << self
      def url_for original_url, geometry, format

        key = Key.generate( original_url, geometry, format )

        begin
          url = Cache.fetch key
          puts "Cache hit for #{original_url} resized to #{geometry}"

        rescue Cache::Miss

          result = RemoteFile.new(key)

          image = Image.new(original_url)
          image.process! ( geometry, format )

          result.store do |object|
            object.write( image.blob, :acl=>:public_read )
          end

          url = Cache.store key, result.url

          puts "Cache miss for #{original_url} resized to #{geometry}"

        end

        url.to_s

      end

    end

  end
end
