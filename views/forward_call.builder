xml.instruct!
xml.Response do
  xml.Dial my_phone_number, timeout: 10, record: false
end