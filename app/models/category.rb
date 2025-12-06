class Category < ApplicationRecord
  has_many :menu_items, dependent: :destroy

  validates :name, presence: true,
                   uniqueness: { case_sensitive: false },
                   length: { minimum: 2, maximum: 100 },
                   format: { with: /\A[a-zA-Z0-9\s&'-]+\z/, message: "can only contain letters, numbers, spaces, and basic punctuation" }
  validates :description, length: { maximum: 500 }, allow_blank: true

  before_validation :normalize_name

  private

  def normalize_name
    self.name = name.to_s.strip.squeeze(" ") if name.present?
  end
end
