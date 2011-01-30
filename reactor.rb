require 'eventmachine'

require 'database'

module SquidGolem
  module Reactor
    def receive_data(data)
      url, user, host = parse(data)
      acl = acl_for(url, user, host)
      send_data "#{acl.url}\n"
    end

    private

      # Format:
      # http://example.com/somepath?foo=bar&baz=true 192.168.1.1/USER - GET
      # 
      # Returns [url, user, host]
      def parse(data)
        url, user_host, *rest = data.split(/\s+/)
        user, host = user_host.split('/')

        return url, user, host
      end

      # Check against the database
      #
      # Returns the ACL that matched
      def acl_for(url, user, host)
        Database.acl_for(url, user, host)
      end

  end
end
