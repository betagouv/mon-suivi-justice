# rails r bin/populate_history_items.rb

require 'ruby-progressbar'

progress = ProgressBar.create(total: HistoryItem.count)

HistoryItem.all.each do |hi|
  content = HistoryItemFactory.build_content(hi.category, hi.appointment, hi.event)
  hi.update!(content: content)
  progress.increment
end

p ""
p "HistoryItems content populated"
