require 'bcrypt'
require 'securerandom'
require 'validators/user_validator'

class User < ActiveRecord::Base
  attr_accessor :password, :password_confirmation, :remember_token

  validates :name, uniqueness: true, :length => { maximum: 255 }, presence: true
  validates :email, uniqueness: true, :length => { maximum: 255 }, presence: true

  validates_with UserValidator

  before_create do
    self.email = self.email.downcase
    self.encrypt_password!
  end

  def new?
    self.id.nil?
  end

  def authenticate_with_password(password)
    BCrypt::Password.new(self.encrypted_password) == password
  end

  def update_password!
    UserValidator.new.validate_password(self)

    if self.errors.empty?
      self.encrypt_password!
      self.save
    else
      raise Errors::CannotUpdatePassword, "Failed updating password because of
        the following reason(s): #{self.errors.full_messages.to_s}".squish
    end
  end

  def remember_me!
    self.remember_token = User.generate_remember_token
    salt = self.id

    remember_digest = BCrypt::Password.create("#{self.remember_token}_#{salt}")

    self.update(
      remember_digest: remember_digest, remember_created_at: Time.now)
  end

  def forget_me!
    self.update(remember_digest: nil)
  end

  def authenticated?(remember_token, salt)
    # NOTE: salt is actually the user id
    BCrypt::Password.new(self.remember_digest) == "#{remember_token}_#{salt}"
  end

  def notify!(message)
    $redis.publish msg_channel, message
  end

  def msg_channel
    "notifications:#{id}"
  end

  module Errors
    class CannotUpdatePassword < StandardError; end
  end

protected

  def encrypt_password!
    self.encrypted_password = BCrypt::Password.create(self.password)
    self.password = nil
    self.password_confirmation = nil
  end

  def self.generate_remember_token
    SecureRandom.urlsafe_base64
  end

end
