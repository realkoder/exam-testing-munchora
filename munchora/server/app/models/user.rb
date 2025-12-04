class User < ApplicationRecord
  self.primary_key = 'id'

  before_create -> { self.id ||= SecureRandom.uuid }

  has_many :recipes, dependent: :destroy
  has_many :llm_usages, dependent: :nullify
  has_many :grocery_lists, foreign_key: :owner_id, dependent: :destroy
  has_many :grocery_list_shares, dependent: :destroy
  has_many :shared_grocery_lists, through: :grocery_list_shares, source: :grocery_list
  has_many :subscriptions
  has_many :invoices
  has_many :recipe_suggestions
  has_many :recipe_comments, dependent: :destroy
  has_many :recipe_likes, dependent: :destroy
  has_many :recipe_suggestions, dependent: :destroy

  validates :email, presence: true, length: { minimum: 6, maximum: 100 }, uniqueness: true, format: { with: URI::MailTo::EMAIL_REGEXP }, if: -> { provider.blank? }

  validates :first_name, presence: true, length: { minimum: 2, maximum: 60 }
  validates :last_name, presence: true, length: { minimum: 2, maximum: 60 }
  validates :bio, presence: false, length: { maximum: 2000 }

  # If provider is present, uid must be present (for OAuth)
  validates :uid, presence: true, if: -> { provider.present? }, length: { maximum: 100 }
  validates :provider, presence: true, if: -> { uid.present? }, length: { maximum: 40 }

  # For manual signup (no provider), password must be present on create
  def password=(unencrypted_password)
    # Only assign string values, otherwise nil
    if unencrypted_password.is_a?(String)
      super(unencrypted_password)
    else
      super(nil)
    end
  end

  has_secure_password validations: false
  validates :password, presence: true, length: { minimum: 6, maximum: 50 }, if: -> { provider.blank? }, on: :create

  validates :image_src, length: { minimum: 14, maximum: 400 }, format: URI.regexp(%w[http https]), allow_blank: true

  # Don't want to return password_digest when serializing
  def as_json(options = {})
    super({ except: [:email, :password_digest] }.merge(options)).merge(
      'fullname' => "#{first_name} #{last_name}", # client relies on attribute fullname instead of first_name / last_name
    )
  end
end
