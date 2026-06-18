# frozen_string_literal: true

require "spec_helper"
require "metanorma/document"
require "metanorma/mirror"

RSpec.describe Metanorma::Document::CLI do
  describe ".run" do
    it "shows usage with no arguments" do
      stdout = capture_stdout { described_class.run([]) }
      stdout.should include("Usage:")
    end

    it "shows usage with --help" do
      stdout = capture_stdout { described_class.run(["--help"]) }
      stdout.should include("Usage:")
    end

    it "raises error for unknown command" do
      -> {
        described_class.run(["unknown"])
      }.should raise_error(
        Metanorma::Document::CLI::Error, /Unknown command/
      )
    end
  end

  describe ".to_mirror" do
    it "raises error when no XML path provided" do
      -> {
        described_class.to_mirror([])
      }.should raise_error(
        Metanorma::Document::CLI::Error, /XML path required/
      )
    end

    it "raises error when file not found" do
      -> {
        described_class.to_mirror(["/nonexistent/file.xml"])
      }.should raise_error(
        Metanorma::Document::CLI::Error, /File not found/
      )
    end

    it "raises error for unknown id-strategy" do
      -> {
        described_class.to_mirror(["--id-strategy", "bogus",
                                   "file.xml"])
      }.should raise_error(Metanorma::Document::CLI::Error,
                           /Unknown ID strategy/)
    end
  end

  def capture_stdout
    old = $stdout
    $stdout = StringIO.new
    yield
    $stdout.string
  ensure
    $stdout = old
  end
end
