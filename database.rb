require 'uri'
require 'ipaddr'

module SquidGolem
  module Database

    def self.acl_for(url, user, host)
      url  = URI.parse(url)
      addr = IPAddr.new(host)
    end

    def initialize
    end


    module Source
      class Address
      end

      class User
      end
    end

    module Destination
      class Domain
      end

      class URL
        # -ENOSYS
      end

      class Expression
        # -ENOSYS
      end
    end

    class ACL
      def self.fetch(source, destination)
      end

      def blocked_url
      end
    end
  end
end
