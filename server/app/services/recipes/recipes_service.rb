class Recipes::RecipesService
  def self.call(recipe:, uploaded_file:, request:)
    processor = ImageUpload::Processor.new(
      uploaded_file: uploaded_file,
      request: request,
      upload_dir: Rails.root.join('public', 'uploads', 'recipes')
    )

    result = processor.process
    return result unless result.success?

    delete_old_image(recipe: recipe)
    recipe.update(image_url: result.public_url)

    result
  end

  def self.delete_old_image(recipe:)
    return unless recipe.image_url.present?

    image_path = URI.parse(recipe.image_url).path
    full_path = Rails.root.join('public', image_path.delete_prefix('/'))
    File.delete(full_path) if File.exist?(full_path)
  rescue => e
    Rails.logger.error("Failed to delete old recipe image: #{e.message}")
  end
end
