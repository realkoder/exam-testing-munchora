require 'rails_helper'

RSpec.describe Llm::LlmService, type: :service do
  # Arrange
  let(:user) { create(:user, email: 'test@example.com') }
  let(:service) { described_class.new(user: user) }

  # Mocking OpenAI response
  let(:mock_openai_response) do
    double(
      'OpenAI::Response',
      choices: [double('Choice', message: double('Message', content: valid_recipe_json))],
      usage: double('Usage', prompt_tokens: 100, completion_tokens: 500),
      model: 'gpt-4.1-mini'
    )
  end

  let(:valid_recipe_json) do
    {
      recipe: {
        title: 'Spaghetti Carbonara',
        description: 'Classic Italian pasta dish',
        instructions: ['Cook pasta', 'Mix eggs and cheese.', 'Combine.'],
        ingredients: [
          { name: 'Spaghetti', amount: '400', category: 'grains 🌾' },
          { name: 'Eggs', amount: '4', category: 'dairy 🥚' },
          { name: 'Parmesan', amount: '100', category: 'dairy 🥚' }
        ],
        cuisine: 'italian',
        difficulty: 'medium',
        tags: %w[pasta italian quick],
        prep_time: 10,
        cook_time: 20,
        servings: 4
      }
    }.to_json
  end

  before do
    # Stubbing the OpenAI client
    allow(OpenAIClient.chat.completions).to receive(:create)
                                              .and_return(mock_openai_response)
  end

  describe '#generate_recipe' do
    context 'when generation is successful' do
      it 'creates a recipe with correct attributes' do
        recipe = service.generate_recipe(prompt: 'Make me pasta')

        expect(recipe).to be_persisted
        expect(recipe.title).to eq('Spaghetti Carbonara')
        expect(recipe.description).to eq('Classic Italian pasta dish')
        expect(recipe.cuisine).to eq('italian')
        expect(recipe.difficulty).to eq('medium')
        expect(recipe.user).to eq(user)
        expect(recipe.is_public).to be false
      end

      it 'creates ingredients for the recipe' do
        recipe = service.generate_recipe(prompt: 'Make me pasta')

        expect(recipe.ingredients.count).to eq(3)

        spaghetti = recipe.ingredients.find_by(name: 'Spaghetti')
        expect(spaghetti.amount).to eq(400)
        expect(spaghetti.category).to eq('grains 🌾')
      end

      it 'logs LLM usage' do
        expect {
          service.generate_recipe(prompt: 'Make me pasta')
        }.to change(LlmUsage, :count).by(1)

        usage = LlmUsage.last
        expect(usage.user).to eq(user)
        expect(usage.prompt).to eq('Make me pasta')
        expect(usage.model).to eq('gpt-4.1-mini')
        expect(usage.provider).to eq('openai')
        expect(usage.prompt_tokens).to eq(100)
        expect(usage.completion_tokens).to eq(500)
      end

      it 'calls OpenAI with correct parameters' do
        service.generate_recipe(prompt: 'Make me pasta')

        expect(OpenAIClient.chat.completions).to have_received(:create).with(
          model: 'gpt-4.1-mini',
          response_format: { type: 'json_object' },
          messages: [
            { role: 'system', content: Llm::RecipeLlmInstruction::SYSTEM_PROMPT },
            { role: 'user', content: 'Make me pasta' }
          ],
          max_tokens: 2000
        )
      end
    end

    context 'when daily limit is exceeded' do
      before do
        # Create DAILY_LIMIT usage records for today
        create_list(:llm_usage, 11, user: user, created_at: Time.current)
      end

      it 'raises LlmUsageLimitExceeded error' do
        expect {
          service.generate_recipe(prompt: 'Make me pasta')
        }.to raise_error(LlmUsageLimitExceeded, /Daily AI usage limit/)
      end

      it 'does not create a recipe' do
        expect {
          service.generate_recipe(prompt: 'Make me pasta') rescue nil
        }.not_to change(Recipe, :count)
      end

      it 'does not call OpenAI API' do
        service.generate_recipe(prompt: 'Make me pasta') rescue nil
        expect(OpenAIClient.chat.completions).not_to have_received(:create)
      end
    end

    context 'when OpenAI returns invalid JSON' do
      let(:mock_openai_response) do
        double(
          'OpenAI::Response',
          choices: [double('Choice', message: double('Message', content: 'invalid json'))],
          usage: double('Usage', prompt_tokens: 100, completion_tokens: 500),
          model: 'gpt-4.1-mini'
        )
      end

      it 'raises an error and logs it' do
        expect(Rails.logger).to receive(:error).with(/Ai::ChatService error/)

        expect {
          service.generate_recipe(prompt: 'Make me pasta')
        }.to raise_error(JSON::ParserError)
      end
    end

    context 'when recipe is missing required keys' do
      let(:invalid_recipe_json) do
        {
          recipe: {
            title: 'Pasta',
            description: 'Yummy'
            # Missing other required fields
          }
        }.to_json
      end

      let(:mock_openai_response) do
        double(
          'OpenAI::Response',
          choices: [double('Choice', message: double('Message', content: invalid_recipe_json))],
          usage: double('Usage', prompt_tokens: 100, completion_tokens: 500),
          model: 'gpt-4.1-mini'
        )
      end

      it 'raises StandardError with missing keys' do
        expect {
          service.generate_recipe(prompt: 'Make me pasta')
        }.to raise_error(StandardError, /Missing keys in recipe/)
      end
    end

    context 'when ingredient has invalid category' do
      let(:recipe_with_invalid_category) do
        {
          recipe: {
            title: 'Test Recipe',
            description: 'Test',
            instructions: ['Test'],
            ingredients: [
              { name: 'Test', amount: 100, category: 'InvalidCategory' }
            ],
            cuisine: 'test',
            difficulty: 'easy',
            tags: ['test'],
            prep_time: 10,
            cook_time: 10,
            servings: 2
          }
        }.to_json
      end

      let(:mock_openai_response) do
        double(
          'OpenAI::Response',
          choices: [double('Choice', message: double('Message', content: recipe_with_invalid_category))],
          usage: double('Usage', prompt_tokens: 100, completion_tokens: 500),
          model: 'gpt-4.1-mini'
        )
      end

      it 'sets category to default "no category 📦"' do
        recipe = service.generate_recipe(prompt: 'Make me something')

        ingredient = recipe.ingredients.first
        expect(ingredient.category).to eq('no category 📦')
      end
    end
  end

  describe '#update_recipe' do
    let!(:existing_recipe) { create(:recipe, user: user, title: 'Old Title') }
    let!(:existing_ingredient) { create(:ingredient, recipe: existing_recipe, name: 'Old Ingredient') }

    let(:updated_recipe_json) do
      {
        recipe: {
          title: 'Updated Spaghetti Carbonara',
          description: 'Updated description',
          instructions: ['Updated instructions'],
          ingredients: [
            { name: 'New Spaghetti', amount: 500, category: 'grains 🌾' }
          ],
          cuisine: 'italian',
          difficulty: 'easy',
          tags: ['updated'],
          prep_time: 15,
          cook_time: 25,
          servings: 6
        }
      }.to_json
    end

    let(:mock_openai_response) do
      double(
        'OpenAI::Response',
        choices: [double('Choice', message: double('Message', content: updated_recipe_json))],
        usage: double('Usage', prompt_tokens: 150, completion_tokens: 600),
        model: 'gpt-4.1-mini'
      )
    end

    context 'when update is successful' do
      it 'updates recipe attributes' do
        recipe = service.update_recipe(prompt: 'Make it easier', recipe: existing_recipe)

        recipe.ingredients.each {|ing| puts "ingrdient name: #{ing.name}"}
        expect(recipe.title).to eq('Updated Spaghetti Carbonara')
        expect(recipe.description).to eq('Updated description')
        expect(recipe.difficulty).to eq('easy')
        expect(recipe.servings).to eq(6)
      end

      it 'replaces old ingredients with new ones' do
        service.update_recipe(prompt: 'Change ingredients', recipe: existing_recipe)

        existing_recipe.reload
        expect(existing_recipe.ingredients.count).to eq(1)
        expect(existing_recipe.ingredients.first.name).to eq('New Spaghetti')
        expect(existing_recipe.ingredients.first.amount).to eq(500)
      end

      it 'logs usage for update' do
        expect {
          service.update_recipe(prompt: 'Update this', recipe: existing_recipe)
        }.to change(LlmUsage, :count).by(1)

        usage = LlmUsage.last
        expect(usage.recipe_id).to eq(existing_recipe.id)
        expect(usage.prompt).to eq('Update this')
      end

      it 'includes original recipe in prompt to OpenAI' do
        service.update_recipe(prompt: 'Make it spicier', recipe: existing_recipe)

        expect(OpenAIClient.chat.completions).to have_received(:create) do |args|
          user_message = args[:messages].find { |m| m[:role] == 'user' }[:content]
          expect(user_message).to include('Make it spicier')
          expect(user_message).to include('Old Title')
          expect(user_message).to include('ORIGINAL RECIPE:')
        end
      end

      it 'uses transaction for atomic updates' do
        # Simulate an error during ingredient creation
        allow_any_instance_of(Recipe).to receive(:update!).and_raise(ActiveRecord::RecordInvalid)

        expect {
          service.update_recipe(prompt: 'Update', recipe: existing_recipe) rescue nil
        }.not_to change { existing_recipe.reload.ingredients.count }
      end
    end

    context 'when daily limit is exceeded' do
      before do
        create_list(:llm_usage, 11, user: user, created_at: Time.current)
      end

      it 'raises LlmUsageLimitExceeded error' do
        expect {
          service.update_recipe(prompt: 'Update this', recipe: existing_recipe)
        }.to raise_error(LlmUsageLimitExceeded)
      end

      it 'does not update the recipe' do
        original_title = existing_recipe.title

        service.update_recipe(prompt: 'Update this', recipe: existing_recipe) rescue nil

        expect(existing_recipe.reload.title).to eq(original_title)
      end
    end
  end
end
