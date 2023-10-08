require "json"
require "net/http"

class Wayback
    def initialize(domain)
        @domain = domain
        @subdomains = []
    end

    def run
        uri = URI("https://web.archive.org/cdx/search/cdx?url=*.#{@domain}/*&output=json&collapse=urlkey")
        response = Net::HTTP.get(uri)
        # if 403
        if response.include? "AdministrativeAccessControlException"
            return []
        end

        json = JSON.parse(response)
        json.each do |result|
            url = result[2]
            url = url.gsub("http://", "")
            url = url.gsub("https://", "")
            url = url.split("/")[0]

            if url.include? @domain
                @subdomains << url
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