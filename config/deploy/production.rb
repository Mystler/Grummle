server "mystler.eu", user: "mystler", roles: %w{web app db}
set :rvm_custom_path, "/usr/share/rvm"
set :rails_env, "production"
set :deploy_to, "/home/mystler/apps/Grummle"
