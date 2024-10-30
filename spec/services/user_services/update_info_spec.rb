require "rails_helper"

RSpec.describe UserServices::UpdateInfo, type: :services do
  subject(:update_info) { described_class.call(object:, params:) }

  let(:object) { build(:user, uuid: params["sub"]) }
  let(:params) do
    User::COGNITO_MAPPING.keys.index_with do
      Faker::Lorem.characters(number: 10)
    end
  end

  describe "#call" do
    context "with cognito info" do
      it "create new user if not exists" do
        expect(update_info.user).to be_persisted
      end
    end
  end
end
