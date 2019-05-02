namespace :db do

  task create: [:environment] do
    db_name  = ENV['AACT_BACK_DATABASE_NAME'] || 'aact_back'
    Rake::Task["db:create"].invoke
    con=ActiveRecord::Base.connection
    con.execute("CREATE SCHEMA ctgov;")
    con.execute("CREATE SCHEMA support;")
    con.execute("ALTER ROLE #{ENV['AACT_DB_SUPER_USERNAME']} IN DATABASE #{db_name} SET SEARCH_PATH TO ctgov, support, public;")
    con.reset!
  end
end

