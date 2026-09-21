class User < ApplicationRecord
  has_secure_password
  has_many :sessions, dependent: :destroy

  normalizes :nickname, with: ->(n) { n.strip.downcase }

  validates :nickname, presence: true, uniqueness: true
end