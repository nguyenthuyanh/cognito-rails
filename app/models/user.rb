class User < ApplicationRecord
  attr_accessor :first_name, :last_name, :email, :phone

  validates :uuid, uniqueness: true, presence: true
  validates :hs_contact_id, :pl_client_id, uniqueness: true
end
