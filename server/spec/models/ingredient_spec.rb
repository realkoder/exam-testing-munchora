require 'rails_helper'

RSpec.describe Ingredient, type: :model do
  describe 'validations' do
    let(:user) { create(:user) }

    let(:valid_attributes) do
      {
        name: 'test',
        amount: 1,
        category: 'fruits 🍎',
        recipe_id: create(:recipe).id
      }
    end

    # ======================================
    # NAME VALIDATIONS
    # ======================================
    context 'name', :name_context do
      [
        # Invalid name partition 0 - 1: lower boundary
        { name: '', is_valid: false },

        # Valid name partition 1-60
        { name: 'n', is_valid: true }, # valid lower
        { name: 'nn', is_valid: true }, # +1 char
        { name: 'n' * 30, is_valid: true }, # equivalence partition
        { name: 'n' * 59, is_valid: true }, # -1 char from valid lower boundary
        { name: 'n' * 60, is_valid: true }, # valid upper

        # Invalid name partition > 60
        { name: 'n' * 61, is_valid: false }, # +1 char
        { name: 'n' * 450, is_valid: false }, # equivalence partition

        # Edge cases: unexpected data type
        { name: nil, is_valid: false },
        { name: 1, is_valid: true },
        { name: 123456, is_valid: true },
        { name: true, is_valid: true }
      ].each do |example|
        name = example[:name]
        size_or_datatype = name.is_a?(String) ? "length #{name.size}" : name.class

        it "#{example[:is_valid] ? 'accepts ' : 'rejects in'}valid name with #{size_or_datatype}" do
          ingredient = Ingredient.new(valid_attributes.merge(name: name))
          example[:is_valid] ? (expect(ingredient).to be_valid) : (expect(ingredient).to_not be_valid)
        end
      end
    end

    # ==========================
    # AMOUNT VALIDATIONS
    # ==========================
    context 'amount', :amount_context do
      [
        # Valid
        { amount: 1, is_valid: true },
        { amount: 10, is_valid: true },
        { amount: 1_000, is_valid: true },
        { amount: 9_999, is_valid: true },

        # Invalid
        { amount: 10_000, is_valid: false },
        { amount: 100_000, is_valid: false },

        # Edge cases: unexpected data type
        { amount: nil, is_valid: false },
        { amount: '233', is_valid: true },
        { amount: '2_433', is_valid: true },
        { amount: "hey", is_valid: false },
        { amount: true, is_valid: false }
      ].each do |example|
        amount = example[:amount]
        size_or_datatype = amount.is_a?(Integer) ? "value: #{amount}" : amount.class

        it "#{example[:is_valid] ? 'accepts ' : 'rejects in'}valid amount with #{size_or_datatype}" do
          recipe = Ingredient.new(valid_attributes.merge(amount: amount))
          example[:is_valid] ? (expect(recipe).to be_valid) : (expect(recipe).to_not be_valid)
        end
      end
    end

    # ======================================
    # CATEGORIES VALIDATIONS
    # ======================================
    # context 'description', :description_context do
    #   [
    #     # Invalid description lower partition 0
    #     { description: '', is_valid: false }, # invalid lower
    #
    #     # Valid description partition 1 - 2_000
    #     { description: 'A', is_valid: true }, # valid lower
    #     { description: 'AA', is_valid: true }, # +1 char
    #     { description: 'I like AI food' * 15, is_valid: true }, # equivalence partition
    #     { description: 'a' * 1_999, is_valid: true }, # -1 char from valid upper
    #     { description: 'a' * 2_000, is_valid: true }, # valid upper
    #
    #     # Invalid description partition > 2_000
    #     { description: 'a' * 2_001, is_valid: false }, # +1 char
    #     { description: 'I like AI food' * 500, is_valid: false }, # equivalence partition
    #
    #     # Edge cases: unexpected data type
    #     { description: nil, is_valid: false },
    #     { description: 1, is_valid: true },
    #     { description: true, is_valid: true }
    #   ].each do |example|
    #     description = example[:description]
    #     size_or_datatype = description.is_a?(String) ? "length #{description.size}" : description.class
    #
    #     it "#{example[:is_valid] ? 'accepts ' : 'rejects in'}valid description with #{size_or_datatype}" do
    #       recipe = Recipe.new(valid_attributes.merge(description: description))
    #       example[:is_valid] ? (expect(recipe).to be_valid) : (expect(recipe).to_not be_valid)
    #     end
    #   end
    # end
  end
end
