class UserAlert < ApplicationRecord
  include Noticed::Model
  belongs_to :recipient, polymorphic: true
  before_save :set_target_blank

  scope :unread, -> { where(read_at: nil) }

  has_rich_text :content

  private

  def set_target_blank
    content.body = content.body.to_s.gsub('<a href', '<a target="_blank" href')
  end
end
