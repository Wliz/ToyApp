class User < ApplicationRecord
	has_many :microposts, -> { order id: :desc }
	# 合在一起写
	# validates_presence_of :name, :email
	# 分开写
	validates :name, presence: { message: '用户名不能为空' }
	validates :email, presence: { message: 'email不能为空' }
end
