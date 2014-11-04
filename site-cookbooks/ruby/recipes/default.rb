#
# Cookbook Name:: ruby
# Recipe:: default
#
# Copyright 2014, YOUR_COMPANY_NAME
#
# All rights reserved - Do Not Redistribute
#

# 対象versionのrubyがインストールされている場合はtrue、されていない場合はfalse
#is_installed_ruby = { /2\.0\.0p451/ =~ ruby_version } ? true : false

cookbook_file "/tmp/ruby-2.0.0-p451.tar.gz" do
  not_if { File.exists?("/tmp/ruby-2.0.0-p451.tar.gz") }
  source "ruby-2.0.0-p451.tar.gz"
end

bash "install ruby" do
  
  not_if '/usr/local/bin/ruby -v | grep "2.0.0p451"'

  cwd '/tmp'
  code <<-EOC
     tar zxvf ruby-2.0.0-p451.tar.gz
     cd ruby-2.0.0-p451
     ./configure --disable-install-doc
     make
     make install 
  EOC
end

#bundlerのインストール
gem_package 'bundler' do
 action :install
 gem_binary("/usr/local/bin/gem")
end
