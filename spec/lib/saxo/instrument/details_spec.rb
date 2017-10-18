require 'spec_helper'

describe Saxo::Instrument::Details do
  # let(:username) { 'dummy' }
  # let(:password) { 'pass' }
  let(:broker) { :saxo }
  # let!(:user) do
  #   Saxo::User::LinkAndLogin.new(
  #     username: username,
  #     password: password,
  #     broker: broker
  #   ).call.response.payload
  # end
  let(:token) { "eyJhY2Nlc3NfdG9rZW4iOiJleUpoYkdjaU9pSkZVekkxTmlJc0luZzFkQ0k2SWtRMFFVVTRNalEyUkRZeU5UQkZNVFk1TmpnNE5ERkNSRVk0TnpjMk1USTROVU13TlVKQ01VWWlmUS5leUp2WVdFaU9pSTNOemMzTUNJc0ltbHpjeUk2SW05aElpd2lZV2xrSWpvaU1UWXdJaXdpZFdsa0lqb2lOMjB6WTBkRU4zQkJVRVI1VGtOa1ptcFRhRFZFWnowOUlpd2lZMmxrSWpvaU4yMHpZMGRFTjNCQlVFUjVUa05rWm1wVGFEVkVaejA5SWl3aWFYTmhJam9pUm1Gc2MyVWlMQ0owYVdRaU9pSXlNVFEySWl3aWMybGtJam9pTnpBNVlUWmlaVFZoWkRoaU5EY3lOR0UxTm1ZMlpEUmlabU01WlRNd1pUTWlMQ0prWjJraU9pSTROQ0lzSW1WNGNDSTZJakUxTURnek16ZzJNRElpZlEuSTFFeGFYWTdtSThyaGFZR3BDNDBRa21NT1FmQlJFeEpMLTNwOTVlM2hOM0dId1UxTXVOYVBMbk9VZ0ExT0pMYWVQOFkycXo0ZUtOM2JJMWo4T09JRlEiLCJ0b2tlbl90eXBlIjoiQmVhcmVyIiwiZXhwaXJlc19pbiI6ODg4LCJyZWZyZXNoX3Rva2VuIjoiMWFhNmYyNDAtZTMyZS00NzNmLTg3ZTItODQ0ZWFjNWRlMzJmIiwicmVmcmVzaF90b2tlbl9leHBpcmVzX2luIjozMjg4LCJiYXNlX3VyaSI6bnVsbH0=" }
  let(:account_number) { 'Demo_8182800' }

  let(:ticker) { 'aapl' }

  subject do
    Saxo::Instrument::Details.new(
      token: token,
      ticker: ticker
    ).call.response
  end

  describe 'Details' do
    it 'returns positions' do
      expect(subject.status).to eql 200
      expect(subject.payload.type).to eql 'success'
      expect(subject.payload.broker_id).to eql 211
      expect(subject.payload.last_price).to be > 0.0
      expect(subject.payload.last_price).to be > 0.0
      expect(subject.payload.bid_price).to be > 0.0
      expect(subject.payload.ask_price).to be > 0.0
      expect(subject.payload.order_size_max).to be > 0.0
      expect(subject.payload.order_size_min).to be > 0.0
      expect(subject.payload.order_size_step).to be > 0.0
      expect(subject.payload.timestamp).to be > 0
      expect(subject.payload.allow_fractional_shares).to eql false
      expect(subject.payload.token).not_to be_empty
    end
  end

  describe 'bad tiocker' do
    let(:ticker) { 'foooooobaaarrrr' }
    it 'throws error' do
      expect { subject }.to raise_error(Trading::Errors::OrderException)
    end
  end

end
