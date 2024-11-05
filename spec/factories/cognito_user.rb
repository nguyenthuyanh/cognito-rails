FactoryBot.define do
  factory :cognito_user, class: Hash do
    defaults = {
      username: Faker::Internet.username,
      given_name: Faker::Name.first_name,
      family_name: Faker::Name.last_name,
      sub: Faker::Internet.uuid,
      phone_number: Faker::PhoneNumber.phone_number,
      "custom:hubspot_contact_id" => Faker::Internet.uuid,
    }

    skip_create
    initialize_with { defaults.merge(attributes).stringify_keys }
  end
end
