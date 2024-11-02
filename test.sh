#!/usr/bin/env bash
bin/rspec spec
cd tmp/ansible
ansible-galaxy install -r requirements.yml
cd ..
vagrant reload --provision
cd capistrano
bundle install --path vendor
bundle exec cap vagrant deploy
cd ..