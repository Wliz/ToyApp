class User < ApplicationRecord
	# validates :name, presence: true
	# 忽略大小写的email邮件地址正则表达式
	VALID_EMAIL_REGEXP = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i

	validates_presence_of :name, :email, :password
	validates :name, length: { maximum: 50 }
	validates :email, length: { maximum: 255 }, format: VALID_EMAIL_REGEXP, uniqueness: { case_sensitive: false }
	validates :password, length: { minimum: 6 }

	# 保存时全部转为小写
	# before_save { self.email = email.downcase }

	# 用户密码确认
	has_secure_password

	# return string hash
	def User.digest(string)
		cost = ActiveModel::SecurePassword.min_cost ? BCrypt::Engine::MIN_COST : BCrypt::Engine.cost
		BCrypt::Password.create(string, cost: cost)
	end
end
