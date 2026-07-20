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
      expect(registry.registered?(klass)).to be(true)
    end
  end

  describe "#registered?" do
    it "returns false for unregistered classes" do
      klass = Class.new
      expect(registry.registered?(klass)).to be(false)
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
      expect(entry.callable).to eq(handler_mod.method(:transform))
    end

    it "returns nil for unregistered class" do
      expect(registry.entry_for(Class.new.new)).to be_nil
    end
  end

  describe "#handle" do
    it "dispatches to handler method and returns HandlerResult" do
      handler_mod = Module.new do
        def self.call(element, context:)
          Metanorma::Mirror::Handlers.build_node("paragraph",
                                                 attrs: { id: element.object_id.to_s })
        end
      end

      klass = Class.new
      registry.register(klass, handler_mod)
      element = klass.new

      result = registry.handle(element, context: nil)
      expect(result).to be_a(Metanorma::Mirror::HandlerResult)
      expect(result.nodes).to be_a(Metanorma::Mirror::Model::Node)
      expect(result.nodes.type).to eq("paragraph")
      expect(result.concat?).to be(false)
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
      expect(result.nodes.type).to eq("paragraph")
    end

    it "returns none HandlerResult for unregistered elements" do
      result = registry.handle(Class.new.new, context: nil)
      expect(result).to be_a(Metanorma::Mirror::HandlerResult)
      expect(result.none?).to be(true)
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
      expect(result.nodes).to be_an(Array)
      expect(result.concat?).to be(true)
    end
  end
end
