require 'spec_helper'

describe Saxo::Positions::Get do
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
  let(:token) { "eyJhY2Nlc3NfdG9rZW4iOiJleUpoYkdjaU9pSkZVekkxTmlJc0luZzFkQ0k2SWtRMFFVVTRNalEyUkRZeU5UQkZNVFk1TmpnNE5ERkNSRVk0TnpjMk1USTROVU13TlVKQ01VWWlmUS5leUp2WVdFaU9pSTNOemMzTUNJc0ltbHpjeUk2SW05aElpd2lZV2xrSWpvaU1UWXdJaXdpZFdsa0lqb2lOMjB6WTBkRU4zQkJVRVI1VGtOa1ptcFRhRFZFWnowOUlpd2lZMmxrSWpvaU4yMHpZMGRFTjNCQlVFUjVUa05rWm1wVGFEVkVaejA5SWl3aWFYTmhJam9pUm1Gc2MyVWlMQ0owYVdRaU9pSXlNVFEySWl3aWMybGtJam9pT1RJd1lqWmtOakZqTURoak5HUTNOamhoWTJKalpUVmlaREU0TkdZM05qWWlMQ0prWjJraU9pSTROQ0lzSW1WNGNDSTZJakUxTURneU16WTFPVE1pZlEueUZEQXZJNEhZcEhGQUZTVmtkbFViU3lURmIxa1JhYndPOFdRX0pkYm1QQUZSQmhYZWRZdE5IUVJNVlI1R2p1bVJYSFVTcV9QcDlaSHdjdGtmWUVaUGciLCJ0b2tlbl90eXBlIjoiQmVhcmVyIiwiZXhwaXJlc19pbiI6MTE1MSwicmVmcmVzaF90b2tlbiI6IjliYjExNzYzLWJjYmItNGNhOS04ZDIzLTc4ZjhhYjUxYWY0NCIsInJlZnJlc2hfdG9rZW5fZXhwaXJlc19pbiI6MzU1MSwiYmFzZV91cmkiOm51bGx9" }
  let(:account_number) { 'Demo_8182800' }

  subject do
    Saxo::Positions::Get.new(
      token: token,
      account_number: account_number
    ).call.response
  end

  describe 'Get' do
    it 'returns positions' do
      expect(subject.status).to eql 200
      expect(subject.payload.positions.count).to be > 0
      expect(subject.payload.pages).to be > 0
      expect(subject.payload.positions[0].quantity).to_not eql 0
      expect(subject.payload.positions[0].quantity).to_not eql nil
      expect(subject.payload.positions[0].cost_basis).to_not eql 0
      expect(subject.payload.positions[0].cost_basis).to_not eql nil
      expect(subject.payload.token).not_to be_empty
    end
  end

  describe 'bad account' do
    let(:account_number) { 'foooooobaaarrrr' }
    it 'throws error' do
      expect { subject }.to raise_error(Trading::Errors::PositionException)
    end
  end
end
