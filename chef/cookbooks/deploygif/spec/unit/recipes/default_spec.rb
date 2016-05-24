#
# Cookbook Name:: deploygif
# Spec:: default
#
# Copyright (c) 2016 The Authors, All Rights Reserved.

require 'spec_helper'

describe 'deploygif::default' do
  context 'When all attributes are default, on an unspecified platform' do
    let(:chef_run) do
      ChefSpec::SoloRunner.new() do |node|
      end.converge(described_recipe)
    end

    before do
      allow_any_instance_of(Chef::Recipe).to receive(:include_recipe).and_call_original
      allow_any_instance_of(Chef::Recipe).to receive(:include_recipe).with('openresty')
      allow_any_instance_of(Chef::Recipe).to receive(:include_recipe).with('openresty::luarocks')
    end

    it "includes the openresty cookbook" do
      expect_any_instance_of(Chef::Recipe)
        .to receive(:include_recipe).with('openresty')
      chef_run
    end

    it 'installs curl' do
      expect(chef_run).to install_package('curl')
    end

    it 'installs jq' do
      expect(chef_run).to install_package('jq')
    end

    # it 'installs luarocks' do
    #   expect(chef_run).to install_openresty_luarock('lua-resty-auto-ssl')
    # end

    it 'creates the directory /etc/resty-auto-ssl' do
      expect(chef_run).to create_directory('/etc/resty-auto-ssl').with(
        user:  'root',
        group: 'www-data',
        mode:  '0770'
      )
    end

    it 'creates a self-signed certificate' do
      expect(chef_run).to run_execute('create_self_signed_cert').with(
        creates: '/etc/ssl/resty-auto-ssl-fallback.crt'
      )
    end

    it 'creates the deploygif group' do
      expect(chef_run).to create_group('deploygif')
    end

    it 'creates the deploygif user with shell \'/sbin/nologin\' and belong to group \'deploygif\'' do
      expect(chef_run).to create_user('deploygif').with(
        shell: '/sbin/nologin',
        group: 'deploygif'
      )
    end

    it 'creates the directory /opt/deploygif with user/group www-data and mode 0750' do
      expect(chef_run).to create_directory('/opt/deploygif').with(
        user:  'www-data',
        group: 'www-data',
        mode:  '0750'
      )
    end

    it 'creates the file /etc/nginx/conf.d/deploygif.conf as user root, mode 0640 and reload nginx' do
      expect(chef_run).to create_template('/etc/nginx/conf.d/deploygif.conf').with(
        owner:  'root',
        group:  'root',
        mode:   '0640',
        source: 'nginx.conf.erb'
      )
      template = chef_run.template('/etc/nginx/conf.d/deploygif.conf')
      expect(template).to notify("execute[reload_nginx]").to(:run).immediately
    end

    it 'executes \'nginx -s reload\' when the nginx vhost template changes' do
      execute = chef_run.execute('reload_nginx')
      expect(execute).to do_nothing #.with(cmd: 'nginx -s reload')
      expect(execute.command).to eq('nginx -s reload')
    end

    it 'executes \'make migrate\' when git pulls new commits' do
      execute = chef_run.execute('run_migrations')
      expect(execute).to do_nothing
      expect(execute.command).to eq('make migrate')
    end

    it 'checks out the git repo https://github.com/z0mbix/deploygif.git as user/group www-data and reload nginx' do
      expect(chef_run).to sync_git('/opt/deploygif').with(
        repository: 'https://github.com/z0mbix/deploygif.git',
        revision: 'master',
        user: 'www-data',
        group: 'www-data'
      )
      sync_git = chef_run.git('/opt/deploygif')
      expect(sync_git).to notify("execute[reload_nginx]").to(:run).immediately
    end
  end
end
