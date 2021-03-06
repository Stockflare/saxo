require 'spec_helper'

describe Saxo::User::Login do
  # let(:username) { 'dummy' }
  # let(:password) { 'pass' }
  let(:broker) { :saxo }
  # let!(:link) do
  #   Saxo::User::Link.new(
  #     username: username,
  #     password: password,
  #     broker: broker
  #   ).call.response
  # end
  let(:user_id) { 'Saxo' }
  let(:user_token) { "eyJhY2Nlc3NfdG9rZW4iOiJleUpoYkdjaU9pSkZVekkxTmlJc0luZzFkQ0k2SWtRMFFVVTRNalEyUkRZeU5UQkZNVFk1TmpnNE5ERkNSRVk0TnpjMk1USTROVU13TlVKQ01VWWlmUS5leUp2WVdFaU9pSTNOemMzTUNJc0ltbHpjeUk2SW05aElpd2lZV2xrSWpvaU1UWXdJaXdpZFdsa0lqb2lOMjB6WTBkRU4zQkJVRVI1VGtOa1ptcFRhRFZFWnowOUlpd2lZMmxrSWpvaU4yMHpZMGRFTjNCQlVFUjVUa05rWm1wVGFEVkVaejA5SWl3aWFYTmhJam9pUm1Gc2MyVWlMQ0owYVdRaU9pSXlNVFEySWl3aWMybGtJam9pTkRJek5UazBPVEprT1RBeE5ERmtaR0k1WWpjMk5tUXhZV05tWVdWaE1UVWlMQ0prWjJraU9pSTROQ0lzSW1WNGNDSTZJakUxTURVME9UTTVNVFVpZlEuUmxmU29sM2VjSnlNWkZVRm8zQmNjaG5yZzVCWms4WmhodUlaemE5WGhlVGlxZF9NdThFU2w3LXp2UUp6NU1xSEhxNjlkSzlDNTZsNF9oM0JnYWd4cWciLCJ0b2tlbl90eXBlIjoiQmVhcmVyIiwiZXhwaXJlc19pbiI6MTE1NCwicmVmcmVzaF90b2tlbiI6IjAwZTZmYjU2LWZjMDUtNGMyMS05ZDI1LTM2NGQxYmYxNGZlMSIsInJlZnJlc2hfdG9rZW5fZXhwaXJlc19pbiI6MzU1NCwiYmFzZV91cmkiOm51bGx9" }

  subject do
    Saxo::User::Login.new(
      user_id: user_id,
      user_token: user_token
    ).call.response
  end

  describe 'good credentials' do
    it 'returns token' do
      expect(subject.status).to eql 200
      expect(subject.payload.type).to eql 'success'
      expect(subject.payload.token).not_to be_empty
    end
  end

  describe 'bad credentials' do
    let(:user_id) { 'foooooobaaarrrr' }
    it 'throws error' do
      expect { subject }.to raise_error(Trading::Errors::LoginException)
    end
  end

  describe 'user needing security question' do
    let(:username) { 'dummySecurity' }
    it 'returns response with questions' do
      expect(subject.payload.type).to eql 'verify'
      expect(subject.payload.challenge).to eql 'question'
      expect(subject.payload.data).to have_key :answers
    end

    describe 'image' do
      let(:username) { 'dummySecurityImage' }
      it 'returns image in response' do
        expect(subject.payload.data.encoded).not_to be_empty
      end
    end
  end
end
