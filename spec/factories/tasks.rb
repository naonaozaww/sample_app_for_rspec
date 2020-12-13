FactoryBot.define do
  factory :task do
    title { "sample" }
    content { "baz" }
    status { 0 }
    deadline { 1.day.from_now }
    association :user
  end
end
