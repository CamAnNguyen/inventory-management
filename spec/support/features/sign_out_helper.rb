module SignOutHelper
  def sign_out
    t('layouts.application.sign_out')
  end
end

RSpec.configure do |config|
  config.include SignOutHelper, type: :feature
end
