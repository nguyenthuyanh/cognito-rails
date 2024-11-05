require "rails_helper"

RSpec.describe User, type: :model do
  subject(:user) { build(:user) }

  describe "#validates" do
    context "with valid attributes" do
      it "is valid" do
        user.valid?
        expect(user.errors).to be_empty
      end
    end

    it { is_expected.to validate_presence_of(:uuid) }
    it { is_expected.to validate_uniqueness_of(:hs_contact_id) }
    it { is_expected.to validate_uniqueness_of(:pl_client_id) }
  end
end
