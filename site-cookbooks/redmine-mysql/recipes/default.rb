#
# Cookbook Name:: redmine-mysql
# Recipe:: default
#
# Copyright 2014, YOUR_COMPANY_NAME
#
# All rights reserved - Do Not Redistribute
#

include_recipe "mysql::server"

cookbook_file "/etc/mysql/conf.d/mysql.cnf" do
    source "mysql.cnf"
    mode 0644
    notifies :restart, 'mysql_service[default]', :immediately
end

include_recipe "database::mysql"

# コネクション定義
mysql_connection_info = {
    :host => "localhost",
    :username => "root",
    :password => node['mysql']['server_root_password']
}

# redmine用のデータベース作成
mysql_database node['redmine']['db_name'] do
    connection mysql_connection_info
    action :create
end

# redmine用データベースのユーザを作成
mysql_database_user node['redmine']['user'] do
    connection mysql_connection_info
    password node['redmine']['password']
    database_name node['redmine']['db_name']
    privileges [:all]
    action [:create, :grant]
end
