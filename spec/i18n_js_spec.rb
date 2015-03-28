require "spec_helper"

describe I18n::JS do

  describe '.export' do
    before { expect(I18n::JS::Exporter).to receive(:export).with(no_args).and_call_original }
    it { I18n::JS.export }
  end

  describe '.filtered_translations' do
    before { expect(I18n::JS::Exporter).to receive(:filtered_translations).with(no_args).and_call_original }
    it { I18n::JS.filtered_translations }
  end

  describe '.config_file_path=' do
    before { expect(I18n::JS::Exporter).to receive(:config_file_path=).with('foo').and_call_original }
    it { I18n::JS.config_file_path = 'foo' }
  end

  describe '.export_i18n_js_dir_path=' do
    before { expect(I18n::JS::Exporter).to receive(:export_i18n_js_dir_path=).with('foo').and_call_original }
    it { I18n::JS.export_i18n_js_dir_path = 'foo' }
  end
end
