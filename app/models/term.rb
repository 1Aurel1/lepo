# == Schema Information
#
# Table name: terms
#
#  id         :integer          not null, primary key
#  sourced_id :string
#  title      :string
#  start_at   :datetime
#  end_at     :datetime
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class Term < ApplicationRecord
  has_many :courses, -> { where('courses.enabled = ?', true) }
  validates_presence_of :end_at
  validates_presence_of :start_at
  validates_presence_of :title
  validates_uniqueness_of :sourced_id, allow_nil: true
  validates_uniqueness_of :title

  # ====================================================================
  # Public Functions
  # ====================================================================
  def self.sync_roster(rterms)
    # Create and Update with OneRoster data

    # Synchronous term condition
    now = Time.zone.now
    rterms.select!{|rt| ((Time.zone.parse(rt['startDate']) - 1.month)...Time.zone.parse(rt['endDate'])).cover? now}

    ids = []
    rterms.each do |rt|
      term = Term.find_or_initialize_by(sourced_id: rt['sourcedId'])
      if term.update_attributes(title: rt['title'], start_at: rt['startDate'], end_at: rt['endDate'])
        ids.push({id: term.id, sourced_id: term.sourced_id, status: term.status})
      end
    end
    ids
  end

  def deletable?(user_id)
    return false if new_record?
    user = User.find user_id
    user && user.system_staff? && courses.size.zero?
  end

  def status
    now = Time.zone.now
    if now < start_at
      'draft'
    elsif (end_at - 1.day) <= now
      # To propery update course status, start date of the status must be less than term.end_at
      'archived'
    else
      'open'
    end
  end
end
