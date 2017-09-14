require 'spec_helper'

describe Saxo do
  it 'has a version number' do
    expect(Saxo::VERSION).not_to be nil
  end

  it 'returns brokers' do
    expect(Saxo.brokers[:td]).to eq('TD')
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
  describe '#api_key' do
    it 'returns ENV - SAXO_API_KEY' do
      expect(Saxo.api_key).to eql ENV['SAXO_API_KEY']
    end
    it 'raises error with no key' do
      Saxo.configure do |config|
        config.api_key = nil
      end
      expect { Saxo.api_uri }.to raise_error(Trading::Errors::ConfigException)
    end
  end
  describe '#price_service_url' do
    it 'returns ENV - PRICE_SERVICE_URL' do
      expect(Saxo.price_service_url).to eql ENV['PRICE_SERVICE_URL']
    end
    it 'raises error with no key' do
      Saxo.configure do |config|
        config.price_service_url = nil
      end
      expect { Saxo.price_service_url }.to raise_error(Trading::Errors::ConfigException)
    end
  end

end
