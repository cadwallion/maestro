# Maestro

A gem designed to easily setup and startup reverse-proxied Rack apps.  Uses foreman to start apps.

## Installation

Add this line to your application's Gemfile:

    gem 'maestro'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install maestro

## Usage

Maestro comes with two commands: `maestro add` and `maestro start`.

### add

`maestro add ORGANIZATION/PROJECT`

This adds a `project.organization.dev` DNS entry to /etc/hosts, adds an nginx configuration, and a foreman entry
in a custom Procfile for all managed Maestro sheets.  The system assumes a ORGANIZATION/PROJECT structure held 
within a directory specified by `ENV['PROJECTS']`.  Therefore, if it is set to `/Users/cadwallion/code`, the root
is `/Users/cadwallion/code/ORGANIZATION/PROJECT`.


### start

`maestro start ORGANIZATION_PROJECT`

This starts the `PROJECT.ORGANIZATION` application using Foreman.  It reads the Procfile found at ~/.maestro and
attempts to start the app server up.  The app server type passed will determine what values are being written in
the Procfile.  To customize the startup script, edit `~/.maestro` with your changes.

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
