require "spec_helper"

describe I18n::JS::Dependencies, ".sprockets_supports_register_preprocessor?" do

  subject { described_class.sprockets_supports_register_preprocessor? }

  context 'when Sprockets is available to register preprocessors' do
    let!(:sprockets_double) do
      class_double('Sprockets').as_stubbed_const(register_processor: true).tap do |double|
        allow(double).to receive(:respond_to?).with(:register_preprocessor).and_return(true)
      end
    end

    it { is_expected.to be_truthy }
    it 'calls respond_to? with register_preprocessor on Sprockets' do
      expect(sprockets_double).to receive(:respond_to?).with(:register_preprocessor).and_return(true)
      subject
    end
  end

  context 'when Sprockets is NOT available to register preprocessors' do
    let!(:sprockets_double) do
      class_double('Sprockets').as_stubbed_const(register_processor: true).tap do |double|
        allow(double).to receive(:respond_to?).with(:register_preprocessor).and_return(false)
      end
    end

    it { is_expected.to be_falsy }
    it 'calls respond_to? with register_preprocessor on Sprockets' do
      expect(sprockets_double).to receive(:respond_to?).with(:register_preprocessor).and_return(false)
      subject
    end
  end

  context 'when Sprockets is missing' do
    before do
      hide_const('Sprockets')
      expect { Sprockets }.to raise_error(NameError)
    end

    it { is_expected.to be_falsy }
  end
end
