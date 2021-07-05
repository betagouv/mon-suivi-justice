class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :invitable, :database_authenticatable,
         :recoverable, :rememberable, :validatable

  enum role: %i[admin bex cpip]

  validates :first_name, :last_name, :role, presence: true

  def name
    "#{last_name.upcase} #{first_name.capitalize}"
  end
end
