require 'spec_helper'

describe Saxo do
  it 'has a version number' do
    expect(Saxo::VERSION).not_to be nil
  end

  it 'returns brokers' do
    expect(Saxo.brokers[:saxo]).to eq('Saxo')
  end

  describe '#api_uri' do
    it 'returns ENV - SAXO_BASE_URI' do
      expect(Saxo.api_uri).to eql ENV['SAXO_BASE_URI']
    end
    it 'raises error when not configured' do
      Saxo.configure do |config|
        config.api_uri = nil
      end
      expect { Saxo.api_uri }.to raise_error(Trading::Errors::ConfigException)
    end
  end
  describe '#app_key' do
    it 'returns ENV - SAXO_APP_KEY' do
      expect(Saxo.app_key).to eql ENV['SAXO_APP_KEY']
    end
    it 'raises error with no key' do
      Saxo.configure do |config|
        config.app_key = nil
      end
      expect { Saxo.api_uri }.to raise_error(Trading::Errors::ConfigException)
    end
  end
  describe '#app_url' do
    it 'returns ENV - SAXO_APP_URL' do
      expect(Saxo.app_url).to eql ENV['SAXO_APP_URL']
    end
    it 'raises error with no key' do
      Saxo.configure do |config|
        config.app_url = nil
      end
      expect { Saxo.app_url }.to raise_error(Trading::Errors::ConfigException)
    end
  end
  describe '#authentication_url' do
    it 'returns ENV - SAXO_AUTHENTICATION_URL' do
      expect(Saxo.authentication_url).to eql ENV['SAXO_AUTHENTICATION_URL']
    end
    it 'raises error with no key' do
      Saxo.configure do |config|
        config.authentication_url = nil
      end
      expect { Saxo.authentication_url }.to raise_error(Trading::Errors::ConfigException)
    end
  end

  describe '#app_secret' do
    it 'returns ENV - SAXO_APP_URL' do
      expect(Saxo.app_secret).to eql ENV['SAXO_APP_SECRET']
    end
    it 'raises error with no key' do
      Saxo.configure do |config|
        config.app_secret = nil
      end
      expect { Saxo.app_secret }.to raise_error(Trading::Errors::ConfigException)
    end
  end

end
