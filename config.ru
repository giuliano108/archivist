$LOAD_PATH.unshift File.dirname(__FILE__)
require 'archivist/web'

run Archivist::Web::App
