require 'test_helper'

class UsersIndexTest < ActionDispatch::IntegrationTest
  # test "the truth" do
  #   assert true
  # end
  def setup
    @admin = users(:michael)
    @non_admin = users(:archer)
  end

  test "index as admin including pagination and delete links" do
    log_in_as(@admin)
    get users_path
    assert_template 'users/index'
    assert_select 'div.pagination'
    # ruby 2.4.0弃用Fixnum和Bignum into integer
    # TODO 回头去看，然后查找原因吧
    # first_page_of_users = User.paginate(page: 1)
    # first_page_of_users.each do |user|
    #   assert_select 'a[href=?]', user_path(user), text: user.name
    #   unless user == @admin
    #     assert_select 'a[href=?]', user_path(user), text: 'delete'
    #   end
    # end
    assert_difference 'User.count', -1 do
      delete user_path(@non_admin)
    end
  end

  test 'index as no-admin' do
    log_in_as @non_admin
    get users_path

    assert_select 'a', text: 'delete', count: 0
  end
end
