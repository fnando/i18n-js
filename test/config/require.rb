# frozen_string_literal: true

I18n.available_locales = %i[en es pt]
I18n.default_locale = :en
I18n.load_path << Dir["./test/fixtures/yml/*.yml"]
