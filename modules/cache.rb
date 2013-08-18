require "redis"

module EasyCache
  class Cache

    class Miss < Exception
    end

    class << self
      def connect!
        uri = URI.parse(ENV["REDISTOGO_URL"])
        @@redis = Redis.new(:host => uri.host, :port => uri.port, :password => uri.password)
      end

      def fetch key
        value = @@redis.get key

        if value.nil?
          raise Miss
        else
          value
        end

      end

      def store key, value
        @@redis.set key, value
        value
      end

    end
  end
end
