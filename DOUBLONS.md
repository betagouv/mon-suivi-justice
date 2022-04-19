## Trouver les doublons

```
a = Convict.all
result = a.select{ |e| a.pluck(:phone).count(e.phone) > 1 && !e.phone.nil? && e.phone != "" }
array = result.pluck(:phone).uniq
```

## Gérer doublons en masse (avec mêmes noms)

```
array.each do |phone|
  next if ["+33659763117", "+33683481555", "+33682356466", "+33603371085", "+33687934479", "+33674426177", "+33616430756"].include?(phone)

  c = Convict.where(phone: phone)
  con1 = c.first
  con2 = c.last

  next unless I18n.transliterate(con1.first_name.strip.downcase) == I18n.transliterate(con2.first_name.strip.downcase) && I18n.transliterate(con1.last_name.strip.downcase) == I18n.transliterate(con2.last_name.strip.downcase)

  areas1 = con1.areas_convicts_mappings.pluck(:area_id)
  areas2 = con1.areas_convicts_mappings.pluck(:area_id)
  next unless areas1.size==areas2.size and areas1&areas2==areas1

  apts = Appointment.where(convict_id: con2.id)
  history_items = HistoryItem.where(convict_id: con2.id)

  apts.each do |a|
    a.update(convict_id: con1.id)
  end

  history_items.each do |h|
    h.update(convict_id: con1.id)
  end

  con2.destroy
end
```

## Sur staging

```
array.each do |phone|
  next if ["+33659763117", "+33683481555", "+33682356466", "+33603371085", "+33687934479", "+33674426177", "+33616430756"].include?(phone)

  c = Convict.where(phone: phone)
  c.last.destroy
end
```

## Formatter doublons

```
array.each do |a|
  c = Convict.where(phone: a)
  puts "#{c.first.id} : #{c.first.first_name} #{c.first.last_name} dans les départements #{c.first.departments.pluck(:name).join(',')}, #{c.last.id} : #{c.last.first_name} #{c.last.last_name} dans les départements #{c.last.departments.pluck(:name).join(',')} avec phone #{c.first.phone}"
end
```
