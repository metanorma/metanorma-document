# frozen_string_literal: true

require "spec_helper"
require "metanorma/mirror"

RSpec.describe Metanorma::Mirror::HandlerRegistry do
  let(:registry) { described_class.new }

  describe "#register" do
    it "stores a handler entry" do
      handler = double("handler")
      klass = Class.new
      registry.register(klass, handler, method_name: :call)
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
      handler = double("handler")
      klass = Class.new
      registry.register(klass, handler, method_name: :transform)
      entry = registry.entry_for(klass.new)
      entry.handler.should eq(handler)
      entry.method_name.should eq(:transform)
    end

    it "returns nil for unregistered class" do
      registry.entry_for(Class.new.new).should be_nil
    end
  end

  describe "#handle" do
    it "dispatches to handler method" do
      handler_mod = Module.new do
        def self.call(element, context:)
          Metanorma::Mirror::Node::Paragraph.new(attrs: { id: element.object_id.to_s })
        end
      end

      klass = Class.new
      registry.register(klass, handler_mod)
      element = klass.new

      result, concat = registry.handle(element, context: nil)
      result.should be_a(Metanorma::Mirror::Node::Paragraph)
      concat.should be(false)
    end

    it "supports method_name option" do
      handler_mod = Module.new do
        def self.transform(_element, context:)
          Metanorma::Mirror::Node::Paragraph.new
        end
      end

      klass = Class.new
      registry.register(klass, handler_mod, method_name: :transform)
      element = klass.new

      result, _concat = registry.handle(element, context: nil)
      result.should be_a(Metanorma::Mirror::Node::Paragraph)
    end

    it "returns nil for unregistered elements" do
      registry.handle(Class.new.new, context: nil).should be_nil
    end

    it "supports concat option" do
      handler_mod = Module.new do
        def self.call(_element, context:)
          [Metanorma::Mirror::Node::Paragraph.new, Metanorma::Mirror::Node::Paragraph.new]
        end
      end

      klass = Class.new
      registry.register(klass, handler_mod, concat: true)
      element = klass.new

      result, concat = registry.handle(element, context: nil)
      result.should be_an(Array)
      concat.should be(true)
    end
  end
end
