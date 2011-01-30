require 'eventmachine'
require 'uri'
require 'ipaddr'

module SquidGolem
  module Reactor
    def receive_data(data)
      domain, user, address = parse(data)
      if allowed?(domain, user, address)
        send_data "\n"
      else
        send_data blocked_url(domain, user)
      end
    end

    private

      # Format:
      # http://example.com/somepath?foo=bar&baz=true 192.168.1.1/USER - GET
      # 
      def parse(data)
        url, user_host, _, method = data.split(/\s+/)
        user, host = user_host.split('/')

        url  = URI.parse(url)
        addr = IPAddr.new(host)

        return url, user, addr
      end

      def allowed?
      end

      def blocked_url(domain, user)
      end
  end

  module Source
  end

  module Destination
  end

  module ACL
  end
end
