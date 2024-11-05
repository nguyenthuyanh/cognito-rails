FactoryBot.define do
  factory :user do
    uuid { Faker::Internet.uuid }
    hs_contact_id { Faker::Internet.uuid }
    pl_client_id { Faker::Internet.uuid }
    first_name { Faker::Name.first_name }
    last_name { Faker::Name.last_name }
  end
end
