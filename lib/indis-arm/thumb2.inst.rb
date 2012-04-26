matcher bits:11, to:15 do
  if match == 0b11101 || match == 0b11110 || match == 0b11111
    base_class = :thumb_32_instruction
  else
    base_class = :thumb_16_instruction
  end
end

i_class :thumb_16_instruction do
  matcher bits:10 to:15 do
    if match 
  end
end