class TestMigration < ActiveRecord::Migration
  # Since we actually instantiate ActiveRecord::Migration to manage indexes as a batch,
  # when running spec tests, we need to have it point to the test database

  def connection
    url ="postgres://#{ENV['AACT_DB_SUPER_USERNAME']}@localhost:5432/aact_back_test"
    ActiveRecord::Base.establish_connection(url).connection
  end
end
