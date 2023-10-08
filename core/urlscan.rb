require "json"
require "net/http"

class Urlscan
    def initialize(domain)
        @domain = domain
        @subdomains = []
    end

    def run(proxied)
        if proxied
            response = ProxiedRequest::HTTP.request("https://urlscan.io/api/v1/search/?q=domain:#{@domain}")
            response = response.body
        else
            uri = URI("https://urlscan.io/api/v1/search/?q=domain:#{@domain}")
            response = Net::HTTP.get(uri)
        end

        json = JSON.parse(response)
        json["results"].each do |result|
            domain = result["page"]["domain"]
            if domain.include? @domain
                @subdomains << domain
            end
        end

        @subdomains.uniq!
        return @subdomains
    end

    def get_thread(proxied = false)
        thread = Thread.new do
            result = self.run(proxied)
            Thread.current[:result] = result
        end
        return thread
    end
end