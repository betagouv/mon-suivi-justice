# Allow `target`/`rel` so links forced to open in a new tab (see UserAlert#set_target_blank)
# survive ActionText's sanitizer instead of being silently stripped on render.
ActionText::ContentHelper.allowed_attributes =
  ActionText::ContentHelper.sanitizer.class.allowed_attributes + ActionText::Attachment::ATTRIBUTES + %w[target rel]
