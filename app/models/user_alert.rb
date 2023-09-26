class UserAlert < ApplicationRecord
  before_save :set_target_blank

  has_many :users_user_alerts
  has_many :users, through: :users_user_alerts
  has_rich_text :content

  scope :unread, -> { where(read_at: nil) }

  private

  def set_target_blank
    content.body = content.body.to_s.gsub('<a href', '<a target="_blank" href')
  end
end
