FactoryBot.define do
  factory :topological_factor do
    sequence(:name) {|n| "Topological factor #{n}"}
    sequence(:term) {|n| "TF:#{n}" }
  end
end
