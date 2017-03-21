class Micropost < ApplicationRecord
	belongs_to :user
	validates :content, length: { maximum: 140 }, presence: true
	# validates :content, presence: { message: '微博内容不能为空！' }
end
