require 'spec_helper'

describe Saxo::Order::Place do
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
  let(:order_action) { :buy }
  let(:price_type) { :market }
  let(:order_expiration) { :day }
  let(:quantity) { 10 }
  let(:base_order) do
    {
      token: token,
      account_number: account_number,
      order_action: order_action,
      quantity: quantity,
      ticker: 'aapl',
      price_type: price_type,
      expiration: order_expiration
    }
  end
  let(:order_extras) do
    {}
  end

  let(:price) { 123.45 }

  let!(:preview) do
    Saxo::Order::Preview.new(
      base_order.merge(order_extras)
    ).call.response.payload
  end

  let(:preview_token) { preview.token }

  subject do
    Saxo::Order::Place.new(
      token: preview_token,
      price: price
    ).call.response
  end

  describe 'Buy Order' do
    it 'returns details' do
      expect(subject.status).to eql 200
      expect(subject.payload.type).to eql 'success'
      expect(subject.payload.token).not_to be_empty
      expect(subject.payload.ticker).to eql 'aapl'
      expect(subject.payload.order_action).to eql :buy
      expect(subject.payload.quantity).to eql 10
      expect(subject.payload.expiration).to eql :day
      expect(subject.payload.price_label).to eql 'market'
      expect(subject.payload.message).to eql subject.raw['confirmationMessage']
      expect(subject.payload.last_price).to eql subject.raw['orderInfo']['price']['last'].to_f
      expect(subject.payload.bid_price).to eql subject.raw['orderInfo']['price']['bid'].to_f
      expect(subject.payload.ask_price).to eql subject.raw['orderInfo']['price']['ask'].to_f
      expect(subject.payload.price_timestamp).to be > 0
      expect(subject.payload.timestamp).to be > 0
      expect(subject.payload.order_number).not_to be_empty
      expect(subject.payload.price).to eql price
    end
  end

  describe 'Sell Order' do
    let(:order_action) { :sell }
    it 'returns details' do
      expect(subject.payload.order_action).to eql :sell
    end
  end
  describe 'Buy to Cover Order' do
    let(:order_action) { :buy_to_cover }
    it 'returns details' do
      expect(subject.payload.order_action).to eql :buy_to_cover
    end
  end
  describe 'Sell Short Order' do
    let(:order_action) { :sell_short }
    it 'returns details' do
      expect(subject.payload.order_action).to eql :sell_short
    end
  end

  describe 'price types' do
    let(:order_extras) do
      {
        limit_price: 11.0
      }
    end
    describe 'limit' do
      let(:price_type) { :limit }
      it 'returns details' do
        expect(subject.status).to eql 200
        expect(subject.payload.type).to eql 'success'
        expect(subject.payload.price_label).to eql 'limit'
      end
    end

    describe 'stop_market' do
      let(:order_extras) do
        {
          stop_price: 11.0
        }
      end
      let(:price_type) { :stop_market }
      it 'returns details' do
        expect(subject.status).to eql 200
        expect(subject.payload.type).to eql 'success'
        expect(subject.payload.price_label).to eql 'stopMarket'
      end
    end

    describe 'stop_limit' do
      let(:order_extras) do
        {
          stop_price: 10.0,
          limit_price: 11.0
        }
      end
      let(:price_type) { :stop_limit }
      it 'returns details' do
        expect(subject.status).to eql 200
        expect(subject.payload.type).to eql 'success'
        expect(subject.payload.price_label).to eql 'stopLimit'
      end
    end

    describe 'failed place' do
      let(:preview_token) { 'foooooobaaarrrr' }
      it 'throws error' do
        expect { subject }.to raise_error(Trading::Errors::OrderException)
      end
    end
  end
end
