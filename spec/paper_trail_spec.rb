require "rails_helper"

RSpec.describe PaperTrail do
  context "when enabled" do
    it "affects all threads" do
      Thread.new { described_class.enabled = false }.join
      assert_equal false, described_class.enabled?
    end

    after do
      described_class.enabled = true
    end
  end

  context "default" do
    it "should have versioning off by default" do
      expect(described_class).not_to be_enabled
    end

    it "should turn versioning on in a `with_versioning` block" do
      expect(described_class).not_to be_enabled
      with_versioning do
        expect(described_class).to be_enabled
      end
      expect(described_class).not_to be_enabled
    end

    context "error within `with_versioning` block" do
      it "should revert the value of `PaperTrail.enabled?` to it's previous state" do
        expect(described_class).not_to be_enabled
        expect { with_versioning { raise } }.to raise_error(RuntimeError)
        expect(described_class).not_to be_enabled
      end
    end
  end

  context "`versioning: true`", versioning: true do
    it "should have versioning on by default" do
      expect(described_class).to be_enabled
    end

    it "should keep versioning on after a with_versioning block" do
      expect(described_class).to be_enabled
      with_versioning do
        expect(described_class).to be_enabled
      end
      expect(described_class).to be_enabled
    end
  end

  context "`with_versioning` block at class level" do
    it { expect(described_class).not_to be_enabled }

    with_versioning do
      it "should have versioning on by default" do
        expect(described_class).to be_enabled
      end
    end
    it "should not leak the `enabled?` state into successive tests" do
      expect(described_class).not_to be_enabled
    end
  end

  describe ".version" do
    it { expect(described_class).to respond_to(:version) }
    it { expect(described_class.version).to eq(described_class::VERSION::STRING) }
  end

  describe ".whodunnit" do
    before(:all) { described_class.whodunnit = "foobar" }

    it "should get set to `nil` by default" do
      expect(described_class.whodunnit).to be_nil
    end
  end

  describe ".controller_info" do
    before(:all) { described_class.controller_info = { foo: "bar" } }

    it "should get set to an empty hash before each test" do
      expect(described_class.controller_info).to eq({})
    end
  end
end
