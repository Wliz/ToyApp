require 'test_helper'

class UsersSignupTest < ActionDispatch::IntegrationTest
  # test "the truth" do
  #   assert true
  # end
  def setup
    ActionMailer::Base.deliveries.clear
  end
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
    assert_select 'div#error_explanation'
  end

  test 'valid signup information with account activation' do
    assert_difference 'User.count', 1 do
      post users_path, params: {
        user: {
          name: 'zhuomi',
          email: 'wanglizheng@skio.cn',
          password: '123456',
          password_confirmation: '123456'
        }
      }
    end
    assert_equal 1, ActionMailer::Base.deliveries.size
    user = assigns(:user)
    # 激活之前登录
    log_in_as(user)
    assert_not logged_in?
    # 激活令牌无效
    get edit_account_activation_path('invalid token', email: user.email)
    assert_not logged_in?
    # 令牌有效， 但地址不对
    get edit_account_activation_path(user.activation_token, email: 'wang')
    assert_not logged_in?
    # 令牌有效，地址正确
    get edit_account_activation_path(user.activation_token, email: user.email)
    assert user.reload.activated?

    follow_redirect!
    assert_template 'users/show'
    assert flash
  end
end
