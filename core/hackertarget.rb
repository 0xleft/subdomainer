require 'net/http'
require 'proxied_request'

class HackerTarget
    def initialize(domain)
        @domain = domain
        @subdomains = []
    end

    def run(proxied)
        if proxied
            response = ProxiedRequest::HTTP.request("https://api.hackertarget.com/hostsearch/?q=#{@domain}")
            response = response.body
        else
            uri = URI("https://api.hackertarget.com/hostsearch/?q=#{@domain}")
            response = Net::HTTP.get(uri)
        end

        response.split("\n").each do |line|
            if line.include? @domain
                @subdomains << line.split(",")[0]
            end
        end

        @subdomains.uniq!
        @subdomains
    end

    def get_thread(proxied = false)
        thread = Thread.new do
            result = self.run(proxied)
            Thread.current[:result] = result
        end
        return thread
    end
end