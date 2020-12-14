module LoginSupport
  def sign_in_as(user)
    visit login_path
    fill_in "Email", with: user.email
    fill_in "Password", with: "12345678"
    click_button "Login"
  end
end

RSpec.configure do |config|
  config.include LoginSupport
end
