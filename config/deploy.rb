require 'mina/bundler'
require 'mina/rails'
require 'mina/git'
# require 'mina/rbenv'  # for rbenv support. (http://rbenv.org)
# require 'mina/rvm'    # for rvm support. (http://rvm.io)

# Basic settings:
#   domain       - The hostname to SSH to.
#   deploy_to    - Path to deploy into.
#   repository   - Git repo to clone from. (needed by mina/git)
#   branch       - Branch name to deploy. (needed by mina/git)

#set :domain, 'schoolsclub.in'
set	:domain, '52.34.166.44'
set :deploy_to, '/var/www/schoolsclub'
set :repository, 'https://github.com/ajayp1221/nwsc.git'
set :branch, 'master'
set :user, 'ubuntu'
set :identity_file, 'OregonAJLive.pem'

# For system-wide RVM install.
#   set :rvm_path, '/usr/local/rvm/bin/rvm'

# Manually create these paths in shared/ (eg: shared/config/database.yml) in your server.
# They will be linked in the 'deploy:link_shared_paths' step.
set :shared_paths, ['config/app.php', 'tmp', 'logs','webroot/upload','webroot/.htaccess','webroot/robots.txt','webroot/fonts/font-awesome/fonts']

# Optional settings:
#   set :user, 'foobar'    # Username in the server to SSH to.
#   set :port, '30000'     # SSH port number.
#   set :forward_agent, true     # SSH forward_agent.

# This task is the environment that is loaded for most commands, such as
# `mina deploy` or `mina rake`.
task :environment do
  # If you're using rbenv, use this to load the rbenv environment.
  # Be sure to commit your .ruby-version or .rbenv-version to your repository.
  # invoke :'rbenv:load'

  # For those using RVM, use this to load an RVM version@gemset.
  # invoke :'rvm:use[ruby-1.9.3-p125@default]'
end

# Put any custom mkdir's in here for when `mina setup` is ran.
# For Rails apps, we'll make some of the shared paths that are shared between
# all releases.
task :setup => :environment do
  queue! %[mkdir -p "#{deploy_to}/#{shared_path}/logs"]
  queue! %[chmod g+rx,u+rwx "#{deploy_to}/#{shared_path}/logs"]

  queue! %[mkdir -p "#{deploy_to}/#{shared_path}/config"]
  queue! %[chmod g+rx,u+rwx "#{deploy_to}/#{shared_path}/config"]
  
  queue! %[mkdir -p "#{deploy_to}/#{shared_path}/webroot"]
  queue! %[chmod g+rx,u+rwx "#{deploy_to}/#{shared_path}/webroot"]
  
  queue! %[mkdir -p "#{deploy_to}/#{shared_path}/tmp"]
  queue! %[chmod g+rx,u+rwx "#{deploy_to}/#{shared_path}/tmp"]

  queue! %[touch "#{deploy_to}/#{shared_path}/config/app.php"]
  queue! %[touch "#{deploy_to}/#{shared_path}/webroot/robots.txt"]
  queue  %[echo "-----> Be sure to edit '#{deploy_to}/#{shared_path}/config/app.php' and '#{deploy_to}/#{shared_path}/webroot/robots.txt'."]

#  if repository
#    repo_host = repository.split(%r{@|://}).last.split(%r{:|\/}).first
#    repo_port = /:([0-9]+)/.match(repository) && /:([0-9]+)/.match(repository)[1] || '22'
#
#    queue %[
#      if ! ssh-keygen -H  -F #{repo_host} &>/dev/null; then
#        ssh-keyscan -t rsa -p #{repo_port} -H #{repo_host} >> ~/.ssh/known_hosts
#      fi
#    ]
#  end
end

desc "Deploys the current version to the server."
task :deploy => :environment do
  to :before_hook do
    # Put things to run locally before ssh
  end
  deploy do
    # Put things that will set up an empty directory into a fully set-up
    # instance of your project.
    invoke :'git:clone'
    invoke :'deploy:link_shared_paths'
    queue!  %[composer install]
    
    invoke :'deploy:cleanup'

    to :launch do
      queue!  %[cd #{deploy_to}/#{current_path}]
      queue!  %[composer dumpautoload -o]
      queue!  %[sudo php bin/cake.php plugin assets symlink]
      queue!  %[sudo service apache2 restart]
      #queue!  %[sudo php bin/cake.php migrations migrate]
    end
  end
end

# For help in making your deploy script, see the Mina documentation:
#
#  - http://nadarei.co/mina
#  - http://nadarei.co/mina/tasks
#  - http://nadarei.co/mina/settings
#  - http://nadarei.co/mina/helpers
