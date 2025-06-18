class ShortenedUrl < ApplicationRecord
  has_many :clicks, dependent: :destroy

  validates :original_url, presence: true
  validates :short_code, uniqueness: true

  before_validation :generate_unique_code, on: :create

  scope :active, -> { where(is_active: true).where('expiration IS NULL OR expiration > ?', Time.current) }

  def expired?
    expiration && expiration < Time.current
  end

  private

  def generate_unique_code
    self.short_code ||= loop do
      code = SecureRandom.urlsafe_base64(6)
      break code unless ShortenedUrl.exists?(short_code: code)
    end
  end
end
