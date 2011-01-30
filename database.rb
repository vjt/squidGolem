require 'uri'
require 'ipaddr'

module SquidGolem
  module Database

    def self.acl_for(url, user, host)
      url  = URI.parse(url)
      host = IPAddr.new(host)

      ACL.fetch(url, user, host)
    end

    def initialize
    end

    class ORM
    end

    module Source
      class Base < ORM
      end

      class Address < Base
      end

      class User < Base
      end
    end

    module Destination
      class Base < ORM
      end

      class Domain < Base
      end

      class URL < Base
        # -ENOSYS
      end

      class Expression < Base
        # -ENOSYS
      end
    end

    class ACL
      def self.fetch(url, user, host)
      end

      def url
      end
    end
  end
end
