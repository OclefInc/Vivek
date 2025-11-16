# == Schema Information
#
# Table name: chapters
#
#  id         :bigint           not null, primary key
#  name       :string
#  start_time :integer
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  lesson_id  :bigint           not null
#
# Indexes
#
#  index_chapters_on_lesson_id                 (lesson_id)
#  index_chapters_on_lesson_id_and_start_time  (lesson_id,start_time)
#
# Foreign Keys
#
#  fk_rails_...  (lesson_id => lessons.id)
#
class Chapter < ApplicationRecord
  belongs_to :lesson
  has_many :chapters_tutorials, dependent: :destroy
  has_many :tutorials, through: :chapters_tutorials

  validates :name, presence: true
  validates :start_time, presence: true, numericality: { greater_than_or_equal_to: 0 }

  default_scope { order(:start_time) }
end
