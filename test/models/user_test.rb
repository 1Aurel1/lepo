# == Schema Information
#
# Table name: users
#
#  id                 :integer          not null, primary key
#  signin_name        :string
#  authentication     :string           default("local")
#  hashed_password    :string
#  salt               :string
#  token              :string
#  role               :string           default("user")
#  familyname         :string
#  familyname_alt     :string
#  givenname          :string
#  givenname_alt      :string
#  folder_id          :string
#  image_file_name    :string
#  image_content_type :string
#  image_file_size    :integer
#  image_updated_at   :datetime
#  web_url            :string
#  description        :text
#  default_note_id    :integer          default(0)
#  last_signin_at     :datetime
#  archived_at        :datetime
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#

require 'test_helper'

class UserTest < ActiveSupport::TestCase
  # ====================================================================
  # Validation Tests
  # ====================================================================
  # test for valid user data
  test 'a user with valid data is valid' do
    assert build(:user).valid?
    assert build(:admin_user).valid?
    assert build(:manager_user).valid?
    assert build(:suspended_user).valid?
    assert build(:ldap_user).valid?
  end

  # test for validates_presence_of :familyname
  test 'a user without familyname is invalid' do
    assert_invalid build(:user, familyname: ''), :familyname
    assert_invalid build(:user, familyname: nil), :familyname
  end

  # test for validates_presence_of :folder_id
  # this test is no need because of before_validation callback

  # test for validates_presence_of :hashed_password, if: "authentication == 'local'"
  test 'a user without hashed_password is invalid' do
    assert_invalid build(:user, hashed_password: ''), :hashed_password
    assert_invalid build(:user, hashed_password: nil), :hashed_password
  end

  # test for validates_presence_of :salt, if: "authentication == 'local'"
  test 'a user without salt is invalid' do
    assert_invalid build(:user, salt: ''), :salt
    assert_invalid build(:user, salt: nil), :salt
  end

  # test for validates_presence_of :signin_name
  test 'a user without signin_name is invalid' do
    assert_invalid build(:user, signin_name: ''), :signin_name
    assert_invalid build(:user, signin_name: nil), :signin_name
  end

  # test for validates_presence_of :token
  # this test is no need because of before_validation callback

  # test for validates_uniqueness_of :folder_id
  test 'some users with same folder_id are invalid' do
    user = create(:user)
    assert_invalid build(:user, folder_id: user.folder_id), :folder_id
  end

  # test for validates_uniqueness_of :signin_name
  test 'some users with same signin_name are invalid' do
    user = create(:user)
    assert_invalid build(:user, signin_name: user.signin_name), :signin_name
  end

  # test for validates_uniqueness_of :token
  test 'some users with same token are invalid' do
    user = create(:user)
    assert_invalid build(:user, token: user.token), :token
  end

  # test for validates_inclusion_of :authentication, in: %w[local ldap]
  test 'a user with authentication that is not included in [local ldap] is invalid' do
    assert_invalid build(:user, authentication: ''), :authentication
    assert_invalid build(:user, authentication: nil), :authentication
  end

  # test for validates_inclusion_of :role, in: %w[admin manager user suspended]
  test 'a user with role that is not included in [admin manager user suspended] is invalid' do
    assert_invalid build(:user, role: ''), :role
    assert_invalid build(:user, role: nil), :role
  end

  # test for validates_confirmation_of :password
  test 'a user with password that is not same to password_confirmation is invalid' do
    assert_invalid build(:user, password_confirmation: 'temporary2'), :password_confirmation
  end

  # test for validate :password_non_blank, if: "authentication == 'local'"
  test 'a user without password is invalid' do
    assert_invalid build(:user, password: ''), :password
    assert_invalid build(:user, password: nil), :password
  end

  # test for validates_length_of :password, in: USER_PASSWORD_MIN_LENGTH..USER_PASSWORD_MAX_LENGTH, allow_blank: true, if: "authentication == 'local'"
  test 'a user with incorrect length password is invalid' do
    assert_invalid build(:user, password: 'a' * (USER_PASSWORD_MIN_LENGTH - 1)), :password
    assert_invalid build(:user, password: 'a' * (USER_PASSWORD_MAX_LENGTH + 1)), :password
  end
end
