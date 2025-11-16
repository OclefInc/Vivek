# == Schema Information
#
# Table name: chapters_tutorials
#
#  id          :bigint           not null, primary key
#  sort        :integer
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  chapter_id  :bigint           not null
#  tutorial_id :bigint           not null
#
# Indexes
#
#  index_chapters_tutorials_on_chapter_id   (chapter_id)
#  index_chapters_tutorials_on_tutorial_id  (tutorial_id)
#
# Foreign Keys
#
#  fk_rails_...  (chapter_id => chapters.id)
#  fk_rails_...  (tutorial_id => tutorials.id)
#
class ChaptersTutorial < ApplicationRecord
  include RailsSortable::Model
  set_sortable :sort

  belongs_to :chapter
  belongs_to :tutorial

  validates :chapter_id, uniqueness: { scope: :tutorial_id }
end
