require 'spec_helper'

describe Maestro::NginxConfigurator do
  let(:nginx_flags) do
    { 'conf-path' => '/my/custom/dir/nginx/nginx.conf' }
  end

  before do
    Maestro::NginxConfigurator.any_instance.stub(:read_nginx_flags) { nginx_flags }
  end

  its(:config_path) { should == '/my/custom/dir/nginx' }
  its(:config_file) { should == '/my/custom/dir/nginx/nginx.conf' }
  its(:sites_path) { should == '/my/custom/dir/nginx/sites' }
end
