require File.expand_path(File.dirname(__FILE__) + "/lib/jetty")

spec = Gem::Specification.new do |s|
  s.name = 'jetty'
  s.version = Jetty::VERSION
  s.summary = "Jetty Server Gem"
  s.description = %{Simple gem to embbed the jetty java application server}
  s.files = Dir['lib/**/*.rb'] + Dir['test/**/*.rb'] + Dir['vendor/**.jar']
  s.require_path = 'lib'
  s.autorequire = 'builder'
  s.has_rdoc = true
  s.extra_rdoc_files = Dir['[A-Z]*']
  s.rdoc_options << '--title' <<  'Builder -- Easy XML Building'
  s.author = "Jorge Rodriguez"
  s.email = "jars@continuum.cl"
  s.homepage = "http://continuum.cl"
end
