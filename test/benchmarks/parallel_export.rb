require "bundler/setup"

require "faker"
require "i18n"
require "yaml"
require "i18n-js"
require "benchmark"

(1..100).each do |i|
  File.open("test/fixtures/bench/bench_#{i}.yml", "w") do |f|
    strings = {}
    5_000.times do
      strings[Faker::Lorem.words(number: 4).join("_")] = Faker::Lorem.sentence
    end
    f.write({"x#{i}": strings}.to_yaml)
  end
end

I18n.load_path = Dir["test/fixtures/bench/*.yml"]
I18n.backend.load_translations

Benchmark.bm(7) do |bench|
  bench.report("baseline") do
    I18nJS.call(config_file: "./test/config/locale_placeholder.yml")
  end
  bench.report("parallel") do
    I18nJS.call(config_file: "./test/config/locale_placeholder.yml",
                parallel: true)
  end
end
