#
# Cookbook Name:: chef_install_configure_collectd 
# Recipe:: config-mongodb
#
# Function:
# This recipe can configure the mongodb plugin for collectd
#
# Copyright (c) 2015 SignalFx, Inc, All Rights Reserved.

require File.expand_path("../helper.rb", __FILE__)

include_recipe 'chef_install_configure_collectd::default'

install_python_pip

remote_file '/tmp/pymongo-3.0.3.tar.gz' do
  source 'https://files.pythonhosted.org/packages/bd/91/1857471b63eaa192127c985b29362c094ae925720d5571daf286222c9716/pymongo-3.0.3.tar.gz'
  owner "root"
  group "root"
  mode '0755'
  action :create
end

bash 'extract_module' do
  code <<-EOH
   pip-2.6 install /tmp/pymongo-3.0.3.tar.gz
  EOH
end

directory node['mongodb']['python_folder'] do
  action :create
  recursive true
end

template "#{node['mongodb']['python_folder']}/mongodb.py" do
  source 'mongodb.py.erb'
  notifies :restart, 'service[collectd]'
end

directory node['mongodb']['dbfile_folder'] do
  action :create
  recursive true
end

template "#{node['collectd_managed_conf_folder']}/10-mongodb.conf" do
  source '10-mongodb.conf.erb'
  variables({
    :python_folder => node['mongodb']['python_folder'],
    :hostname => node['mongodb']['hostname'],
    :port => node['mongodb']['port'],
    :user => node['mongodb']['user'],
    :password => node['mongodb']['password'],
    :database => node['mongodb']['database']
  })
  notifies :restart, 'service[collectd]'
end

start_collectd
