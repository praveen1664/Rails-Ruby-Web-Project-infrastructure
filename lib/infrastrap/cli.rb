require 'thor'
require 'git'
require 'bundler'

module Infrastrap
  # Your code goes here...
  class CLI < ::Thor
    include Thor::Actions

    def self.source_root
      File.expand_path "#{__dir__}/../templates"
    end

    desc "generate source destination", "generate infrastructure from project"
    def generate(git_url, destination = nil)
      self.repo_url = git_url
      Dir.mktmpdir("infastrap") do |source_dir|
        last = git_url.split('/').last.gsub('.git','')
        source = "#{source_dir}/#{last}"
        say 'cloning repo'
        Git.clone(git_url, source, depth: 1)
        self.bundler_lockfile ||= Bundler::LockfileParser.new(Bundler.read_file("#{source}/Gemfile.lock"))
        self.project_name = File.basename(source)
        destination = File.expand_path(destination || "./#{project_name}-infrastructure")
        say "source: #{source}"
        say "destination: #{destination}"
        empty_directory destination
        template 'gitignore.erb', "#{destination}/.gitignore"
        template 'README.md.erb', "#{destination}/README.md"
        template 'Vagrantfile.rb.erb', "#{destination}/Vagrantfile"
        copy_file "ansible.cfg", "#{destination}/ansible.cfg"
        shell.indent do
          generate_ansible "#{destination}/ansible", source
        end
        shell.indent do
          generate_capistrano "#{destination}/capistrano", source
        end
      end
    end

    desc "generate_ansible source destination", "generate ansible code from project"
    def generate_ansible(destination = nil, source = "./")
      destination = File.expand_path(destination || "../ansible")
      self.bundler_lockfile ||= Bundler::LockfileParser.new(Bundler.read_file("#{source}/Gemfile.lock"))
      say "generating ansible at \"#{destination}\""
      empty_directory destination
      copy_file "ansible/ansible.cfg", "#{destination}/ansible.cfg"
      copy_file "ansible/vagrant.yml", "#{destination}/vagrant.yml"
      copy_file "ansible/requirements.yml", "#{destination}/requirements.yml"
      template "ansible/group_vars/vm.yml.erb", "#{destination}/group_vars/vm.yml"
      template "ansible/group_vars/all.yml.erb", "#{destination}/group_vars/all.yml"
      say "-- common role"
      shell.indent do
        directory "ansible/roles/common", "#{destination}/roles/common"
      end
      say "-- app role"
      shell.indent do
        copy_file "ansible/roles/app/tasks/main.yml", "#{destination}/roles/app/tasks/main.yml"
        copy_file "ansible/roles/app/tasks/install_ruby.yml", "#{destination}/roles/app/tasks/install_ruby.yml"
        template "ansible/roles/app/tasks/install_gem_dependencies.yml.erb", "#{destination}/roles/app/tasks/install_gem_dependencies.yml"
        unless gem_dependency_names.include?('therubyracer') || gem_dependency_names.include?('therubyrhino') || gem_dependency_names.include?('mini_racer')
          copy_file "ansible/roles/app/tasks/install_node.yml", "#{destination}/roles/app/tasks/install_node.yml"
          append_to_file "#{destination}/roles/app/tasks/main.yml", '- include: install_node.yml'
        end
      end
      say "-- deployment role"
      shell.indent do
        directory "ansible/roles/deployment", "#{destination}/roles/deployment"
        if File.exist?("#{ENV['HOME']}/.ssh/id_rsa.pub")
          append_to_file "#{destination}/roles/deployment/files/_deploy_home_/.ssh/authorized_keys" do
            File.read("#{ENV['HOME']}/.ssh/id_rsa.pub")
          end
        end
      end
      if gem_dependency_names.include?('pg')
        say "-- postgresql role"
        shell.indent do
          directory "ansible/roles/postgresql", "#{destination}/roles/postgresql"
        end
      end
    end

    desc "generate_capistrano source destination", "generate capistrano code from project"
    method_option :repo_url, :desc => "Git Repo url"
    def generate_capistrano(destination = nil, source = "./")
      destination = File.expand_path(destination || "../capistrano")
      self.bundler_lockfile ||= Bundler::LockfileParser.new(Bundler.read_file("#{source}/Gemfile.lock"))
      say "generating capistrano at \"#{destination}\""
      empty_directory destination
      copy_file "capistrano/Gemfile", "#{destination}/Gemfile"
      if gem_dependency_names.include?('rails')
        uncomment_lines "#{destination}/Gemfile", "capistrano-rails"
      end
      copy_file "capistrano/Capfile", "#{destination}/Capfile"
      uncomment_lines "#{destination}/Capfile", "\"capistrano/bundler"
      if gem_dependency_names.include?('rails')
        uncomment_lines "#{destination}/Capfile", "\"capistrano/rails"
      end
      template "capistrano/config/deploy/vagrant.rb.erb", "#{destination}/config/deploy/vagrant.rb"
      template "capistrano/config/deploy.rb.erb", "#{destination}/config/deploy.rb"
    end

    protected

    def repo_url=(v)
      @repo_url = v
    end

    def repo_url
      options[:repo_url] || @repo_url || ask("Please enter git repo url for deployment")
    end

    def bundler_lockfile=(p)
      @bundler_lockfile = p
    end

    def bundler_lockfile
      @bundler_lockfile
    end

    def gem_dependency_names
      bundler_lockfile.dependencies.map(&:name)
    end

    def project_name=(p)
      @project_name = p
    end

    def project_name
      @project_name || fail('no project name set')
    end

    def app_deploy_user
      project_name
    end

    def app_deploy_path
      "/home/#{app_deploy_user}/#{project_name}_app"
    end

    def vagrant_db_machine?
      gem_dependency_names.include?('pg')
    end

    def vagrant_machines
      return @machines if @machines
      require 'ostruct'
      machines = []
      if vagrant_db_machine?
        machines << {vm_name: 'db', memory: '256'}
      end
      machines << {vm_name: 'app', memory: '512'}
      machines.each_with_index do |hash,i|
        hash[:vm_ip] = "#{vagrant_ip_range}.#{i + 10}"
        hash[:vm_hostname] = "#{hash.fetch(:vm_name)}.#{project_name.gsub(/[^a-zA-Z\-]/,'-')}.vm"
      end
      @machines = machines.map{ |hash| OpenStruct.new(hash) }
    end

    def vagrant_app_machine
      vagrant_machines.find{|machine| machine.vm_name == 'app'}
    end

    def vagrant_db_machine
      vagrant_machines.find{|machine| machine.vm_name == 'db'}
    end

    def vagrant_ip_range
      @vagrant_ip_range ||= "192.#{rand(128) + 64}.#{rand(128) + 64}"
    end
  end
end