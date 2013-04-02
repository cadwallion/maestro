require 'open3'
require 'fileutils'

module Maestro
  class NginxConfigurator
    attr_reader :sites_path, :config_path, :config_file
    def initialize
      detect_config_path
    end

    def detect_config_path
      options = read_nginx_flags
      
      @config_file  = options['conf-path']
      @config_path = File.dirname @config_file
      @sites_path = File.join @config_path, '/sites'
    end

    def read_nginx_flags
      stdout, stderr, status = Open3.capture3('nginx -V')
      options = stderr.split(' --').inject({}) do |hash, option|
        key, val = option.split("=")
        hash[key] = val
        hash
      end
    end

    def add_vhost_for domain, directory
      if !Dir.exists? @sites_path
        create_sites_directory!
        add_include_to_nginx!
      end

      vhost = generate_vhost_from_template domain, directory
      File.write "#{@sites_path}/#{domain}", vhost
    end

    def create_sites_directory!
      FileUtils.mkdir_p @sites_path
    end

    def add_include_to_nginx!
      config_file = File.open @config_file, 'a'
      config_file << "include #{@sites_path}/*;\n"
      config_file.close
    end

    def generate_vhost_from_template server_name, root_directory
      template = File.read nginx_template
      template.sub! /SERVER_NAME/, server_name
      template.gsub! /DIRECTORY/, root_directory
      template.gsub! /UPSTREAM_NAME/, "#{server_name.gsub('.','_')}_app"

      template
    end

    def nginx_template
      File.dirname(__FILE__) + '/templates/nginx'
    end
  end
end
