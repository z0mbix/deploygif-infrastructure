require 'spec_helper'

describe group('deploygif') do
  it { should exist }
end

describe user('deploygif') do
  it { should exist }
  it { should belong_to_group 'deploygif' }
  it { should have_home_directory '/opt/deploygif' }
  it { should have_login_shell '/sbin/nologin' }
end

describe file('/opt/deploygif') do
  it { should be_directory }
  it { should be_owned_by 'www-data' }
  it { should be_grouped_into 'www-data' }
end

describe file('/opt/deploygif/.git') do
  it { should be_directory }
  it { should be_owned_by 'www-data' }
  it { should be_grouped_into 'www-data' }
end

describe package('curl') do
  it { should be_installed }
end

describe package('jq') do
  it { should be_installed }
end

describe command("/usr/share/luajit/bin/luarocks list") do
  its(:stdout) { should match /lua-resty-auto-ssl/ }
  its(:stdout) { should match /lua-resty-http/ }
  its(:exit_status) { should eq 0 }
end

describe file('/etc/ssl/resty-auto-ssl-fallback.crt') do
  it { should be_file }
  it { should be_owned_by 'root' }
  it { should be_grouped_into 'root' }
  it { should be_mode '644' }
end

describe file('/etc/ssl/resty-auto-ssl-fallback.key') do
  it { should be_file }
  it { should be_owned_by 'root' }
  it { should be_grouped_into 'root' }
  it { should be_mode '644' }
end

describe service('nginx') do
  it { should be_enabled }
  it { should be_running }
end

describe port(80) do
  it { should be_listening.with('tcp') }
end

# describe port(8999) do
#   it { should be_listening.with('tcp') }
# end
