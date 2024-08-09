#frozen
#
require 'csv'
require 'google/apis/civicinfo_v2'

civic_info = Google::Apis::CivicinfoV2::CivicInfoService.new
civic_info.key = 'AIzaSyClRzDqDh5MsXwnCWi0kOiiBivP6JsSyBw'

def analyze(zip)
  zip.to_s.rjust(5, '0')[0..4]
end

def legislators_by_zip(zip)
  begin
    legislators = civic_info.representative_info_by_address(
      address: zip,
      levels: 'country',
      roles: %w[legislatorUpperBody legislatorLowerBody]
    )
    legislators = legislators.officials.map(&:name)
    return legislators
  rescue
    return 'you have bad luck'
  end
end

puts 'Event Manager Initialized.'

form = File.read('./lib/form_letter.html')

contents = CSV.open(
  './event_attendees.csv',
  headers: true,
  header_converters: :symbol
)

contents.each do |rows|
  name = rows[:first_name]

  zipcode = analyze(rows[:zipcode])

  legislators = legislators_by_zip(zipcode)

  letter = form.gsub('FIRST_NAME', name)
  letter.gsub!('LEGISLATORS', legislators)
  puts letter
end
