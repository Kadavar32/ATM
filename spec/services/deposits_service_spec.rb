require 'rails_helper'

RSpec.describe DepositsService, type: :service do
  let(:service) { DepositsService.new }

  describe '#create' do
    let!(:amount) { rand(1..25) }
    let!(:amount_2) { amount * 2 }
    let!(:bill) { create(:bill, count: 0, amount: amount) }
    let!(:bill_2) { create(:bill, count: 0, amount: amount_2) }

    shared_examples 'updates existing bills' do
      it 'updates count of bills' do
        expect(bill.count).to eq 0
        expect(bill_2.count).to eq 0

        subject

        expect(bill.reload.count).to eq bill_count
        expect(bill_2.reload.count).to eq bill_count
      end
    end

    shared_examples 'creates new Deposit record' do
      it 'creates Deposit' do
        expect { subject }.to change(Deposit, :count)
      end

      it 'has attributes in response' do
        deposit = subject
        expect(deposit[:items]).to be_present
        expect(deposit[:amount]).to be_present
      end

      it 'changes total balance' do
        current_balance = service.total_balance
        response = subject
        amount = response[:amount]
        new_balance = service.total_balance
        expect(current_balance + amount).to eq new_balance
      end
    end

    let(:bill_count) { rand(1..100) }
    
    let(:existing_bills) do
      [{ amount: amount, count: bill_count },
       { amount: amount_2, count: bill_count }]
    end

    let(:params) { existing_bills }

    subject { service.create(params) }

    it_behaves_like 'creates new Deposit record'
    it_behaves_like 'updates existing bills'

    context 'with undefined bills' do
      let(:undefined_bill) { { amount: (amount - 2), count: bill_count } }
      let(:params) do
        existing_bills + [undefined_bill]
      end

      it 'does not create new Bill' do
        expect { subject }.not_to change(Bill, :count)
      end

      it 'has only existing bills in response' do
        deposit = subject
        response_items = deposit.items.map(&:symbolize_keys)
        expect(response_items).to eq existing_bills
      end

      it_behaves_like 'creates new Deposit record'
      it_behaves_like 'updates existing bills'
    end
  end

  describe '#find_all' do
    before do
      (1..5).to_a.each { |_e| create(:deposit) }
    end

    subject { service.find_all }

    it 'has data in response' do
      data = subject
      expect(data.count).to eq Deposit.all.count
    end
  end
end
