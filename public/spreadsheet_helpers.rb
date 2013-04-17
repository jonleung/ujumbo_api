(2..28).each do |i|
  puts %{=INDIRECT("Users!F$#{i}")}
end