module LanguageHelper
  LANGUAGES = {
    en: "English",
    es: "Español",
    "es-co": "Spanish (Columbia)",
    fr: "French",
    nl: "Dutch"
  }

  def language_options
    LANGUAGES.slice(*I18n.available_locales).invert.to_a
  end
end
