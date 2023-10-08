require "json"
require "net/http"

class Urlscan
    def initialize(domain)
        @domain = domain
        @subdomains = []
    end

    def run
        uri = URI("https://urlscan.io/api/v1/search/?q=domain:#{@domain}")
        response = Net::HTTP.get(uri)
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

    def get_thread
        thread = Thread.new do
            result = self.run
            Thread.current[:result] = result
        end
        return thread
    end
end