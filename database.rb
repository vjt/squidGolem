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

    module Source
      class Base
      end

      class Address < Base
      end

      class User < Base
      end
    end

    module Destination
      class Base
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
      def self.fetch(domain, user, host)
        %[sp_check_domain #{domain}, #{user}, #{host}]
      end

      def url
      end
    end
  end
end
