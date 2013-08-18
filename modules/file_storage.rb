require 'aws-sdk'

module Whim
  class RemoteFile

    class << self
      def connect!

        @@s3 = AWS::S3.new(
          :access_key_id => ENV['S3_KEY'],
          :secret_access_key => ENV['S3_SECRET']
        )

        @@bucket = @@s3.buckets[ ENV['S3_BUCKET'] ]

      end

      def clean_up days_ago=30

        cuttoff_date = Date.today - days_ago

        Cache.keys_older_than(cuttoff_date) do |key|
          RemoteFile.new(key).remove!
        end

      end

    end

    def initialize key, value=nil
      @key = key
      @value = value
    end

    def url
      @url ||= @@bucket.objects[@key].public_url
    end

    def store!
      @@bucket.objects[@key].write(@value, :acl=>:public_read)
      @url = @@bucket.objects[@key].public_url
    end

    def remove!
      @@bucket.objects[@key].delete
    end


  end
end
