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
#  reset_digest      :string
#  reset_send_at     :datetime
#
# Indexes
#
#  index_users_on_email  (email) UNIQUE
#

class User < ApplicationRecord
  has_many :microposts, dependent: :destroy
  attr_accessor :remember_token, :activation_token, :reset_token
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

  # 用户密码确认，带有authenticate方法
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

  def password_reset_expired?
    reset_send_at < 2.hours.ago
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

  # 如果指定的令牌和摘要匹配true
  def authenticated?(attribute, token)
    digest = send("#{attribute}_digest")
    return false if digest.nil?
    BCrypt::Password.new(digest).is_password?(token)
  end

  # 激活账户
  def activate
    transaction do
      update_attributes!(activated: true, activated_at: Time.current)
    end
  rescue => ex
    # 默认捕获StandardError异常信息，可以指定捕获的异常
    logger.error "激活账户发生异常：#{ex.backtrace.join('\n')}"
  end

  # 发送激活邮件
  def send_activation_email
    UserMailer.account_activation(self).deliver_now
  end

  # 设置密码重设相关的属性
  def create_reset_digest
    self.reset_token = User.new_token
    transaction do
      update_attributes!(reset_digest: User.digest(reset_token), reset_send_at: Time.current)
    end
  rescue => ex
    logger.error "设置密码错误: #{ex.backtrace.join('\n')}"
  end

  # 发送密码重设邮件
  def sent_password_reset_email
    UserMailer.password_reset(self).deliver_now
  end

  private

  # 创建并赋值激活令牌和摘要
  def create_activation_digest
    # 为实例变量赋值需要使用self，获取其变量值不需要
    self.activation_token  = User.new_token
    self.activation_digest = User.digest(activation_token)
  end
end
