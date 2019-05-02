class ApplicationMailer < ActionMailer::Base
  default from: ENV['AACT_OWNER_EMAIL'] || 'aact-owner@email.com'
  layout 'mailer'

  def self.admin_addresses
    addrs = ENV['AACT_ADMIN_EMAILS'] || []
    addrs.split(",")
  end

end
