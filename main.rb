#frozen
#
require 'csv'
require 'google/apis/civicinfo_v2'

civic_info = Google::Apis::CivicinfoV2::CivicInfoService.new
civic_info.key = 'AIzaSyClRzDqDh5MsXwnCWi0kOiiBivP6JsSyBw'

def analyze(zip)
  zip.to_s.rjust(5, '0')[0..4]
end

puts 'Event Manager Initialized.'

contents = CSV.open(
  './event_attendees.csv',
  headers: true,
  header_converters: :symbol
)

contents.each do |rows|
  name = rows[:first_name]

  zipcode = analyze(rows[:zipcode])

  begin
    legislators = civic_info.representative_info_by_address(
      address: zipcode,
      levels: 'country',
      roles: %w[legislatorUpperBody legislatorLowerBody]
    )
    legislators = legislators.officials.map(&:name)
  rescue
    'you have bad luck'
  end
  puts "#{name}, #{zipcode}, #{legislators}"
end
