class UserAlert < ApplicationRecord
  ALLOWED_LINK_DOMAIN = 'gouv.fr'.freeze

  attr_readonly :services
  attr_readonly :roles

  validate :links_point_to_authorized_domains

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
    self.content = content.body.fragment.replace('a[href]') do |link|
      link['target'] = '_blank'
      link['rel'] = 'noopener noreferrer'
      link
    end
  end

  def links_point_to_authorized_domains
    return if content.blank?

    Nokogiri::HTML::DocumentFragment.parse(content.body.to_s).css('a[href]').each do |link|
      href = link['href']
      next if authorized_link?(href)

      errors.add(:content, "contient un lien vers un domaine non autorisé : #{href}")
    end
  end

  def authorized_link?(href)
    uri = begin
      URI.parse(href)
    rescue URI::InvalidURIError
      nil
    end

    uri.present? && uri.scheme.in?(%w[http https]) && authorized_host?(uri.host)
  end

  def authorized_host?(host)
    host.present? && (host == ALLOWED_LINK_DOMAIN || host.end_with?(".#{ALLOWED_LINK_DOMAIN}"))
  end
end
