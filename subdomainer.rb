require_relative "core/urlscan.rb"
require_relative "core/wayback.rb"
require_relative "core/crt.rb"
require_relative "core/hackertarget.rb"

class Subdomainer
    def initialize(domain)
        @domain = domain
        @subdomains = []
    end

    def run
        threads = []
        threads << Urlscan.new(@domain).get_thread
        threads << Crt.new(@domain).get_thread
        threads << HackerTarget.new(@domain).get_thread
        threads << Wayback.new(@domain).get_thread

        threads.each do |thread|
            thread.join
            result = thread[:result]
            if result
                @subdomains += result
            end
        end

        @subdomains.uniq!
        return @subdomains
    end
end

if __FILE__ == $0
    domain = ARGV[0]

    subdomains = Subdomainer.new(domain).run
    puts subdomains
end