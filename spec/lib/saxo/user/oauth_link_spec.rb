require 'spec_helper'

describe Saxo::User::OauthLink do
  let(:o_auth_verifier) { '33a6433d-e9ec-4314-8c2c-c4f271e25e57' }
  let(:broker) { :saxo }

  subject do
    Saxo::User::OauthLink.new(
      o_auth_verifier: o_auth_verifier,
      broker: broker
    ).call.response
  end

  describe 'good credentials' do
    it 'returns token' do
      puts subject.inspect
      expect(subject.status).to eql 200
      expect(subject.payload.type).to eql 'success'
      expect(subject.payload.user_token).not_to be_empty
      expect(subject.payload.user_id).not_to be_empty
    end
  end

  describe 'bad credentials' do
    let(:username) { 'foooooobaaarrrr' }
    it 'throws error' do
      expect { subject }.to raise_error(Trading::Errors::LoginException)
    end
  end
end
