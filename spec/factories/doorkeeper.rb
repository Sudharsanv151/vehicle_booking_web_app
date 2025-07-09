FactoryBot.define do
  factory :oauth_application, class: 'Doorkeeper::Application' do
    name { "Test App" }
    redirect_uri { "https://example.com/callback" }
    scopes { "public" }
    uid { SecureRandom.hex(8) }
    secret { SecureRandom.hex(16) }
  end

  factory :access_token, class: 'Doorkeeper::AccessToken' do
    application { create(:oauth_application) }
    resource_owner_id { nil }
    scopes { "public" }
    expires_in { 2.hours }
    token { SecureRandom.hex(16) }
    created_at { Time.current }
  end
end
