# == Schema Information
#
# Table name: users
#
#  id                :integer          not null, primary key
#  name              :string
#  email             :string
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  password_digest   :string
#  remember_digest   :string
#  admin             :boolean          default(FALSE)
#  activation_digest :string
#  activated         :boolean          default(FALSE)
#  activated_at      :datetime
#
# Indexes
#
#  index_users_on_email  (email) UNIQUE
#

class User < ApplicationRecord
  attr_accessor :remember_token, :activation_token
  before_create :create_activation_digest
  # validates :name, presence: true
  # 忽略大小写的email邮件地址正则表达式
  VALID_EMAIL_REGEXP = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i

  validates :name, :email, presence: true
  validates :name, length: { maximum: 50 }
  validates :email, length: { maximum: 255 }, format: VALID_EMAIL_REGEXP, uniqueness: { case_sensitive: false }
  validates :password, presence: true, length: { minimum: 6 }, allow_nil: true

  # 保存时全部转为小写
  # before_save { self.email = email.downcase }

  # 用户密码确认
  has_secure_password

  # remember user to database
  def remember
    self.remember_token = User.new_token
    # no valid
    update_attribute(:remember_digest, User.digest(remember_token))
  end

  # forget user to database
  def forget
    update_attribute(:remember_digest, nil)
  end

  # authenticate user token, digest
  def authenticated?(remember_token)
    return false unless remember_digest
    BCrypt::Password.new(remember_digest).is_password?(remember_token)
  end

  # return string hash
  def self.digest(string)
    cost = ActiveModel::SecurePassword.min_cost ? BCrypt::Engine::MIN_COST : BCrypt::Engine.cost
    BCrypt::Password.create(string, cost: cost)
  end

  # return remember digest token
  class << self
    def new_token
      SecureRandom.urlsafe_base64
    end
  end

  private

  # 创建并赋值激活令牌和摘要
  def create_activation_digest
    # 为实例变量赋值需要使用self，获取其变量值不需要
    self.activation_token = User.new_token
    self.activation_digest = User.digest(activation_token)
  end
end
