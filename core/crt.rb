require "json"
require "net/http"

class Crt
    def initialize(domain)
        @domain = domain
        @subdomains = []
    end

    def run(proxied)
        if proxied
            response = ProxiedRequest::HTTP.request("https://crt.sh/?q=#{@domain}&output=json")
            response = response.body
        else
            uri = URI("https://crt.sh/?q=#{@domain}&output=json")
            response = Net::HTTP.get(uri)
        end

        json = JSON.parse(response)
        json.each do |result|
            name = result["name_value"].split("\n")
            name.each do |name|
                if name.include? @domain
                    @subdomains << name
                end
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