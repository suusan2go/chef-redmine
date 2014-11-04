#
# Cookbook Name:: ruby
# Recipe:: default
#
# Copyright 2014, YOUR_COMPANY_NAME
#
# All rights reserved - Do Not Redistribute
#

REDMINE_VERSION='2.5-stable'
REDMINE_HOME='/var/lib/redmine'

bash "Development Tools install" do
 code <<-EOC
   yum -y groupinstall "Development Tools"
 EOC
end

package "openssl-devel" do
 action :install
end

package "readline-devel" do
 action :install
end

package "zlib-devel" do
 action :install
end

package "curl-devel" do
 action :install
end

package "libyaml-devel" do
 action :install
end

package "ImageMagick" do
 action :install
end

package "ImageMagick-devel" do
 action :install
end

package "ipa-pgothic-fonts" do
 action :install
end

subversion "redmine" do
    repository "http://svn.redmine.org/redmine/branches/#{REDMINE_VERSION}"
    destination "#{REDMINE_HOME}"
    action :sync
end


["/var/lib/redmine/config/database.yml","/var/lib/redmine/config/configuration.yml"].each do  |config|
 template config do
  owner "root"
  group "root"
  mode 0644
 end
end

bash "bundle install" do
 cwd "#{REDMINE_HOME}"
 code "bundle install --without development test --path vendor/bundle"
end

bash "init redmine" do
  cwd '/var/lib/redmine'
  code <<-EOC
    bundle exec rake generate_secret_token
    RAILS_ENV=production bundle exec rake db:migrate
  EOC
end

execute "change redmine dir" do
    cwd "#{REDMINE_HOME}"
    command "chown -R apache:apache #{REDMINE_HOME}"
end

# railsアプリケーションとしての設定
include_recipe "rails"

web_app "redmine" do
    cookbook "passenger_apache2"
    template "web_app.conf.erb"
    docroot "#{REDMINE_HOME}/public"
    server_name "hogehoge"
    server_aliases ["fugafuga", "hogefuga"]
    rails_env "production"
end
