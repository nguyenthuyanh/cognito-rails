require "rails_helper"

RSpec.describe ::Crm::Hubspot, type: :lib do
  subject(:crm) { described_class.new }

  described_class::ATTR_MAPPING.each_key do |object|
    it { is_expected.to respond_to("get_#{object}") }
    it { is_expected.to respond_to("get_#{object}_files") }

    describe "#upload_#{object}_file" do
      context "with valid argument" do
        let(:file_attr) { :foo }
        let(:file_property) { :bar }
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
            .with(id: object_id, properties: { file_property => file_id }).once

          crm.send("upload_#{object}_file", object_id, file_attr, file)
        end
      end
    end
  end
end
