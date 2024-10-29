class User < ApplicationRecord
  COGNITO_MAPPING = {
    "sub" => :uuid,
    "given_name" => :first_name,
    "family_name" => :last_name,
    "email" => :email,
    "phone_number" => :phone,
    "custom:hubspot_contact_id" => :hs_contact_id,
  }.freeze

  attr_accessor :first_name, :last_name, :email, :phone
end
