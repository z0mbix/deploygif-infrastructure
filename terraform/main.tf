## VARIABLES ##

# Stack name
variable "stack_name" {
    default = "deploygif"
}

# Chef Organisation
variable "chef_org" {}

# DigitalOcean Droplet image
variable "droplet_image" {
    #default = "ubuntu-14-04-x64"
    default = "ubuntu-16-04-x64"
}

# DigitalOcean Droplet type
variable "droplet_type" {
    default = "lon1"
}

# DigitalOcean Droplet size
variable "droplet_size" {
    default = "512mb"
}

# SSH Public Key
variable "ssh_key_file" {
    default = "~/.ssh/deploygif.pub"
}

# Number of web nodes to create
variable "web_node_count" {
    default = 1
}

# Import our common module that contains our
# Chef validation key
module "common" {
    source = "./modules/common"
}


## RESOURCES ##

# Add the SSH public key to DigitalOcean
resource "digitalocean_ssh_key" "sshkey" {
    name = "${var.stack_name}"
    public_key = "${file(var.ssh_key_file)}"
}

# Create the web server(s)
resource "digitalocean_droplet" "web" {
    image = "${var.droplet_image}"
    name = "${var.stack_name}-${count.index + 1}"
    region = "${var.droplet_type}"
    size = "${var.droplet_size}"
    count = "${var.web_node_count}"
    ssh_keys = [ "${digitalocean_ssh_key.sshkey.id}" ]
    user_data = <<EOF
#cloud-config
chef:
  install_type: "omnibus"
  server_url: "https://api.opscode.com/organizations/${var.chef_org}"
  node_name: "${var.stack_name}${count.index+1}"
  run_list:
    - role[deploygif]
  validation_cert: |
${module.common.validation_key}
  validation_name: "${var.chef_org}-validator"
  exec: true
  delete_validation_post_exec: true
runcmd:
  - curl -s -L https://omnitruck.chef.io/install.sh | sudo bash
  - while [ ! -e /usr/bin/chef-client ]; do sleep 5; done; chef-client -i 60 -d
output: {all: '| tee -a /var/log/cloud-init-output.log'}
disable_ec2_metadata: true
EOF
}

# Output the IP address of where to find the service
output "url" {
    value = "http://${digitalocean_droplet.web.ipv4_address}/"
}

# Output how to connect to the new server
output "ssh" {
    value = "ssh -i ${var.ssh_key_file} root@${digitalocean_droplet.web.ipv4_address}"
}
