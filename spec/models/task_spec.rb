require 'rails_helper'

RSpec.describe Task, type: :model do
  # データが有効であること
  describe 'validation' do
    # 全ての属性が有効であること
    it 'is valid with all attributes' do
      task = FactoryBot.create(:task)
      expect(task).to be_valid
    end
    # タイトルが無い場合は無効であること
    it 'is invalid without title' do
      task = Task.new(title: nil)
      task.valid?
      expect(task.errors[:title]).to include("can't be blank")
    end
    # ステータスが無い場合は無効であること
    it 'is invalid without status' do
      task = Task.new(status: nil)
      task.valid?
      expect(task.errors[:title]).to include("can't be blank")
    end
    # タイトルが重複している場合は無効であること
    it 'is invalid with a duplicate title' do
      task1 = FactoryBot.create(:task)
      task2 = Task.new(title: "sample")
      task2.valid?
      expect(task2.errors[:title]).to include("has already been taken")
    end
    # 異なるタイトルの場合は有効であること
    it 'is valid with another title' do
      task1 = FactoryBot.create(:task)
      task2 = FactoryBot.build(:task, title: "sample2")
      expect(task2).to be_valid
    end
  end
end
