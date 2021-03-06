require 'thor'
module Maestro
  class CLI < Thor
    include Thor::Actions

    desc 'add', "Adds an application to Maestro"
    method_option :type, default: "unicorn", aliases: '-app', desc: 'App server type (unicorn, thin, etc)'
    def add name
      org_name, project_name = name.split("/")
      bootstrap = Bootstrap.new project_name, org_name, type: options[:type].to_sym
      puts "Adding nameserver resolution to /etc/resolver..."
      bootstrap.add_resolver
      puts "Adding nginx conf for #{project_name}.#{org_name}.dev..."
      bootstrap.add_nginx_vhost
      puts "Adding #{options[:type]} config to Maestro startup scripts..."
      bootstrap.add_foreman_line
      puts "Done! You may start this app with `maestro start articulate.codename`."
    end

    desc 'start', "Starts an application using Foreman"
    def start name
      app_directory = "#{ENV['PROJECTS']}/#{name.sub(/[\._]/, '/')}"
      IO.popen  "foreman start #{name} -f ~/.maestro -d #{app_directory} -c" do |process|
        Signal.trap('INT') { Process.kill 'INT', process.pid }
        Signal.trap('TERM') { Process.kill 'TERM', process.pid }
        puts process.gets until process.eof?
      end
    end
  end
end
