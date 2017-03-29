require 'test_helper'

class UsersSignupTest < ActionDispatch::IntegrationTest
	# test "the truth" do
	#   assert true
	# end
	# 用户注册的集成测试
	test 'invalid signup information' do
		# 发送注册请求
		assert_no_difference 'User.count' do
			post users_path, params: {
			user: {
			name:                  '',
			email:                 'user@invalid',
			password:              'foo',
			password_confirmation: 'bar'
			}
			}
		end
		assert_template 'users/new'
		# assert_select 'div#<CSS id for error explanation>'
		# assert_select 'div.<CSS class for field with error>'
	end
end
