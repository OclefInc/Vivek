# == Schema Information
#
# Table name: assignments
#
#  id          :bigint           not null, primary key
#  composition :string
#  student     :string
#  teacher     :string
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#
class Assignment < ApplicationRecord
    has_many :lessons
end
