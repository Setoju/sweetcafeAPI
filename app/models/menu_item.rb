class MenuItem < ApplicationRecord
  belongs_to :category
  has_many :order_items
  
  validates :name, presence: true,
                   length: { minimum: 2, maximum: 200 },
                   uniqueness: { scope: :category_id, case_sensitive: false, message: "already exists in this category" }
  validates :price, presence: true,
                    numericality: { greater_than: 0, less_than_or_equal_to: 10000, message: "must be between 0 and 10,000" }
  validates :size, presence: true, numericality: { only_integer: true, greater_than: 0, message: "must be positive" }
  validates :description, length: { maximum: 1000 }, allow_blank: true
  validates :image_url, format: { with: URI::DEFAULT_PARSER.make_regexp(%w[http https]), message: "must be a valid URL" },
                        allow_blank: true,
                        length: { maximum: 500 }
  validates :available, inclusion: { in: [true, false] }
  validates :category, presence: true
  validates :quantity, numericality: { only_integer: true, greater_than_or_equal_to: 0, message: "must be a non-negative integer" }
  validate :price_decimal_places
  
  private
  
  def price_decimal_places
    if price.present? && price.to_s.include?('.') && price.to_s.split('.').last.length > 2
      errors.add(:price, "can have at most 2 decimal places")
    end
  end
end
