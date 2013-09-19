require 'nsconfig'
require 'archivist/log'

module Archivist
    extend NSConfig
    self.config_path= File.join File.dirname(__FILE__), 'config'
    Archivist::SinatraRoot = File.dirname(__FILE__)
end
