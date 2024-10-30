class User < ApplicationRecord
  COGNITO_MAPPING = {
    "sub" => :uuid,
    "username" => :user_name,
    "given_name" => :first_name,
    "family_name" => :last_name,
    "email" => :email,
    "phone_number" => :phone,
    "custom:hubspot_contact_id" => :hs_contact_id,
  }.freeze

  attr_accessor :first_name, :last_name, :email, :phone

  validates :uuid, uniqueness: true, presence: true
  validates :hs_contact_id, :pl_client_id, uniqueness: true
end
