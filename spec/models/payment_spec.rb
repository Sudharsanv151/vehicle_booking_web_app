require 'rails_helper'

RSpec.describe Payment, type: :model do

  describe "associations" do
    it "belongs to booking" do
      expect(described_class.reflect_on_association(:booking).macro).to eq(:belongs_to)
    end
  end

  describe "validations" do

    subject { build(:payment) }

    context "payment_type validation", :aggregate_failures do
      it "is invalid without payment_type" do
        subject.payment_type = nil
        expect(subject).not_to be_valid
        expect(subject.errors[:payment_type]).to include("can't be blank")
      end

      it "is invalid with an unsupported type" do
        subject.payment_type = "Cheque"
        expect(subject).not_to be_valid
        expect(subject.errors[:payment_type]).to include("is not included in the list")
      end

      it "is valid with allowed types" do
        %w[Cash UPI Card].each do |type|
          subject.payment_type = type
          expect(subject).to be_valid
        end
      end
    end

    context "payment_status validation", :aggregate_failures do
      it "is invalid if payment_status is nil" do
        subject.payment_status = nil
        expect(subject).not_to be_valid
        expect(subject.errors[:payment_status]).to include("is not included in the list")
      end

      it "is valid for true and false" do
        subject.payment_status = true
        expect(subject).to be_valid

        subject.payment_status = false
        expect(subject).to be_valid
      end
    end
  end

  describe "callbacks" do
    it "formats payment_type before validation" do
      payment = build(:payment, payment_type: "  upi  ")
      payment.valid?
      expect(payment.payment_type).to eq("Upi")
    end
  end

  describe "scopes" do
    let!(:success) { create(:payment, payment_status: true) }
    let!(:fail)    { create(:payment, payment_status: false) }
    let!(:upi)     { create(:payment, payment_type: "UPI") }

    it "returns only successful payments" do
      expect(Payment.successful).to include(success)
      expect(Payment.successful).not_to include(fail)
    end

    it "returns only failed payments" do
      expect(Payment.failed).to include(fail)
      expect(Payment.failed).not_to include(success)
    end

    it "filters by payment type" do
      expect(Payment.by_type("Upi")).to include(upi)
      expect(Payment.by_type("Upi")).not_to include(success, fail)
    end
  end

  describe ".ransackable_attributes" do
    it "includes searchable attributes", :aggregate_failures do
      expect(Payment.ransackable_attributes).to include("booking_id", "payment_type", "payment_status")
    end
  end

  describe ".ransackable_associations" do
    it "includes booking association" do
      expect(Payment.ransackable_associations).to include("booking")
    end
  end
end
