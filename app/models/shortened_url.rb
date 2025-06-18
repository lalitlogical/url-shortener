class ShortenedUrl < ApplicationRecord
  has_many :clicks, dependent: :destroy

  validates :original_url, presence: true
  validates :short_code, uniqueness: true

  has_secure_password :passcode, validations: false # enables `passcode=` and `authenticate`

  # Virtual attribute for plain passcode input
  attr_accessor :passcode

  before_create :set_expiration
  before_save :set_passcode_digest
  before_validation :generate_unique_code, on: :create

  scope :active, -> { where(is_active: true).where('expiration IS NULL OR expiration > ?', Time.current.utc) }

  def expired?
    expiration && expiration < Time.current.utc
  end

  private
  
  def set_passcode_digest
    if passcode.present?
      self.passcode_digest = BCrypt::Password.create(passcode)
    end
  end

  def set_expiration
    self.expiration = expiration ? Time.at(expiration).utc : nil
  end

  def generate_unique_code
    # self.short_code ||= loop do
    #   code = SecureRandom.urlsafe_base64(6)
    #   break code unless ShortenedUrl.exists?(short_code: code)
    # end
    return if short_code.present?

    tries = 0
    begin
      self.short_code = Base62ShortCodeGenerator.generate
      tries += 1
    end while self.class.exists?(short_code: short_code) && tries < 5

    raise "Could not generate unique short_code" if tries == 5
  end
end
