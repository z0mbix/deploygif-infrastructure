current_dir = File.dirname(__FILE__)

user                     "z0mbix"

log_level                :info
log_location             STDOUT
chef_server_url          "https://api.opscode.com/organizations/#{ENV['CHEF_ORGNAME']}"
node_name                user
client_key               "#{ENV['HOME']}/.chef/#{user}.pem"
validation_client_name   "#{ENV['CHEF_ORGNAME']}-validator"
validation_key           "#{ENV['HOME']}/.chef/#{ENV['CHEF_ORGNAME']}-validator.pem"
chef_server_url          "https://api.opscode.com/organizations/#{ENV['CHEF_ORGNAME']}"
syntax_check_cache_path  "#{ENV['HOME']}/.chef/syntax_check_cache"
cache_options(:path => "#{ENV['HOME']}/.chef/checksums")
cookbook_path            ["#{current_dir}/cookbooks"]
cookbook_copyright       "z0mbix.io"
cookbook_license         "MIT"
cookbook_email           "zombie@zombix.org"
