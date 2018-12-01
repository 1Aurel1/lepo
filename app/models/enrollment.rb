# == Schema Information
#
# Table name: enrollments
#
#  id          :integer          not null, primary key
#  course_id   :integer
#  user_id     :integer
#  role        :string
#  group_index :integer          default(0)
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#

class Enrollment < ApplicationRecord
  belongs_to :course
  belongs_to :user
  validates_presence_of :course_id
  validates_presence_of :user_id
  validates_uniqueness_of :course_id, scope: [:user_id]
  # FIXME: Group work
  validates_inclusion_of :group_index, in: (0...COURSE_GROUP_MAX_SIZE).to_a
  validates_inclusion_of :role, in: %w[manager assistant learner]

  # ====================================================================
  # Public Functions
  # ====================================================================
  def self.sync_roster(course_id, user_ids, role)
    # Create and Update with OneRoster data

    user_ids.each do |user_id|
      member = Enrollment.find_or_initialize_by(course_id: course_id, user_id: user_id)
      member.update_attributes(role: role)
    end
  end

  def self.destroy_unused(course_id, user_ids)
    members = where(course_id: course_id).where.not(user_id: user_ids)
    deleted_members = []
    unless members.empty?
      deleted_members = members.destroy_all
      deleted_members.map{|m| m.user_id}
    end
  end

  def self.update_managers(course_id, current_ids, ids)
    transaction do
      # unregister
      current_ids.each do |c_id|
        if ids.include? c_id
          # neednot add or delete
          ids.delete c_id
        else
          enrollment = Enrollment.find_by(course_id: course_id, user_id: c_id, role: 'manager')
          enrollment.destroy! if enrollment.deletable?
        end
      end
      # register
      ids.each do |id|
        enrollment = Enrollment.new(course_id: course_id, user_id: id, role: 'manager')
        enrollment.save!
      end
    end
    return true
  rescue StandardError
    logger.info(e.inspect)
    return false
  end

  def self.to_roster_hash course_sourced_id, user, role
    raise if user.sourced_id.nil?
    hash = {
      classSourcedId: course_sourced_id,
      schoolSourcedId: Rails.application.secrets.roster_school_sourced_id,
      userSourcedId: user.sourced_id,
      role: self.to_roster_role(role)
    }
  end

  def self.to_roster_role role
    case role
    when 'manager'
      'teacher'
    when 'assistant'
      'aide'
    when 'learner'
      'student'
    else
      raise
    end
  end

  def deletable?
    stickies = Sticky.where(course_id: course_id, manager_id: user_id)
    case role
    when 'manager'
      course = Course.find_enabled_by course_id
      return false if course.evaluator? user_id

      manager_num = Enrollment.where(course_id: course_id, role: 'manager').size
      return (stickies.size.zero? && (manager_num > 1))
    when 'assistant'
      return stickies.size.zero?
    when 'learner'
      outcomes = Outcome.where(manager_id: user_id, course_id: course_id)
      outcomes.each do |outcome|
        return false unless outcome.outcome_messages.empty?
      end
      return stickies.size.zero?
    end
    false
  end
end
