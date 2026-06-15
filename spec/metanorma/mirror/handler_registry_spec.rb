# frozen_string_literal: true

require "spec_helper"
require "metanorma/mirror"

RSpec.describe Metanorma::Mirror::HandlerRegistry do
  let(:registry) { described_class.new }

  describe "#register" do
    it "stores a handler entry" do
      handler_mod = Module.new do
        def self.call(_element, context:); end
      end
      klass = Class.new
      registry.register(klass, handler_mod, method_name: :call)
      registry.registered?(klass).should be(true)
    end
  end

  describe "#registered?" do
    it "returns false for unregistered classes" do
      klass = Class.new
      registry.registered?(klass).should be(false)
    end
  end

  describe "#entry_for" do
    it "returns entry for registered class" do
      handler_mod = Module.new do
        def self.transform(_element, context:); end
      end
      klass = Class.new
      registry.register(klass, handler_mod, method_name: :transform)
      entry = registry.entry_for(klass.new)
      entry.handler.should eq(handler_mod)
      entry.method_name.should eq(:transform)
    end

    it "returns nil for unregistered class" do
      registry.entry_for(Class.new.new).should be_nil
    end
  end

  describe "#handle" do
    it "dispatches to handler method and returns HandlerResult" do
      handler_mod = Module.new do
        def self.call(element, context:)
          Metanorma::Mirror::Handlers.build_node("paragraph", attrs: { id: element.object_id.to_s })
        end
      end

      klass = Class.new
      registry.register(klass, handler_mod)
      element = klass.new

      result = registry.handle(element, context: nil)
      result.should be_a(Metanorma::Mirror::HandlerResult)
      result.nodes.should be_a(Metanorma::Mirror::Model::Node)
      result.nodes.type.should eq("paragraph")
      result.concat?.should be(false)
    end

    it "supports method_name option" do
      handler_mod = Module.new do
        def self.transform(_element, context:)
          Metanorma::Mirror::Handlers.build_node("paragraph")
        end
      end

      klass = Class.new
      registry.register(klass, handler_mod, method_name: :transform)
      element = klass.new

      result = registry.handle(element, context: nil)
      result.nodes.type.should eq("paragraph")
    end

    it "returns none HandlerResult for unregistered elements" do
      result = registry.handle(Class.new.new, context: nil)
      result.should be_a(Metanorma::Mirror::HandlerResult)
      result.none?.should be(true)
    end

    it "supports concat option" do
      handler_mod = Module.new do
        def self.call(_element, context:)
          [Metanorma::Mirror::Handlers.build_node("paragraph"),
           Metanorma::Mirror::Handlers.build_node("paragraph")]
        end
      end

      klass = Class.new
      registry.register(klass, handler_mod, concat: true)
      element = klass.new

      result = registry.handle(element, context: nil)
      result.nodes.should be_an(Array)
      result.concat?.should be(true)
    end
  end
end
