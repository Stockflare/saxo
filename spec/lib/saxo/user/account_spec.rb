require 'spec_helper'

describe Saxo::User::Account do
  # let(:username) { 'dummy' }
  # let(:password) { 'pass' }
  let(:broker) { :saxo }
  # let(:answer) { 'tradingticket' }
  # let!(:user) do
  #   Saxo::User::LinkAndLogin.new(
  #     username: username,
  #     password: password,
  #     broker: broker
  #   ).call.response.payload
  # end
  let(:token) { "eyJhY2Nlc3NfdG9rZW4iOiJleUpoYkdjaU9pSkZVekkxTmlJc0luZzFkQ0k2SWtRMFFVVTRNalEyUkRZeU5UQkZNVFk1TmpnNE5ERkNSRVk0TnpjMk1USTROVU13TlVKQ01VWWlmUS5leUp2WVdFaU9pSTNOemMzTUNJc0ltbHpjeUk2SW05aElpd2lZV2xrSWpvaU1UWXdJaXdpZFdsa0lqb2lOMjB6WTBkRU4zQkJVRVI1VGtOa1ptcFRhRFZFWnowOUlpd2lZMmxrSWpvaU4yMHpZMGRFTjNCQlVFUjVUa05rWm1wVGFEVkVaejA5SWl3aWFYTmhJam9pUm1Gc2MyVWlMQ0owYVdRaU9pSXlNVFEySWl3aWMybGtJam9pTW1FMll6a3pZMk5tTURrNU5EWmxZamt6TnpoaE1USm1aR1EwTjJaaVpqVWlMQ0prWjJraU9pSTROQ0lzSW1WNGNDSTZJakUxTURneU5ERTFNVGdpZlEuc1RqZUJLa0NNWEsyYmJFVmpWN0pfV2pRV3Y1clNGRjl3SGx3bW5wX25obDBreTFsM0pCc2dmakZKX2JHNGNnUk9rbngxeXhGRzY4S2l4S1FPR0hUcmciLCJ0b2tlbl90eXBlIjoiQmVhcmVyIiwiZXhwaXJlc19pbiI6MTE1MiwicmVmcmVzaF90b2tlbiI6ImZiYjY2NTFiLTIxMmItNDJkZi1hMjJmLWU2ZjYzMzQxZGMxNSIsInJlZnJlc2hfdG9rZW5fZXhwaXJlc19pbiI6MzU1MiwiYmFzZV91cmkiOm51bGx9" }
  let(:account_number) { 'Demo_8182800' }

  describe 'Get Account' do
    subject do
      Saxo::User::Account.new(
        token: token,
        account_number: account_number
      ).call.response
    end
    it 'returns details' do
      expect(subject.status).to eql 200
      expect(subject.payload.cash).to be > 0
      expect(subject.payload.token).not_to be_empty
      expect(subject.payload.power).to be > 0
      expect(subject.payload.day_return).to be > 0
      expect(subject.payload.day_return_percent).to be > 0
      expect(subject.payload.total_return).to be > 0
      expect(subject.payload.total_return_percent).to be > 0
      expect(subject.payload.value).to be > 0
    end
    describe 'bad token' do
      let(:token) { 'foooooobaaarrrr' }
      it 'throws error' do
        expect { subject }.to raise_error(Trading::Errors::LoginException)
      end
    end
  end
end
