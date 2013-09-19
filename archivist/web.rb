require 'diffy'
require 'haml'
require 'sinatra/base'
require 'archivist-init'

ApplicationTitle = 'Archivist'

module Archivist::Web
    $0 = self.name
    Archivist::log_set_prefix(self.name)
    Archivist::log "--- Starting (#{Archivist[:environment]})"

    class App < Sinatra::Base
        def self.new(*)
            app = Rack::Auth::Digest::MD5.new(super) do |username|
                {Archivist[:web_username] => Archivist[:web_password]}[username]
            end
            app.realm  = self.name
            app.opaque = 'secretissecret'
            app
        end

        configure :production, :development do
            enable :logging
            set    :root, Archivist::SinatraRoot
            set    :views, File.join(Archivist::SinatraRoot,'views')
        end

        configure :development do
            require 'sinatra/reloader'
            register Sinatra::Reloader
        end

        helpers do
            def get_filename_from_archive(f)
                Archivist[:archive_path] + '/' + File.basename(f)
            end
        end

        get '/' do
            @files = Dir[Archivist[:archive_path] + '/*']
                     .sort{ |a,b| b <=> a }
                     .first(Archivist[:show_last_n])
                     .map{ |f| File.basename(f) }
            haml :archive
        end

        get '/file/:name' do
            content_type :text
            IO.read(get_filename_from_archive(params[:name]))
        end

        get '/diff/:from/:to' do
            @from = get_filename_from_archive(params[:from])
            @to   = get_filename_from_archive(params[:to])
            haml :diff
        end
    end
end
