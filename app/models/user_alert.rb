class UserAlert < ApplicationRecord
  include Noticed::Model
  belongs_to :recipient, polymorphic: true

  has_rich_text :content
end
