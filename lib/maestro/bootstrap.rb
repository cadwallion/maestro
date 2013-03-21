module Maestro
  class Bootstrap
    attr_reader :project_name, :org_name, :app_type

    def initialize project_name, org_name, options = {}
      @project_name = project_name
      @org_name = org_name
      @app_type = options[:type]
    end

    def nginx_config
      template = File.read File.dirname(__FILE__) + '/templates/nginx'
      template.sub! /SERVER_NAME/, server_name
      template.gsub! /DIRECTORY/, "#{root_directory}"
      template.gsub! /UPSTREAM_NAME/, "#{project_name}_app"
      File.write "/usr/local/etc/nginx/sites-available/#{domain}", template
      FileUtils.ln_sf "/usr/local/etc/nginx/sites-available/#{domain}", "/usr/local/etc/nginx/sites-enabled/#{domain}"
    end

    def add_dns
      dns = File.read "/etc/hosts"
      dns.sub! /127.0.0.1\t(.*)\n/, "127.0.0.1\t\1 #{server_name}\n"
      if File.writable? "/etc/hosts"
        File.write "/etc/hosts", dns
      else
        puts "[WARNING] Cannot write to /etc/hosts, please add #{domain} to 127.0.0.1 entry in /etc/hosts!"
      end
    end

    def add_foreman_line
      sheet_music = read_maestro_sheet
      sheet_music << "#{org_name}_#{project_name}: #{startup_line}\n"
      File.write File.expand_path("~/.maestro"), sheet_music
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
      end
    end
  end
end
