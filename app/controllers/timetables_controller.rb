require 'csv'
require 'date'

class TimetablesController < ApplicationController
	def index
		require 'trello'

		boardName = 'Cards'
		username = 'sparksofl'

		Trello.configure do |config|
		  config.developer_public_key = 'dbaf008eabec02f406a5fdd67684780b'
		  config.member_token = '6aed650820637b0af18adf6ffb9bc9e63f611ffd0e0a5ad0a1d3941deb728ca2'
		end

		#createList = lambda { |b| Trello::List.create(name: "Cist Timetable", board_id: b.id) if b.name == 'Studies' }
		@user = Trello::Member.find(username)
		@board = @user.boards.each do |b| 
			@ctList = Trello::List.create(name: "Cist Timetable", board_id: b.id) if b.name == boardName
		end
		
		CSV.foreach("/home/mary/Downloads/TimeTable_15_11_2015 (1).csv", :headers => true, :encoding => "windows-1251:utf-8") do |row|
			name = row[0].split(/[0-9]{1}/)[0]
			due = DateTime.strptime(row[1] + ' ' + row[2] + ' +2', '%d.%m.%Y %H:%M:%S %z')
			card = Trello::Card.create(name: name, list_id: @ctList.id)
			card.due = due
			card.update!
		end
	end
end