require "spec_helper"

describe Infrastrap do
  it "has a version number" do
    expect(Infrastrap::VERSION).not_to be nil
  end
end

describe Infrastrap::CLI do
  describe 'generate' do
    before :all do
      cli = Infrastrap::CLI.new
      @repo_url = 'https://github.com/grantspeelman/simple_rails_pg.git'
      cli.generate(@repo_url, 'tmp')
    end

    it 'creates README.md' do
      expect(File).to exist("tmp/README.md")
    end

    it 'creates .gitignore' do
      expect(File).to exist("tmp/.gitignore")
    end

    describe 'vagrant' do
      describe 'ansible.cfg' do
        let(:filename) {"tmp/ansible.cfg"}

        it 'creates it' do
          expect(File).to exist(filename)
        end
      end

      describe 'Vagrantfile' do
        let(:filename) {"tmp/Vagrantfile"}
        let(:file_contents) {File.read filename}

        it 'creates it' do
          expect(File).to exist(filename)
        end

        it 'changes box to ubuntu/xenial64' do
          expect(file_contents).to include("config.vm.box = \"ubuntu/xenial64\"")
        end

        it 'adds db vm' do
          expect(file_contents).to include("hostname = \"db.simple-rails-pg.vm\"")
        end

        it 'adds app vm' do
          expect(file_contents).to include("hostname = \"app.simple-rails-pg.vm\"")
        end
      end
    end

    describe 'capistrano' do
      let(:capistrano_dir) { "tmp/capistrano" }

      it 'creates Gemfile' do
        expect(File).to exist("#{capistrano_dir}/Gemfile")
      end

      it 'creates Capfile' do
        expect(File).to exist("#{capistrano_dir}/Capfile")
      end

      it 'creates config/deploy/vagrant.rb' do
        expect(File).to exist("#{capistrano_dir}/config/deploy/vagrant.rb")
      end

      it 'creates config/deploy.rb' do
        expect(File).to exist("#{capistrano_dir}/config/deploy.rb")
      end

      it 'sets the repo_url in config/deploy.rb' do
        file_contents = File.read "#{capistrano_dir}/config/deploy.rb"
        expect(file_contents).to include(@repo_url)
      end
    end


    describe 'ansible' do
      let(:ansible_dir) { "tmp/ansible" }

      it 'creates ansible.cfg' do
        expect(File).to exist("#{ansible_dir}/ansible.cfg")
      end

      it 'creates vagrant.yml' do
        expect(File).to exist("#{ansible_dir}/vagrant.yml")
      end

      it 'creates requirements.yml' do
        expect(File).to exist("#{ansible_dir}/requirements.yml")
      end

      it 'creates group_vars/vm.yml' do
        expect(File).to exist("#{ansible_dir}/group_vars/vm.yml")
      end

      it 'creates group_vars/all.yml' do
        expect(File).to exist("#{ansible_dir}/group_vars/all.yml")
      end

      describe 'common role' do
        let(:role_dir) { "#{ansible_dir}/roles/common" }
        let(:main_yml_contents) {File.read "#{role_dir}/tasks/main.yml" }

        it 'updates apt cache' do
          expect(File).to exist("#{role_dir}/tasks/main.yml")
          expect(main_yml_contents).to include("apt: update_cache=yes")
        end
      end

      describe 'app role' do
        let(:role_dir) { "#{ansible_dir}/roles/app" }
        let(:main_yml_contents) {File.read "#{role_dir}/tasks/main.yml" }

        it 'add install_ruby.yml' do
          expect(File).to exist("#{role_dir}/tasks/install_ruby.yml")
          expect(main_yml_contents).to include("install_ruby.yml")
        end

        it 'add install_gem_dependencies.yml' do
          expect(File).to exist("#{role_dir}/tasks/install_gem_dependencies.yml")
          expect(main_yml_contents).to include("install_gem_dependencies.yml")
        end

        it 'add install_node.yml' do
          expect(File).to exist("#{role_dir}/tasks/install_node.yml")
          expect(main_yml_contents).to include("install_node.yml")
        end
      end

      describe 'deployment role' do
        let(:role_dir) { "#{ansible_dir}/roles/deployment" }
        let(:main_yml_contents) {File.read "#{role_dir}/tasks/main.yml" }

        it 'add create_deploy_user.yml' do
          expect(File).to exist("#{role_dir}/tasks/create_deploy_user.yml")
          expect(main_yml_contents).to include("create_deploy_user.yml")
        end

        it 'add setup-bundler.yml' do
          expect(File).to exist("#{role_dir}/tasks/setup-bundler.yml")
          expect(main_yml_contents).to include("setup-bundler.yml")
        end

        it 'add placeholer_app.yml' do
          expect(File).to exist("#{role_dir}/tasks/placeholder_app.yml")
          expect(main_yml_contents).to include("placeholder_app.yml")
        end

        it 'add install_service.yml' do
          expect(File).to exist("#{role_dir}/tasks/install_service.yml")
          expect(main_yml_contents).to include("install_service.yml")
        end

        it 'add set_enviroment_variables.yml' do
          expect(File).to exist("#{role_dir}/tasks/set_enviroment_variables.yml")
          expect(main_yml_contents).to include("set_enviroment_variables.yml")
        end
      end

      describe 'postgresql role' do
        let(:role_dir) { "#{ansible_dir}/roles/postgresql" }
        let(:main_yml_contents) {File.read "#{role_dir}/tasks/main.yml" }

        it 'add pg_install.yml' do
          expect(File).to exist("#{role_dir}/tasks/install.yml")
          expect(main_yml_contents).to include("install.yml")
        end

        it 'add create_database.yml' do
          expect(File).to exist("#{role_dir}/tasks/create_database.yml")
          expect(main_yml_contents).to include("create_database.yml")
        end

        it 'add setup_backups.yml' do
          expect(File).to exist("#{role_dir}/tasks/setup_backups.yml")
          expect(main_yml_contents).to include("setup_backups.yml")
        end
      end
    end
  end
end
