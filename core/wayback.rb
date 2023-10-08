require "json"
require "net/http"
require 'proxied_request'
require "uri"

class Wayback
    def initialize(domain)
        @domain = domain
        @subdomains = []
    end

    def run(proxied)
        if proxied
            response = ProxiedRequest::HTTP.request("https://web.archive.org/cdx/search/cdx?url=*.#{@domain}/*&output=json&collapse=urlkey")
            response = response.body
        else
            uri = URI("https://web.archive.org/cdx/search/cdx?url=*.#{@domain}/*&output=json&collapse=urlkey")
            response = Net::HTTP.get(uri)
        end

        if response.include? "AdministrativeAccessControlException"
            return []
        end

        json = JSON.parse(response)
        json.each do |result|
            url = result[2].strip
            url = url.gsub("http://", "")
            url = url.gsub("https://", "")
            url = url.split("/")[0]
            url = url.split("?")[0]
            url = url.split(":")[0]
            url = url.split("@")[-1]

            if url.include? @domain
                @subdomains << url
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