require 'rails_helper'

RSpec.describe Withdrawal, type: :model do

  describe '#create' do
    let(:params) { { amount: rand(1..50) } }

    subject { Withdrawal.create(params) }

    it 'creates new Bill record' do
      expect { subject }.to change(Withdrawal, :count).by(1)
    end

    it 'has negative transfer_amount' do
      withdrawal = subject
      expect(withdrawal.transfer_amount).to eq (- withdrawal.amount)
    end
  end
end
