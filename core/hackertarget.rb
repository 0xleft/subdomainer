require "net/http"

class HackerTarget
    def initialize(domain)
        @domain = domain
        @subdomains = []
    end

    def run
        uri = URI("https://api.hackertarget.com/hostsearch/?q=#{@domain}")
        response = Net::HTTP.get(uri)
        response.split("\n").each do |line|
            if line.include? @domain
                @subdomains << line.split(",")[0]
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