require 'fileutils'
require 'maestro/nginx_configurator'

module Maestro
  class Bootstrap
    attr_reader :project_name, :org_name, :app_type

    def initialize project_name, org_name, options = {}
      @project_name = project_name
      @org_name = org_name
      @app_type = options[:type]
      @nginx_config = NginxConfigurator.new
    end

    def add_nginx_vhost
      @nginx_config.add_vhost_for server_name, root_directory
    end

    def add_foreman_line
      sheet_music = read_maestro_sheet
      sheet_music << "#{org_name}_#{project_name}: #{startup_line}\n"
      File.write File.expand_path("~/.maestro"), sheet_music
    end

    def add_resolver
      if !File.exists? '/etc/resolver'
        FileUtils.mkdir '/etc/resolver'
      end

      IO.popen "sudo -i", 'r+' do |process|
        process.puts "echo 'nameserver 127.0.0.1' > /etc/resolver/#{project_name}.#{org_name}.dev"
        process.puts 'exit'
        process.close_write
        puts process.gets until process.eof?
      end
    end

    def server_name
      "#{domain}.dev"
    end

    def root_directory
      File.expand_path "#{ENV['PROJECTS']}/#{org_name}/#{project_name}"
    end

    def domain
      "#{project_name}.#{org_name}"
    end

    def read_maestro_sheet
      if File.exists? File.expand_path "~/.maestro"
        File.read File.expand_path "~/.maestro"
      else
        ""
      end
    end

    def startup_line
      case app_type
      when :thin
        "bundle exec thin start -S tmp/sockets/development.sock -P tmp/pids/development.pid"
      when :unicorn
        "bundle exec unicorn_rails -c config/unicorn.rb"
      when :rackup
        "rackup config.ru"
      end
    end
  end
end
