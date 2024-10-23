# frozen_string_literal: true

require "rails_helper"

class Alice
  attr_accessor :name
end

module Alices
  class AliceService < BaseService
    def call
      add_errors("error1", "error2")

      "AliceService called"
    end
  end
end

module NameSpace
  module Resources
    class ResourceService < BaseService; end
  end
end

RSpec.describe BaseService do
  context "when not inherited" do
    subject(:base_service) { described_class.call }

    describe ".call" do
      it "returns an instance of the service" do
        expect(base_service).to be_a(described_class)
      end
    end

    describe "#call" do
      it "do nothing" do
        expect(base_service.call).to be_nil
      end
    end

    describe "#success?" do
      context "when no errors" do
        it "returns true" do
          expect(base_service).to be_success
        end
      end
    end

    describe "#errors" do
      it "returns an array" do
        expect(base_service.errors).to eq([])
      end
    end

    describe "#params" do
      context "when params are not provided" do
        it "returns an empty hash" do
          expect(base_service.params).to eq({})
        end
      end

      context "when params are provided" do
        subject(:base_service) { described_class.call(params: { test: "test" }) }

        it "returns the params" do
          expect(base_service.params).to eq(test: "test")
        end
      end
    end

    describe "#object" do
      context "when object is not provided" do
        it "returns an instance of the object class from the singularized parent" do
          expect(base_service.object).to be_a(Object)
        end
      end

      context "when object is provided" do
        it "returns the object" do
          expect(described_class.call(object: "test").object).to eq("test")
        end
      end
    end
  end

  context "when inherited by AliceService" do
    subject(:inherited_service) { Alices::AliceService.call }

    describe "#success?" do
      it "returns false" do
        expect(inherited_service).not_to be_success
      end
    end

    describe "#errors" do
      it "returns an array of errors" do
        expect(inherited_service.errors).to eq(%w[error1 error2])
      end
    end

    describe "#alice" do
      context "when object is not provided" do
        it "returns a new instance of" do
          expect(inherited_service.alice).to be_a(Alice)
          expect(inherited_service.alice.name).to eq(nil)
        end
      end

      context "when object is provided" do
        subject(:inherited_service) { Alices::AliceService.call(object: alice) }

        let(:alice) { Alice.new.tap { |a| a.name = "Alice" } }

        it "returns the object" do
          expect(inherited_service.alice).to eq(alice)
          expect(inherited_service.alice.name).to eq("Alice")
        end
      end
    end

    describe "#call" do
      it "returns the result of the call method" do
        expect(inherited_service.call).to eq("AliceService called")
      end
    end
  end

  context "when inherited by ResourceService" do
    subject(:inherited_service) { NameSpace::Resources::ResourceService.call }

    describe "#resource" do
      context "when object is not provided" do
        it "returns nil" do
          expect(inherited_service.resource).to eq(nil)
        end
      end
    end

    describe ".object_class_name_from_parent" do
      it "returns the object class name from the singularized parent" do
        expect(inherited_service.class.object_class_name_from_parent).to eq("NameSpace::Resource")
      end
    end
  end
end
