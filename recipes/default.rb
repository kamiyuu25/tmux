#
# Cookbook Name:: tmux
# Recipe:: default
#
# Copyright 2014, YOUR_COMPANY_NAME
#
# All rights reserved - Do Not Redistribute
#


%w(ncurses-devel gcc make).each do |pkg|
  package pkg do
    action :install
  end
end

libevent_name = "libevent-#{node['tmux']['libevent']['version']}"
remote_file "#{Chef::Config['file_cache_path']}/#{libevent_name}.tar.gz" do
  source   "https://github.com/downloads/libevent/libevent/#{libevent_name}.tar.gz"
  checksum node['tmux']['checksum']
  notifies :run, 'bash[install_libevent]', :immediately
end

bash 'install_libevent' do
  user 'root'
  cwd  Chef::Config['file_cache_path']
  code <<-EOH
      tar -zxf #{libevent_name}.tar.gz
      cd #{libevent_name}
      ./configure 
      make
      make install
      echo /usr/local/lib > /etc/ld.so.conf.d/libevent.conf
      ldconfig
    EOH
  action :nothing
end


tar_name = "tmux-#{node['tmux']['version']}"
remote_file "#{Chef::Config['file_cache_path']}/#{tar_name}.tar.gz" do
  source   "http://downloads.sourceforge.net/tmux/#{tar_name}.tar.gz"
  checksum node['tmux']['checksum']
  notifies :run, 'bash[install_tmux]', :immediately
end

bash 'install_tmux' do
  user 'root'
  cwd  Chef::Config['file_cache_path']
  code <<-EOH
      tar -zxf #{tar_name}.tar.gz
      cd #{tar_name}
      ./configure #{node['tmux']['configure_options'].join(' ')}
      make
      make install
    EOH
  action :nothing
end
