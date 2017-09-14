require 'spec_helper'

describe Saxo::Order::Status do
  let(:username) { 'dummy' }
  let(:password) { 'pass' }
  let(:broker) { :dummy }
  let(:answer) { 'tradingticket' }
  let!(:user) do
    Saxo::User::LinkAndLogin.new(
      username: username,
      password: password,
      broker: broker
    ).call.response.payload
  end
  let(:token) { user.token }
  let(:account_number) { user.accounts[0].account_number }

  describe 'All Order Status' do
    subject do
      Saxo::Order::Status.new(
        token: token,
        account_number: account_number
      ).call.response
    end
    it 'returns details' do
      expect(subject.status).to eql 200
      expect(subject.payload.type).to eql 'success'
      expect(subject.payload.token).not_to be_empty
      expect(subject.payload.orders[0].ticker).to eql 'cmg'
      expect(subject.payload.orders[0].order_action).to eql :buy
      expect(subject.payload.orders[0].filled_quantity).to eql 0.0
      expect(subject.payload.orders[0].filled_price).to eql 0.0
      expect(subject.payload.orders[0].filled_total).to eql 0.0
      expect(subject.payload.orders[0].quantity).to eql 5000
      expect(subject.payload.orders[0].expiration).to eql :day
      expect(subject.payload.orders[0].status).to eql :open
      expect(subject.payload.orders[1].ticker).to eql 'mcd'
      expect(subject.payload.orders[1].order_action).to eql :sell_short
      expect(subject.payload.orders[1].filled_quantity).to eql 6000.0
      expect(subject.payload.orders[1].filled_price).to eql 123.45
      expect(subject.payload.orders[1].filled_total).to eql 740700.0
      expect(subject.payload.orders[1].quantity).to eql 10_000
      expect(subject.payload.orders[1].expiration).to eql :gtc
      expect(subject.payload.orders[1].status).to eql :filling
    end
    describe 'bad token' do
      let(:token) { 'foooooobaaarrrr' }
      it 'throws error' do
        expect { subject }.to raise_error(Trading::Errors::OrderException)
      end
    end
  end

  describe 'Single Order Status' do
    let(:orders) do
      Saxo::Order::Status.new(
        token: token,
        account_number: account_number
      ).call.response.payload.orders
    end
    let(:order_number) { orders[1].order_number }

    subject do
      Saxo::Order::Status.new(
        token: token,
        account_number: account_number,
        order_number: order_number
      ).call.response
    end

    it 'returns details' do
      expect(subject.status).to eql 200
      expect(subject.payload.type).to eql 'success'
      expect(subject.payload.token).not_to be_empty
      expect(subject.payload.orders[0].ticker).to eql 'cmg'
      expect(subject.payload.orders[0].order_action).to eql :buy
      expect(subject.payload.orders[0].filled_quantity).to eql 0.0
      expect(subject.payload.orders[0].filled_price).to eql 0.0
      expect(subject.payload.orders[0].filled_total).to eql 0.0
      expect(subject.payload.orders[0].quantity).to eql 5000
      expect(subject.payload.orders[0].expiration).to eql :day
    end
    describe 'bad account' do
      let(:account_number) { 'foooooobaaarrrr' }
      it 'throws error' do
        expect { subject }.to raise_error(Trading::Errors::OrderException)
      end
    end
  end
end
