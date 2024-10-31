require "rails_helper"

RSpec.describe ::Crm::Hubspot, type: :lib do
  subject(:crm) { described_class.new }

  let(:file_attr) { :foo }
  let(:file_property) { :bar }

  described_class::ATTR_MAPPING.each_key do |object|
    it { expect(crm.send("get_#{object}", id: "id")).to be_a("crm/models/#{object}".camelize.constantize) }

    it {
      expect(crm.send("get_#{object}_files", id: "id")).to be_a("crm/models/#{object}".camelize.constantize)
    }

    describe "#update_#{object}" do
      let(:attr_mapping) { { object => { properties: { file_attr => file_property } } } }

      context "with valid argument" do
        before do
          stub_const("#{described_class}::ATTR_MAPPING", attr_mapping)
        end

        it {
          expect(crm.send("update_#{object}", id: "id",
            attributes: { file_attr => file_property })).not_to be_nil
        }
      end
    end

    describe "#upload_#{object}_file" do
      context "with valid argument" do
        let(:attr_mapping) { { object => { files: { file_attr => file_property } } } }
        let(:file) { File.open(Rails.root.join("spec/test.txt").to_s) }
        let(:object_id) { "object_id" }
        let(:file_id) { "file_id" }

        before do
          stub_const("#{described_class}::ATTR_MAPPING", attr_mapping)
          allow_any_instance_of(described_class).to receive(:upload_file).and_return(double(id: file_id))
          allow_any_instance_of(described_class).to receive("update_#{object}").and_return(true)
        end

        it "upload file then attach to #{object} object" do
          expect_any_instance_of(described_class).to receive(:upload_file).with(file, nil).once
          expect_any_instance_of(described_class).to receive("update_#{object}")
            .with(id: object_id, attributes: { file_attr => file_id }).once

          crm.send("upload_#{object}_file", object_id, file_attr, file)
        end
      end
    end
  end
end
