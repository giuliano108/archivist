$LOAD_PATH.unshift File.dirname(__FILE__)
require 'fileutils'
require 'listen'
require 'digest/sha1'
require 'archivist-init'

module Archivist::Watcher
    Signal.trap('TERM') do
        Archivist::log "--- Terminated"
        exit 0
    end

    $0 = self.name
    Archivist::log_set_prefix(self.name)

    # We only look for files that are being added to :incoming_path
    # As soon as they come in, they get moved to :archive_path
    @callback = Proc.new do |modified, added, removed|
        ts = Archivist::get_timestamp
        return unless added
        added.each do |incoming|
            temp_destination = File.join(Archivist[:archive_path],"#{ts}-#{File.basename incoming}")
            FileUtils.move(incoming, temp_destination)
            sha = Digest::SHA1.hexdigest IO.read(temp_destination)
            incoming_name = File.basename(incoming)
            destination = temp_destination.sub(/-#{Regexp.escape incoming_name}$/,"-#{sha}-#{incoming_name}")
            FileUtils.move(temp_destination, destination)
            Archivist::log "Archived \"#{incoming_name}\" as \"#{File.basename destination}\""
        end
    end

    Archivist::log "--- Starting (#{Archivist[:environment]})"
    Archivist::log "Watching for files in : #{Archivist[:incoming_path]}"
    Archivist::log "Archiving to          : #{Archivist[:archive_path]}"

    Listen.to(Archivist[:incoming_path])
          .change(&@callback)
          .start!

    Archivist::log "--- Stopped"
end
