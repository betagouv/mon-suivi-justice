Date::DATE_FORMATS[:base_date_format] = "%d/%m/%Y"
Date::DATE_FORMATS[:default] = ->(date) { I18n.localize date, format: :default }
Time::DATE_FORMATS[:lettered] = "%Hh%M"
