class Account < ApplicationRecord
  has_secure_password

  has_many :users, dependent: :destroy
  has_many :meal_plans, through: :users

  validates :username, presence: true, uniqueness: true
end

