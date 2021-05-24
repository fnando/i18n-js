# frozen_string_literal: true

class GettextBackend < I18n::Backend::Simple
  include I18n::Backend::Gettext
end
