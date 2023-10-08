require "json"
require "net/http"

class Crt
    def initialize(domain)
        @domain = domain
        @subdomains = []
    end

    def run
        uri = URI("https://crt.sh/?q=#{@domain}&output=json")
        response = Net::HTTP.get(uri)
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

    def get_thread
        thread = Thread.new do
            result = self.run
            Thread.current[:result] = result
        end
        return thread
    end
end