class UserAlert < ApplicationRecord
  attr_readonly :services
  attr_readonly :roles

  before_save :set_target_blank

  has_many :user_user_alerts, dependent: :destroy
  has_many :users, through: :user_user_alerts

  has_rich_text :content

  scope :unread, -> { where(read_at: nil) }

  def self.unread_by(user)
    joins(:user_user_alerts).where(user_user_alerts: { user_id: user.id, read_at: nil })
  end

  private

  def set_target_blank
    content.body = content.body.to_s.gsub('<a href', '<a target="_blank" href')
  end
end
