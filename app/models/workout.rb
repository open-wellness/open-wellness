class Workout < ApplicationRecord
  include PgSearch
  
  pg_search_scope :filtered_search,
    against: [:title, :description],
    using: [:tsearch, :trigram]
  
  has_rich_text :description
  has_one_attached :video_clip
  
  validates :video_clip, presence: true
  validates :title, length: { in: 2..25 }
  validates :description, length: { minimum: 100 }
end
