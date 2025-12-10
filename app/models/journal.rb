# == Schema Information
#
# Table name: journals
#
#  id             :bigint           not null, primary key
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#  composition_id :bigint           not null
#  user_id        :bigint           not null
#
# Indexes
#
#  index_journals_on_composition_id  (composition_id)
#  index_journals_on_user_id         (user_id)
#
# Foreign Keys
#
#  fk_rails_...  (composition_id => compositions.id)
#  fk_rails_...  (user_id => users.id)
#
class Journal < ApplicationRecord
  belongs_to :composition, touch: true
  belongs_to :user, touch: true
  has_many :journal_entries, dependent: :destroy

  has_rich_text :description
  has_one_attached :summary_video
  has_one_attached :video_thumbnail
  has_many :comments, as: :annotation

  delegate :name, to: :composition

  has_many :comments, as: :annotation
  has_many :subscriptions, as: :subscribable, dependent: :destroy
  has_many :subscribers, through: :subscriptions, source: :user
  has_many :bookmarks, as: :bookmarkable, dependent: :destroy

  def to_param
    "#{id}-#{name.parameterize}-#{user.name.parameterize}"
  end

  def first_journal_entry
    journal_entries.order(:sort).first
  end

  def generate_video_thumbnail
    require "vips"

    title = name
    subtitle = user.name

    if journal_entries.any?
      start_date = journal_entries.minimum(:date)&.strftime("%b %d, %Y")
      end_date = journal_entries.maximum(:date)&.strftime("%b %d, %Y")
      count = journal_entries.count
      entry_count_text = "#{count} #{'Entries'.pluralize(count)}"
      if !complete?
        entry_count_text += " (In Progress)"
      end
      date_range_text = "#{start_date} - #{end_date}"
    else
      entry_count_text = ""
      date_range_text = ""
    end

    svg = <<~SVG
      <svg width="1200" height="630" xmlns="http://www.w3.org/2000/svg">
        <rect width="100%" height="100%" fill="#1f2937"/>
        <text x="50%" y="35%" dominant-baseline="middle" text-anchor="middle" fill="white" font-family="Arial, Helvetica, sans-serif" font-size="60" font-weight="bold">
          #{CGI.escapeHTML(title)}
        </text>
        <text x="50%" y="50%" dominant-baseline="middle" text-anchor="middle" fill="#9ca3af" font-family="Arial, Helvetica, sans-serif" font-size="40">
          #{CGI.escapeHTML(subtitle)}
        </text>
        <text x="50%" y="65%" dominant-baseline="middle" text-anchor="middle" fill="#9ca3af" font-family="Arial, Helvetica, sans-serif" font-size="35">
          #{CGI.escapeHTML(entry_count_text)}
        </text>
        <text x="50%" y="75%" dominant-baseline="middle" text-anchor="middle" fill="#9ca3af" font-family="Arial, Helvetica, sans-serif" font-size="30">
          #{CGI.escapeHTML(date_range_text)}
        </text>
      </svg>
    SVG

    image = Vips::Image.new_from_buffer(svg, "")

    Tempfile.create([ "thumbnail", ".png" ]) do |file|
      image.write_to_file(file.path)
      video_thumbnail.attach(io: File.open(file.path), filename: "thumbnail.png", content_type: "image/png")
    end
  end

  after_save :enqueue_thumbnail_generation, if: :saved_change_to_summary_video_attachment?

  def saved_change_to_summary_video_attachment?
    attachment_changes["summary_video"].present?
  end

  def enqueue_thumbnail_generation
    GenerateVideoThumbnailJob.perform_later(self)
  end
end
