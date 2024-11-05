require "rails_helper"

RSpec.describe UserServices::UpdateInfo, type: :services do
  subject(:update_info) { described_class.call(object:, params:) }

  let(:object) { build(:user, uuid: params["sub"]) }
  let(:params) do
    described_class::COGNITO_MAPPING.keys.index_with do
      Faker::Lorem.characters(number: 10)
    end
  end

  describe "#call" do
    context "when user not exists" do
      it "create new user" do
        expect { update_info }.to change(User, :count).by(1)
      end

      it "create user with uuid from cognito" do
        expect(update_info.user.uuid).to eq(params["sub"])
      end
    end

    context "when user exists" do
      let(:object) { create(:user, uuid: params["sub"]) }

      it "return existed user" do
        expect(update_info.user).to eq(object)
      end
    end

    context "without pennylane client id" do
      let(:object) { create(:user, uuid: params["sub"], pl_client_id: nil) }

      before do
        allow_any_instance_of(Crm::Hubspot).to receive(:get_quotes_from_contact_id)
          .and_return([double(reference: "quote_reference")])
      end

      it "fetch quote reference from hubspot" do
        expect_any_instance_of(Crm::Hubspot).to receive(:get_quotes_from_contact_id).once
        update_info
      end

      it "fetch client id from pennylane" do
        expect(update_info.user.pl_client_id).not_to be_nil
      end
    end
  end
end
