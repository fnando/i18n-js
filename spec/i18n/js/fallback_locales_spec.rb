require "spec_helper"

describe I18n::JS::FallbackLocales do
  let(:locale) { :fr }
  let(:default_locale) { :en }

  describe "#locales" do
    subject { described_class.new(fallbacks, locale) }

    context "when given true as fallbacks" do
      let(:fallbacks) { true }
      its(:locales) { should eq([default_locale]) }
    end

    context "when given false as fallbacks" do
      let(:fallbacks) { false }
      it "raises an ArgumentError" do
        expect { subject.locales }.to raise_error
      end
    end

    context "when given a valid locale as fallbacks" do
      let(:fallbacks) { :de }
      its(:locales) { should eq([:de]) }
    end

    context "when given a valid Array as fallbacks" do
      let(:fallbacks) { [:de, :en] }
      its(:locales) { should eq([:de, :en]) }
    end

    context "when given a valid Hash with current locale as key as fallbacks" do
      let(:fallbacks) do { :fr => [:de, :en] } end
      its(:locales) { should eq([:de, :en]) }
    end

    context "when given a valid Hash without current locale as key as fallbacks" do
      let(:fallbacks) do { :de => [:fr, :en] } end
      its(:locales) { should eq([default_locale]) }
    end

    context "when given a invalid locale as fallbacks" do
      let(:fallbacks) { :invalid_locale }
      it "raises an ArgumentError" do
        expect { subject.locales }.to raise_error
      end
    end

    context "when given a invalid type as fallbacks" do
      let(:fallbacks) { 42 }
      it "raises an ArgumentError" do
        expect { subject.locales }.to raise_error
      end
    end

    context "when given an invalid Array as fallbacks" do
      let(:fallbacks) { [:de, :en, :invalid_locale] }
      it "raises an ArgumentError" do
        expect { subject.locales }.to raise_error
      end
    end

    context "when given a invalid Hash as fallbacks" do
      let(:fallbacks) do { :fr => [:de, :en, :invalid_locale] } end
      it "raises an ArgumentError" do
        expect { subject.locales }.to raise_error
      end
    end

    # I18n::Backend::Fallbacks
    context "when I18n::Backend::Fallbacks is used" do
      let(:backend_with_fallbacks) { backend_class_with_fallbacks.new }

      before do
        I18n.backend = backend_with_fallbacks
        I18n.fallbacks[:fr] = [:de, :en]
      end
      after { I18n.backend = I18n::Backend::Simple.new }

      context "given true as fallbacks" do
        let(:fallbacks) { true }
        its(:locales) { should eq([:de, :en]) }
      end

      context "given a Hash with current locale as fallbacks" do
        let(:fallbacks) do { :fr => [:en] } end
        its(:locales) { should eq([:en]) }
      end

      context "given a Hash without current locale as fallbacks" do
        let(:fallbacks) do { :de => [:en] } end
        its(:locales) { should eq([:de, :en]) }
      end
    end
  end # -- describe "#locales"
end # -- describe I18n::JS::FallbackLocales
