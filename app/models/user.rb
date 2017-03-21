class User < ApplicationRecord
	# validates :name, presence: true
	# 忽略大小写的email邮件地址正则表达式
	VALID_EMAIL_REGEXP = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i

	validates_presence_of :name, :email
	validates :name, length: { maximum: 50 }
	validates :email, length: { maximum: 255 }, format: VALID_EMAIL_REGEXP
end
