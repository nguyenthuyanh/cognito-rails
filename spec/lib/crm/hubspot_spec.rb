require "rails_helper"

RSpec.describe ::Crm::Hubspot, type: :lib do
  subject(:crm) { described_class.new }

  described_class::ATTR_MAPPING.each_key do |object|
    describe "#get_#{object}" do
      it { is_expected.to respond_to("get_#{object}") }
      it { is_expected.to respond_to("get_#{object}_file") }
    end
  end
end
