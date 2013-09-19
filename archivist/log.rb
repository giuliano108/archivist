require 'archivist/utils'

module Archivist
    @log_opened = false
    @log_prefix = ''

    def self.log_set_prefix(prefix)
        @log_prefix = prefix + ' '
    end

    def self.log(message)
        unless @log_opened
            $stdout.sync = true
            @log_opened  = true
        end
        puts Archivist::get_timestamp + ' ' + @log_prefix + message
    end
end
