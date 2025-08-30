FactoryBot.define do
  factory :invoice do
    sequence(:invoice_number) { |n| "C#{30000 + n}" }
    total { rand(10.0..50.0).round(2) }
    invoice_date { rand(1.year.ago.to_date..Date.current) }
    status { [ 'Vigente', 'Pagada', 'Vencida' ].sample }
    active { [ true, false ].sample }

    trait :vigente do
      status { 'Vigente' }
      active { true }
    end

    trait :pagada do
      status { 'Pagada' }
      active { true }
    end

    trait :vencida do
      status { 'Vencida' }
      active { false }
    end

    trait :high_value do
      total { rand(25.0..100.0).round(2) }
    end

    trait :low_value do
      total { rand(5.0..15.0).round(2) }
    end

    trait :recent do
      invoice_date { rand(1.month.ago.to_date..Date.current) }
    end

    trait :old do
      invoice_date { rand(1.year.ago.to_date..6.months.ago.to_date) }
    end
  end
end
