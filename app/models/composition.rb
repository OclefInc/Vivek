# == Schema Information
#
# Table name: compositions
#
#  id         :bigint           not null, primary key
#  composer   :string
#  name       :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
class Composition < ApplicationRecord
    validates_presence_of :name, :composer
    has_many :assignments
    has_many :sheet_musics
    has_rich_text :description
end
