#
# Cookbook Name:: deploygif
# Recipe:: default
#
# Copyright (c) 2016 z0mbix
#

# This is a lua based application so let's use openresty
include_recipe 'openresty'
# Install luarocks so we can install lua-resty-auto-ssl for letsencrypt
include_recipe 'openresty::luarocks'

# Required to use 'luarocks install'
package "curl"

# Install jq as it's superb for dealing with JSON
package "jq"

# This enables letsencrypt for openresty
openresty_luarock 'lua-resty-auto-ssl' do
  action :install
  version '0.8.0-1'
end

# Directory for letsencrypt configs/certs
directory '/etc/resty-auto-ssl' do
  owner 'root'
  group 'www-data'
  mode '0770'
end

# Required to allow nginx to start so it can get the letsencrypt cert
execute 'create_self_signed_cert' do
  command "openssl req -new -newkey rsa:2048 -days 3650 -nodes -x509 \
    -subj '/CN=sni-support-required-for-valid-ssl' \
    -keyout /etc/ssl/resty-auto-ssl-fallback.key \
    -out /etc/ssl/resty-auto-ssl-fallback.crt"
  creates '/etc/ssl/resty-auto-ssl-fallback.crt'
  action :run
end

# Create the deploygif group
group 'deploygif'

# Create the deploygif user
user 'deploygif' do
  home node['deploygif']['install_dir']
  shell '/sbin/nologin'
  group 'deploygif'
end

# Create a directory for the application (Default: /opt/deploygif)
directory node['deploygif']['install_dir'] do
  owner 'www-data'
  group 'www-data'
  mode '0750'
end

# Reload nginx (Doing this, as service['nginx'] doesn't work
# correctly with chefspec
execute "reload_nginx" do
  command "nginx -s reload"
  timeout 5
  action :nothing
end

# Run redis migrations
execute "run_migrations" do
  command "make migrate"
  cwd node['deploygif']['install_dir']
  user 'www-data'
  timeout 30
  action :nothing
end

# Clone the application from git
git node['deploygif']['install_dir'] do
  repository node['deploygif']['git_repo']
  revision node['deploygif']['git_branch']
  user 'www-data'
  group 'www-data'
  action :sync
  # notifies :reload, 'service[nginx]', :immediately
  notifies :run, 'execute[run_migrations]', :immediately
  notifies :run, 'execute[reload_nginx]', :immediately
end

# The openresty/nginx vhost configuration file
template "#{node['openresty']['dir']}/conf.d/deploygif.conf" do
  source 'nginx.conf.erb'
  owner 'root'
  group 'root'
  mode  '0640'
  variables(
    :servername => node['deploygif']['servername'],
    :install_dir => node['deploygif']['install_dir'],
    :log_dir => node['openresty']['log_dir']
  )
  # notifies :reload, 'service[nginx]', :immediately
  notifies :run, 'execute[reload_nginx]', :immediately
end
