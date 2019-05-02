class PublicBase < ActiveRecord::Base
  hostname=ENV['AACT_PUBLIC_HOSTNAME'] || 'localhost'
  dbname=ENV['AACT_PUBLIC_DATABASE_NAME'] || 'aact'
  url ="postgres://#{ENV['AACT_DB_SUPER_USERNAME']}@#{hostname}:5432/#{dbname}"
  establish_connection(url)
  self.abstract_class = true
end
