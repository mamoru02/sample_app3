class UsersSignupTest < ActionDispatch::IntegrationTest

  def setup
    ActionMailer::Base.deliveries.clear
  end

      # 無効なサインアップ情報
  test "invalid signup information" do
    get signup_path
    assert_no_difference 'User.count' do  # User.count == User.count ⇦ post users_path
      post users_path, params: { user: { name:  "",
                                         email: "user@invalid",
                                         password:              "foo",
                                         password_confirmation: "bar" } }
    end
    assert_template 'users/new'
    assert_select 'div#error_explanation' # <div id="error_explanation">foobar</div>
    assert_select 'div.field_with_errors' # <div class="field_with_errors">foobar</div>
  end

      # アカウントアクティベーションを伴う有効なサインアップ情報
  test "valid signup information with account activation" do
    get signup_path
    assert_difference 'User.count', 1 do  # User.count + 1 == User.count ⇦ post users_path
      post users_path, params: { user: { name:  "Example User",
                                         email: "user@example.com",
                                         password:              "password",
                                         password_confirmation: "password" } }
    end
    assert_equal 1, ActionMailer::Base.deliveries.size
    user = assigns(:user)
    assert_not user.activated?
    # 有効化していない状態でログインしてみる
    log_in_as(user)
    assert_not is_logged_in?
    # 有効化トークンが不正な場合
    get edit_account_activation_path("invalid token", email: user.email)
    assert_not is_logged_in?
    # トークンは正しいがメールアドレスが無効な場合
    get edit_account_activation_path(user.activation_token, email: 'wrong')
    assert_not is_logged_in?
    # 有効化トークンが正しい場合
    get edit_account_activation_path(user.activation_token, email: user.email)
    assert user.reload.activated?
    follow_redirect!
    assert_template 'users/show'
    assert is_logged_in?
  end
end
