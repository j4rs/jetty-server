require 'java'

module Jetty

  def self.configure(configuration = Jetty.configuration)
    yield configuration if block_given?
    @@configuration = configuration
  end

  def self.configuration
    @@configuration ||= Jetty::Configuration.new
  end

  class Configuration

    # no debe ser requerido si no se usa spring
    attr_accessor :dispatcher_server_name
    attr_accessor :mode # :spring

    attr_accessor :port
    attr_accessor :webapp_dir
    attr_accessor :context_path

    def initialize
      @port = 8888
      @webapp_dir = Dir.pwd + "/web"
      @context_path = ""
      raise "The path #{@webapp_dir} does not exist" unless test ?d, @webapp_dir
      raise "The path #{@webapp_dir}/WEB-INF/lib does not exist" unless test ?d, @webapp_dir + "/WEB-INF/lib"
      Dir[
        File.expand_path(File.dirname(__FILE__)) + "/../../vendor/*.jar",
        File.expand_path(File.dirname(__FILE__))  + "/../../resources",
        @webapp_dir + "/WEB-INF/lib/*.jar"
      ].each { | f | $CLASSPATH << f }
    end

    def classpath=(cp)
      cp.each { |r| $CLASSPATH << r }
    end

  end

  module Server

    def self.start_jetty
      import 'org.eclipse.jetty.server.Server'
      import 'org.eclipse.jetty.webapp.WebAppContext'

      @@server = Server.new Jetty.configuration.port

      wac = WebAppContext.new
      wac.set_copy_web_dir true
      wac.set_context_path Jetty.configuration.context_path unless Jetty.configuration.context_path.empty?
      wac.set_descriptor Jetty.configuration.webapp_dir + "/WEB-INF/web.xml"
      wac.set_parent_loader_priority true
      wac.setResourceBase Jetty.configuration.webapp_dir

      @@server.set_handler wac
      @@server.start

      # solo si el modo es spring y se seteo el dispatcher_server_name
      @@app_ctx = wac.get_servlet_handler.get_servlet(Jetty.configuration.dispatcher_server_name).get_servlet_instance().get_web_application_context
    end

    def self.stop_jetty
      @@server.stop
    end

    # Solo se debe definir si se esta usando spring
    def get_bean(id)
      bean = @@app_ctx.get_bean id
      while bean.nil? do
        @@app_ctx = @app_ctx.get_parent
        bean = @app_ctx.get_bean id unless @app_ctx.nil?
      end
      return bean
    end

  end

end
