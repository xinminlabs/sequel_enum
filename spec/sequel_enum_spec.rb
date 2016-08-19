require 'spec_helper'

class Item < Sequel::Model
  plugin :enum
end

describe "sequel_enum" do
  let(:item) { Item.new }

  specify "class should provide reflection" do
    Item.enum :condition, [:mint, :very_good, :fair]
    Item.enum :order, [:asc, :desc]
    expect(Item.enums).to eq({ condition: { :mint => 0, :very_good => 1, :fair => 2}, order: { :asc => 0, :desc => 1 }})
  end

  specify "it accepts an array of symbols" do
    expect{
      Item.enum :condition, [:mint, :very_good, :good, :poor]
    }.not_to raise_error
  end

  specify "it accepts a hash of index => value" do
    expect{
      Item.enum :condition, :mint => 0, :very_good => 1, :good => 2, :poor => 3
    }.not_to raise_error
  end

  specify "it rejects an invalid hash" do
    expect{
      Item.enum :condition, { '0' => :mint }
    }.to raise_error(ArgumentError)
  end

  specify "it rejects when it's not an array or hash" do
    expect{
      Item.enum :condition, 'whatever'
    }.to raise_error(ArgumentError)
  end

  describe "methods" do
    before(:all) do
      Item.enum :condition, [:mint, :very_good, :good, :poor]
      Item.enum :order, [:asc, :desc]
    end

    describe "#column=" do
      context "with a valid value" do
        it "should set column to the value index" do
          item.condition = :mint
          item.order = :asc
          expect(item[:condition]).to be 0
          expect(item[:order]).to be 0
        end
      end

      context "with an invalid value" do
        it "should set column to nil" do
          item.condition = :fair
          item.order = :middle
          expect(item[:condition]).to be_nil
          expect(item[:order]).to be_nil
        end
      end
    end

    describe "#column" do
      context "with a valid index stored on the column" do
        it "should return its matching value" do
          item[:condition] = 1
          item[:order] = 1
          expect(item.condition).to be :very_good
          expect(item.order).to be :desc
        end
      end

      context "with an invalid index stored on the column" do
        it "should return nil" do
          item[:condition] = 10
          item[:order] = 10
          expect(item.condition).to be_nil
          expect(item.order).to be_nil
        end
      end
    end

    describe "#column?" do
      context "when the actual value match" do
        it "should return true" do
          item.condition = :good
          item.order = :asc
          expect(item.good?).to be true
          expect(item.asc?).to be true
        end
      end

      context "when the actual value doesn't match" do
        it "should return false" do
          item.condition = :mint
          item.condition = :asc
          expect(item.poor?).to be false
          expect(item.desc?).to be false
        end
      end
    end
  end
end
