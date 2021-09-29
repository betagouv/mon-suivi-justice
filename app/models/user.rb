class User < ApplicationRecord
  has_paper_trail

  belongs_to :organization

  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :trackable and :omniauthable
  devise :invitable, :database_authenticatable, :timeoutable,
         :recoverable, :rememberable, :validatable

  enum role: %i[admin bex cpip]

  validates :first_name, :last_name, :role, presence: true

  def name
    "#{last_name.upcase} #{first_name.capitalize}"
  end
end
