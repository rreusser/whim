require 'digest'

module Whim
  class Key

    class << self

      def generate( original_url, geometry, format )

        # "Tempt the demo gods" with a non-unique key...
        "#{Digest::MD5.hexdigest(original_url+geometry)}/#{File.basename(original_url,'.*')}.#{format}"

      end

    end
  end
end
