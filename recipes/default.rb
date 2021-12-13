def get_collectd_conf_folder
  case node['platform_family']
    when 'rhel', 'amazon'
      return '/etc/collectd.d'
    when 'debian'
      return '/etc/collectd'
  end
end

def get_collectd_conf_file
  case node['platform_family']
    when 'rhel', 'amazon'
      return '/etc/collectd.conf'
    when 'debian'
      return '/etc/collectd/collectd.conf'
  end
end

# required to work around issue with collectd logging on centos 7
if node['platform'] == 'centos' and node['platform_version'].to_f >= 7.0
    node.override['SignalFx']['collectd']['logfile']['File'] =  "stdout"
end

node.default['collectd_conf_file'] = get_collectd_conf_file
node.default['collectd_conf_folder'] = get_collectd_conf_folder
node.default['collectd_managed_conf_folder'] = "#{node['collectd_conf_folder']}/managed_config"
node.default['collectd_filtering_conf_folder'] = "#{node['collectd_conf_folder']}/filtering_config"

if node.key?(:hudl) and node[:hudl].fetch(:patch_signalfx_installation, false)
  remote_file '/tmp/SignalFx-collectd-RPMs-AWS_EC2_Linux-release-latest.noarch.rpm' do
    source 'https://dl.signalfx.com/rpms/SignalFx-rpms/release/SignalFx-collectd-RPMs-AWS_EC2_Linux-release-latest.noarch.rpm'
    action :create
  end

  remote_file '/tmp/SignalFx-collectd_plugin-RPMs-AWS_EC2_Linux-release-latest.noarch.rpm' do
    source 'https://dl.signalfx.com/rpms/SignalFx-rpms/release/SignalFx-collectd_plugin-RPMs-AWS_EC2_Linux-release-latest.noarch.rpm'
    action :create
  end

  yum_package 'signalfx-collectd-repo' do
    source '/tmp/SignalFx-collectd-RPMs-AWS_EC2_Linux-release-latest.noarch.rpm'
    action :install
  end

  yum_package 'signalfx-collectd-plugins-repo' do
    source '/tmp/SignalFx-collectd_plugin-RPMs-AWS_EC2_Linux-release-latest.noarch.rpm'
    action :install
  end

  ['collectd', 'collectd-disk'].each do |package|
    yum_package package do
      action :install
    end
  end
else
  include_recipe 'chef_install_configure_collectd::install-collectd'
end
include_recipe 'chef_install_configure_collectd::config-collectd'
include_recipe 'chef_install_configure_collectd::config-signalfx'

