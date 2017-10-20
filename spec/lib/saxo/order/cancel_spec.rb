require 'spec_helper'

describe Saxo::Order::Cancel do
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
  let(:token) { "eyJhY2Nlc3NfdG9rZW4iOiJleUpoYkdjaU9pSkZVekkxTmlJc0luZzFkQ0k2SWtRMFFVVTRNalEyUkRZeU5UQkZNVFk1TmpnNE5ERkNSRVk0TnpjMk1USTROVU13TlVKQ01VWWlmUS5leUp2WVdFaU9pSTNOemMzTUNJc0ltbHpjeUk2SW05aElpd2lZV2xrSWpvaU1UWXdJaXdpZFdsa0lqb2lOMjB6WTBkRU4zQkJVRVI1VGtOa1ptcFRhRFZFWnowOUlpd2lZMmxrSWpvaU4yMHpZMGRFTjNCQlVFUjVUa05rWm1wVGFEVkVaejA5SWl3aWFYTmhJam9pUm1Gc2MyVWlMQ0owYVdRaU9pSXlNVFEySWl3aWMybGtJam9pT0RJd05UbGxNVEJoT0RjeE5ETXpOemhoTm1JNVpEWmxNamxpTXpGak1qZ2lMQ0prWjJraU9pSTROQ0lzSW1WNGNDSTZJakUxTURnME9UVXpNek1pZlEuN1dSQTZEYmJrNWFXdE56SEc1MHIza3NTcTh3VlVxZGxrSXhBTzdoQ2kzcGZOSjByd29Rc29ua0dCVUVXVEVyUFYtdzMtVVJ4Ukg1U0VZYlZYX0V5MUEiLCJ0b2tlbl90eXBlIjoiQmVhcmVyIiwiZXhwaXJlc19pbiI6MTE0OCwicmVmcmVzaF90b2tlbiI6IjgxYmIwNjFkLThmMDUtNGMxNy04OTY1LThkYzIzODVlNzIxOSIsInJlZnJlc2hfdG9rZW5fZXhwaXJlc19pbiI6MzU0OCwiYmFzZV91cmkiOm51bGx9" }
  let(:account_number) { 'Demo_8182800' }

  describe 'Cancel Order' do
    let(:orders) do
      Saxo::Order::Status.new(
        token: token,
        account_number: account_number
      ).call.response.payload.orders
    end
    let(:order_number) { orders[1].order_number }

    subject do
      Saxo::Order::Cancel.new(
        token: token,
        account_number: account_number,
        order_number: order_number
      ).call.response
    end

    it 'returns details' do
      expect(subject.status).to eql 200
      expect(subject.payload.type).to eql 'success'
      expect(subject.payload.token).not_to be_empty
      expect(subject.payload.orders[0].ticker).to eql 'ftfy'
      expect(subject.payload.orders[0].order_action).to eql :buy
      expect(subject.payload.orders[0].filled_quantity).to eql 0.0
      expect(subject.payload.orders[0].filled_price).to eql 0.0
      expect(subject.payload.orders[0].quantity).to eql 275_000
      expect(subject.payload.orders[0].expiration).to eql :gtc
    end
  end
end
