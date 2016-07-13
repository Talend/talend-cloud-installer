require 'serverspec'
Dir[Pathname.new(File.dirname(__FILE__)).join('shared/**/*.rb')].each{ |f| require f }

set :backend, :exec
