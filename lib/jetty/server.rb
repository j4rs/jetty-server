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
    attr_accessor :dispatcher_server_name
    attr_accessor :port
    attr_accessor :webapp_dir

    def initialize
      self.port = 8888
      self.webapp_dir = "web"
      Dir[
        File.expand_path(File.dirname(__FILE__)) + "/../../vendor/*.jar",
        File.expand_path(File.dirname(__FILE__))  + "/../../resources"
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
      wac.set_descriptor Jetty.configuration.webapp_dir + "/WEB-INF/web.xml"
      wac.set_parent_loader_priority true
      wac.setResourceBase Jetty.configuration.webapp_dir

      @@server.set_handler wac
      @@server.start
      @@app_ctx = wac.get_servlet_handler.get_servlet(Jetty.configuration.dispatcher_server_name).get_servlet_instance().get_web_application_context
    end

    def self.stop_jetty
      @@server.stop
    end

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