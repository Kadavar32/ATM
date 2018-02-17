require 'rails_helper'

RSpec.describe Bill, type: :model do

  describe '#create' do
    let(:params) { { amount: rand(1..50), count: rand(100) } }

    subject { Bill.create(params) }

    it 'creates new Bill record' do
      expect { subject }.to change(Bill, :count).by(1)
    end

    context 'with record RecordNotUnique error' do
      let(:existing_bill) { create(:bill) }

      let(:params) { { amount: existing_bill.amount, count: rand(100) } }

      it 'raises not RecordNotUnique' do
        expect { subject }.to raise_error(ActiveRecord::RecordNotUnique)
      end
    end
  end

  describe 'update' do
    let!(:bill) { create(:bill) }

    context 'with optimistic lock' do

      it 'raise StaleObjectError' do
        bill_variable = Bill.last
        bill_variable_2 = Bill.last

        bill_variable.update(count: 1)

        expect { bill_variable_2.update(count: 1) }.to raise_error(ActiveRecord::StaleObjectError)
      end
    end
  end
end
