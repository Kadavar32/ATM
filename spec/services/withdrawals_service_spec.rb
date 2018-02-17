require 'rails_helper'

RSpec.describe WithdrawalsService, type: :service do
  let(:service) { WithdrawalsService.new }

  describe '#create' do
    let(:total_balance) { service.total_balance }

    let(:bill_count) { rand(1..100) }
    let(:params) do
      [{ amount: amount, count: bill_count },
       { amount: amount_2, count: bill_count }]
    end

    shared_examples 'create new Withdrawal record' do
      it 'creates Withdrawal' do
        expect { subject }.to change(Withdrawal, :count)
      end

      it 'has attributes in response' do
        withdrawal = subject
        expect(withdrawal[:items]).to be_present
        expect(withdrawal[:amount]).to be_present
      end

      it 'changes total balance' do
        current_balance = service.total_balance
        response = subject
        amount = response.amount
        new_balance = service.total_balance
        expect(current_balance - amount).to eq new_balance
      end
    end

    let(:params) { 0 }
    subject { service.create(params) }

    context 'with valid amount' do

      let(:params) { 65 }

      let!(:bill_5) { create(:bill, amount: 5, count: 2) }
      let!(:bill_10) { create(:bill, amount: 10, count: 2) }
      let!(:bill_25) { create(:bill, amount: 25, count: 2) }

      it_behaves_like 'create new Withdrawal record'

      it 'has right amount' do
        withdrawals = subject
        expect(withdrawals.amount).to eq params
      end
    end

    context 'with invalid amount' do
      let!(:bill_5) { create(:bill, amount: 5, count: 2) }
      let!(:bill_10) { create(:bill, amount: 10, count: 2) }
      let!(:bill_25) { create(:bill, amount: 25, count: 2) }

      shared_examples 'invalid amount error' do
        it 'raises ServiceError' do
          expect { subject }.to raise_error(ServiceError, ErrorMessages::INVALID_AMOUNT_ERROR)
        end
      end

      context 'when amount < 0' do
        let(:money_amount) { - 1 }

        it_behaves_like 'invalid amount error'
      end

      context 'when amount is 0' do
        let(:money_amount) { 0 }

        it_behaves_like 'invalid amount error'
      end


      context 'when amount is a String' do
        let(:money_amount) { 'Not Numeric' }

        it_behaves_like 'invalid amount error'
      end
    end

    context 'when balance less than money_amount' do
      let!(:bill_5) { create(:bill, amount: 5, count: 2) }
      let!(:bill_10) { create(:bill, amount: 10, count: 2) }
      let!(:bill_25) { create(:bill, amount: 25, count: 2) }

      let(:params) { rand(50000..1000000) }

      it 'raises ServiceError' do
        expect { subject }.to raise_error(ServiceError, ErrorMessages::LOW_BALANCE_ERROR)
      end
    end

    context 'with Inaccessible amount error, with last big bill' do
      let!(:bill_5) { create(:bill, amount: 0, count: 0) }
      let!(:bill_10) { create(:bill, amount: 10, count: 0) }

      let(:last_big_bill) { 25 }

      let!(:bill_25) { create(:bill, amount: last_big_bill, count: 1) }

      let(:params) { 24 }

      it 'raises ServiceError' do
        expect { subject }.to raise_error(ServiceError, /#{ErrorMessages::PROCEED_ERROR}.+#{last_big_bill}/)
      end
    end

    context 'with Inaccessible amount error, with smaller amount' do
      let!(:bill_5) { create(:bill, amount: 1, count: 3) }
      let!(:bill_10) { create(:bill, amount: 10, count: 2) }

      let(:smaller_amount) { 23 }
      let!(:bill_25) { create(:bill, amount: 25, count: 1) }

      let(:params) { 24 }

      it 'raises ServiceError' do
        expect { subject }.to raise_error(ServiceError, /#{ErrorMessages::PROCEED_ERROR}.+#{smaller_amount}/)
      end
    end
  end

  describe '#find_all' do
    before do
      (1..5).to_a.each { |_e| create(:withdrawal) }
    end

    subject { service.find_all }

    it 'has data in response' do
      data = subject
      expect(data.count).to eq Withdrawal.all.count
    end
  end
end
