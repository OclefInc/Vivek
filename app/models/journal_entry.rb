# == Schema Information
#
# Table name: journal_entries
#
#  id               :bigint           not null, primary key
#  date             :date
#  name             :string
#  sort             :integer          default(1000)
#  video_end_time   :integer
#  video_start_time :integer
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#  journal_id       :bigint           not null
#
# Indexes
#
#  index_journal_entries_on_journal_id  (journal_id)
#
# Foreign Keys
#
#  fk_rails_...  (journal_id => journals.id)
#
class JournalEntry < ApplicationRecord
  belongs_to :journal, touch: true

  include RailsSortable::Model
  set_sortable :sort  # Indicate a sort column

  has_many :comments, as: :annotation
  has_rich_text :description

  has_one_attached :entry_video
  has_one_attached :video_thumbnail
  has_many :bookmarks, as: :bookmarkable, dependent: :destroy

  before_validation :assign_default_name, on: :create
  before_create :assign_sort_position
  before_create :assign_default_date

  validates_presence_of :name

  def to_param
    "#{id}-#{name&.parameterize || 'entry'}"
  end

  def next_entry
    journal.journal_entries.where("sort > ?", sort).order(:sort).first
  end

  def previous_entry
    journal.journal_entries.where("sort < ?", sort).order(sort: :desc).first
  end

  alias_method :next, :next_entry
  alias_method :previous, :previous_entry

  after_create :notify_subscribers
  after_create_commit :regenerate_journal_thumbnail
  after_destroy_commit :regenerate_journal_thumbnail
  after_update_commit :regenerate_journal_thumbnail, if: :saved_change_to_date?

  def notify_subscribers
    journal.subscribers.each do |user|
      JournalMailer.new_journal_entry_notification(user, self).deliver_later
    end
  end

  def regenerate_journal_thumbnail
    GenerateVideoThumbnailJob.perform_later(journal) if journal
  end

  after_save :enqueue_thumbnail_generation, if: :saved_change_to_thumbnail_attributes?

  def saved_change_to_thumbnail_attributes?
    saved_change_to_name? || saved_change_to_date?
  end

  def enqueue_thumbnail_generation
    GenerateJournalEntryThumbnailJob.set(wait: 1.minute).perform_later(self, {
      name: name,
      date: date&.to_s
    })
  end

  def generate_video_thumbnail
    require "vips"

    title = name
    subtitle = "#{journal.name}"
    user_name = user&.name || ""
    journal_entry_date = date&.strftime("%b %d, %Y") || ""

    svg = <<~SVG
      <svg width="1200" height="630" xmlns="http://www.w3.org/2000/svg">
        <rect width="100%" height="100%" fill="#1f2937"/>
        <text x="50%" y="35%" dominant-baseline="middle" text-anchor="middle" fill="white" font-family="Arial, Helvetica, sans-serif" font-size="60" font-weight="bold">
          #{CGI.escapeHTML(title)}
        </text>
        <text x="50%" y="50%" dominant-baseline="middle" text-anchor="middle" fill="#9ca3af" font-family="Arial, Helvetica, sans-serif" font-size="40">
          #{CGI.escapeHTML(subtitle)}
        </text>
        <text x="50%" y="60%" dominant-baseline="middle" text-anchor="middle" fill="#9ca3af" font-family="Arial, Helvetica, sans-serif" font-size="30">
          #{CGI.escapeHTML(user_name)}
        </text>
        <text x="50%" y="70%" dominant-baseline="middle" text-anchor="middle" fill="#9ca3af" font-family="Arial, Helvetica, sans-serif" font-size="30">
          #{CGI.escapeHTML(journal_entry_date)}
        </text>
      </svg>
    SVG

    image = Vips::Image.new_from_buffer(svg, "")

    Tempfile.create([ "thumbnail", ".png" ]) do |file|
      image.write_to_file(file.path)
      video_thumbnail.attach(io: File.open(file.path), filename: "thumbnail.png", content_type: "image/png")
    end
  end

  private
    def assign_default_name
      # set name to date if name is blank
      self.name = Date.today.to_s if name.blank? && entry_video.attached?
    end

    def assign_sort_position
      # Set sort to the next position after the last lesson in the assignment
      if journal.present?
        max_sort = journal.journal_entries.maximum(:sort) || 0
        self.sort = max_sort + 1
      end
    end

    def assign_default_date
      # Set date to today if not already set
      self.date = Date.today if date.blank?
    end
end
