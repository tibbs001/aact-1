class PublicAltBase < ActiveRecord::Base
  establish_connection(AACT::Application::AACT_ALT_PUBLIC_DATABASE_URL)
  self.abstract_class = true

    def self.database_exists?
      begin
        PublicBase.connection
      rescue ActiveRecord::NoDatabaseError
        false
      else
        true
      end
    end

end
