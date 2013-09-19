module Archivist
    def self.get_timestamp
        Time.now.strftime '%Y%m%d-%H%M%S'
    end
end
