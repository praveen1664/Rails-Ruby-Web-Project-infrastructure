# Infrastrap

Looking for a quick way to bootstrap your Rails/Ruby Web Project infrastructure. 
_Infrastrap_ will help you get quickly started by generating you infrastructure 
by looking at you Gemfile and project code.

## Installation

    $ gem install infrastrap

## Usage

Inside your Rails or Ruby Project Directory run the following

    $ infrastrap generate
    
For More options run:

    $ infrastrap help generate

## Development

After checking out the repo, run `bin/setup` to install dependencies. 
Then, run `rake spec` to run the tests. You can also run `bin/console` for an 
interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. 
To release a new version, update the version number in `version.rb`, 
and then run `bundle exec rake release`, which will create a git tag for the version, 
push git commits and tags, and push the `.gem` file to 
[rubygems.org](https://rubygems.org).

## TODO

* Terraform (AWS and Digital Ocean)
* Apache and Ngnix
* MySQL
* Multiple ruby versions (including Jruby and Rubinius)
* Redis
* NewRelic
* Nagios
* Mailcatcher
* Staging Environments
* Vagrant development Environment
* Multiple Servers (With Load Balancer) and/or Single Servers
* Sqlite





