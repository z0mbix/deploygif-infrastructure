Deploygif Infrastructure
========================

## About

This repository contains the code to manage the [deploygif.com](deploygif.com) website and infrastructure.

[Terraform](https://terraform.io) is used to provision an instance on [Digital Ocean](https://digitalocean.com), and [Chef](https://www.chef.io) then installs and configures all the required services.

## Services

Deploygif is a simple lua application that runs on top of [OpenResty](https://openresty.org/en/). It retrieves a random URL of an animated gif from [redis](http://redis.io). The application code can be found on a separate GitHub repository ([z0mbix/deploygif](https://github.com/z0mbix/deploygif)).

## License

MIT