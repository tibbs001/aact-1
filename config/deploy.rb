# config valid only for current version of Capistrano
lock "3.8.2"
set :chruby_ruby, 'ruby-2.4.5'

set :application, "aact"

# Default branch is :master
ask :branch, 'development'
set :rails_env, 'development'

namespace :deploy do
  after :deploy, 'finish_up'
end

desc 'Finalize the deployment'
task :finish_up do
  on roles(:app) do
    require 'util/file_manager'
    # create symlink to to the root directory containing aact static files
    # content of this directory can get big; we create this directory on a separate NAS drive
    source = ENV.fetch('AACT_STATIC_FILE_DIR','/aact-files')
    if ! File.exists?(source)
      require 'fileutils'
      fu=FileUtils.new
      fu.mkdir source
      fu.mkdir_p "#{source}/static_db_copies/daily"
      fu.mkdir_p "#{source}/static_db_copies/monthly"
      fu.mkdir_p "#{source}/exported_files/daily"
      fu.mkdir_p "#{source}/exported_files/monthly"
      fu.mkdir_p "#{source}/db_backups"
      fu.mkdir_p "#{source}/documentation"
      fu.mkdir_p "#{source}/logs"
      fu.mkdir_p "#{source}/tmp"
      fu.mkdir_p "#{source}/other"
      fu.mkdir_p "#{source}/xml_downloads"
    end

    target = release_path.join('public/static')
    execute :ln, '-s', source, target
  end
end

# Default deploy_to directory is /var/www/my_app_name

# Default value for :format is :airbrussh.
#set :format, :airbrussh

# You can configure the Airbrussh format using :format_options.
# These are the defaults.
set :format_options, command_output: true, log_file: "#{ENV.fetch('STATIC_FILE_DIR','/aact-files')}/logs/capistrano_aact.log", color: :auto, truncate: :auto

# Default value for :pty is false
# set :pty, true

# Default value for :linked_files is []
# append :linked_files, "config/database.yml", "config/secrets.yml"

# Default value for linked_dirs is []
# append :linked_dirs, "log", "tmp/pids", "tmp/cache", "tmp/sockets", "public/system"

# Default value for default_env is {}

set :default_env, {
  'PATH' => '/usr/local/pgsql/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/snap/bin:/home/tibbs001/bin:/usr/local/share',
  'LD_LIBRARY_PATH' => ENV['LD_LIBRARY_PATH'],
  'APPLICATION_HOST' => 'localhost',
  'RUBY_VERSION' =>  'ruby 2.4.5',
  'GEM_HOME' => ENV['GEM_HOME'],
  'GEM_PATH' => ENV['GEM_PATH']
}

# Default value for keep_releases is 5
 set :keep_releases, 5
#
