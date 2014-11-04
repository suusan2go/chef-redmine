#
# Cookbook Name:: Passenger
# Recipe:: default
#
# Copyright 2014, YOUR_COMPANY_NAME
#
# All rights reserved - Do Not Redistribute
#
include_recipe "apache2"

include_recipe "build-essential"
node.default['passenger']['apache_mpm'] = "prefork"

case node['platform_family']
when "arch"
    package 'apache'
when "rhel"
    package "httpd-devel"
    if node['platform-family'].to_f < 6.0
        package 'curl-devel'
    else
        package 'libcurl-devel'
        package 'openssl-devel'
        package 'zlib-devel'
    end
else
    apache_development_package = if %w( worker threaded ).include? node['passenger']['apache_mpm']
                'apache2-threaded-dev'
            else
                'apache2-prefork-dev'
            end
    %W( #{apache_development_package} libapr1-dev libcurl4-gnutls-dev ).each do |pkg|
        package pkg do
            action :upgrade
        end
    end
end


gem_package "passenger" do
 action :install
 gem_binary("/usr/local/bin/gem")
end

bash "passenger_module" do
    code <<-CODE
        passenger-install-apache2-module --auto
    CODE
end

ruby_block "passenger variables set" do
    block do
        #テンプレートの設定値をrbenvのパスへ上書きする
        passenger_version = %x[/usr/local/bin/gem list passenger | awk -F '[()]'  '{ print $2 }'].chomp
        node.default['rbenv']['gems_dir'] = %x[/usr/local/bin/gem environment gemdir].chomp
        node.default['passenger']['root_path'] = "#{node['rbenv']['gems_dir']}/gems/passenger-#{passenger_version}"
        node.default['passenger']['module_path'] = "#{node['passenger']['root_path']}/buildout/apache2/mod_passenger.so"
    end
end


template "#{node['apache']['dir']}/mods-available/passenger.load" do
    cookbook "passenger_apache2"
    source "passenger.load.erb"
    owner "root"
    group "root"
    mode 0644
end

template "#{node['apache']['dir']}/mods-available/passenger.conf" do
    cookbook "passenger_apache2"
    source "passenger.conf.erb"
    owner "root"
    group "root"
    mode 0644
end

link "#{node['apache']['dir']}/mods-enabled/passenger.load" do
    to "#{node['apache']['dir']}/mods-available/passenger.load"
end

link "#{node['apache']['dir']}/mods-enabled/passenger.conf" do
    to "#{node['apache']['dir']}/mods-available/passenger.conf"
end
