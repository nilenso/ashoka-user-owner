module I18n
  def self.name_for_locale(locale)
    I18n.backend.translate(locale, "language.name")
  rescue I18n::MissingTranslationData
    locale.to_s
  end
end