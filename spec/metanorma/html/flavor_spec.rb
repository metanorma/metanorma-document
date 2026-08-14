# frozen_string_literal: true

require "spec_helper"
require "metanorma/html"
require "metanorma/iso/document"
require "metanorma/itu/document"

RSpec.describe Metanorma::Html::Flavor do
  def build_flavor(name:, pubid_module: nil)
    described_class.new(name: name, model_class: Object,
                        renderer_class: Object, pubid_module: pubid_module)
  end

  describe "#pubid_module_const" do
    it "returns nil when no pubid module is configured" do
      expect(build_flavor(name: :cc).pubid_module_const).to be_nil
    end

    it "resolves a configured pubid module" do
      expect(build_flavor(name: :iso, pubid_module: :"Pubid::Iso")
               .pubid_module_const).to eq(Pubid::Iso)
    end

    it "raises ArgumentError naming flavor and module when unresolvable" do
      flavor = build_flavor(name: :itu, pubid_module: :"Pubid::Ithu")
      expect { flavor.pubid_module_const }
        .to raise_error(ArgumentError, /itu.*Pubid::Ithu/)
    end
  end

  describe "Generator flavor registry" do
    it "resolves every configured pubid module", :aggregate_failures do
      modules = Metanorma::Html::Generator.flavors.filter_map(&:pubid_module)
      expect(modules).not_to be_empty
      modules.each { |m| expect(Object.const_get(m.to_s)).to be_a(Module) }
    end
  end
end
