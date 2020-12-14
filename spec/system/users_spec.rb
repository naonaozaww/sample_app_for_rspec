require 'rails_helper'

RSpec.describe 'Users', type: :system do
  let(:user) { create(:user) }
  describe 'ログイン前' do
    describe 'ユーザー新規登録' do
      context 'フォームの入力値が正常' do
        it 'ユーザーの新規作成が成功する' do
          visit sign_up_path
          expect {
            fill_in 'Email', with: 'foo@example.com'
            fill_in 'Password', with: '123456'
            fill_in 'Password confirmation', with: '123456'
            click_button 'SignUp'
          }.to change { User.count }.by(1)
          expect(page).to have_content('User was successfully created.')
          expect(page).to have_content('Login')
        end
      end
      context 'メールアドレスが未入力' do
        it 'ユーザーの新規作成が失敗する' do
          visit sign_up_path
          expect {
            fill_in 'Email', with: ''
            fill_in 'Password', with: '123456'
            fill_in 'Password confirmation', with: '123456'
            click_button 'SignUp'
          }.to change { User.count }.by(0)
          expect(page).to have_content("Email can't be blank")
          expect(page).to have_content('SignUp')
        end
      end
      context '登録済のメールアドレスを使用' do
        it 'ユーザーの新規作成が失敗する' do
          visit sign_up_path
          user
          expect {
            fill_in 'Email', with: user.email
            fill_in 'Password', with: '123456'
            fill_in 'Password confirmation', with: '123456'
            click_button 'SignUp'
          }.to change { User.count }.by(0)
          expect(page).to have_content('Email has already been taken')
          expect(page).to have_content('SignUp')
        end
      end
    end

    describe 'マイページ' do
      context 'ログインしていない状態' do
        it 'マイページへのアクセスが失敗する' do
          visit user_path user
          expect(page).to have_content('Login required')
          expect(page).to have_content('Login')
        end
      end
    end

    describe 'タスク新規作成ページ' do
      context 'ログインしていない状態' do
        it 'タスク新規作成ページへのアクセスが失敗する' do
          visit new_task_path user
          expect(page).to have_content('Login required')
          expect(page).to have_content('Login')
        end
      end
    end

    describe 'ユーザー編集ページ' do
      context 'ログインしていない状態' do
        it 'ユーザー編集ページへのアクセスが失敗する' do
          visit edit_user_path user
          expect(page).to have_content('Login required')
          expect(page).to have_content('Login')
        end
      end
    end
  end

  describe 'ログイン後' do
    describe 'ユーザー編集' do
      context 'フォームの入力値が正常' do
        it 'ユーザーの編集が成功する' do
          sign_in_as user
          expect(page).to have_content('Login successful')
          click_on 'Mypage'
          click_link 'Edit'
          fill_in 'Email', with: 'bazbaz@example.com'
          fill_in 'Password', with: '123456'
          fill_in 'Password confirmation', with: '123456'
          click_button 'Update'
          expect(page).to have_content('User was successfully updated.')
          expect(page).to have_content('bazbaz@example.com')
        end
      end
      context 'メールアドレスが未入力' do
        it 'ユーザーの編集が失敗する' do
          sign_in_as user
          expect(page).to have_content('Login successful')
          click_on 'Mypage'
          click_link 'Edit'
          fill_in 'Email', with: ''
          fill_in 'Password', with: '123456'
          fill_in 'Password confirmation', with: '123456'
          click_button 'Update'
          expect(page).to have_content("Email can't be blank")
          expect(page).to have_content('Edit')
        end
      end
      context '登録済のメールアドレスを使用' do
        it 'ユーザーの編集が失敗する' do
          update_user = create(:user)
          another_user = create(:user)
          sign_in_as update_user
          expect(page).to have_content('Login successful')
          click_on 'Mypage'
          click_link 'Edit'
          fill_in 'Email', with: another_user.email
          fill_in 'Password', with: '123456'
          fill_in 'Password confirmation', with: '123456'
          click_button 'Update'
          expect(page).to have_content('Email has already been taken')
          expect(page).to have_content('Editing User')
        end
      end
      context '他ユーザーの編集ページにアクセス' do
        it '編集ページへのアクセスが失敗する' do
          update_user = create(:user)
          another_user = create(:user)
          sign_in_as update_user
          visit edit_user_path(another_user)
          expect(page).to have_content('Forbidden access.')
          expect(page).to have_content(update_user.email)
        end
      end
    end

    describe 'マイページ' do
      context 'タスクを作成' do
        it '新規作成したタスクが表示される' do
          sign_in_as user
          click_link "New task"
          expect {
            fill_in "Title", with: "sample"
            fill_in "Content", with: "content"
            select "todo", from: "Status"
            fill_in "Deadline", with: "002020,12,16,12:00"
            click_button "Create Task"
          }.to change { user.tasks.count }.by(1)
          expect(page).to have_content('Task was successfully created.')
          click_link "Mypage"
          expect(page).to have_content('sample')
        end
      end

      context 'タスクを削除' do
        it 'タスクの削除が成功する' do
          sign_in_as user
          click_link "New task"
          expect {
            fill_in "Title", with: "sample"
            fill_in "Content", with: "content"
            select "todo", from: "Status"
            fill_in "Deadline", with: "002020,12,16,12:00"
            click_button "Create Task"
          }.to change { user.tasks.count }.by(1)
          click_link "Mypage"
          click_link "Destroy"
          expect {
            expect(page.accept_confirm).to eq 'Are you sure?'
            expect(page).to have_content('Task was successfully destroyed.')
          }.to change { user.tasks.count }.by(-1)
        end
      end

      context 'タスクの作成に失敗する' do
        it '未入力の場合タスクの作成に失敗する' do
          sign_in_as user
          click_link "New task"
          expect {
            fill_in "Title", with: ""
            fill_in "Content", with: "content"
            select "todo", from: "Status"
            fill_in "Deadline", with: "002020,12,16,12:00"
            click_button "Create Task"
          }.to change { user.tasks.count }.by(0)
          expect(page).to have_content("Title can't be blank")
          expect(page).to have_content('New Task')
        end
      end

      context 'タスクの編集に失敗する' do
        it '未入力の場合タスクの編集に失敗する' do
          task = create(:task, title: 'sample')
          sign_in_as task.user
          click_link "Edit"
          fill_in "Title", with: ""
          click_button "Update Task"
          expect(page).to have_content("Title can't be blank")
          click_link "Task list"
          expect(page).to have_content('sample')
        end
      end
    end
  end
end
