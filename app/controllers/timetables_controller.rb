require 'trello'
require 'csv'
require 'date'

class TimetablesController < ApplicationController
	def index
		boardName = 'Studies'
		username = 'sparksofl'
		listName = 'Cist Timetable'
		board_id = 0;

		Trello.configure do |config|
		  config.developer_public_key = 'dbaf008eabec02f406a5fdd67684780b'
		  config.member_token = '6aed650820637b0af18adf6ffb9bc9e63f611ffd0e0a5ad0a1d3941deb728ca2'
		end


		@client = Trello::Client.new(
		  :consumer_key => 'dbaf008eabec02f406a5fdd67684780b',
		  :consumer_secret => '96e13c6bc9047aff7380b8c4f86c1696abcca8aac693f7d6428fb099bd07d81b',
		  :oauth_token => '6aed650820637b0af18adf6ffb9bc9e63f611ffd0e0a5ad0a1d3941deb728ca2',
		  :oauth_token_secret => '1a8250b7fa5163ae4312ff437bbe507a'
		)

		#createList = lambda { |b| Trello::List.create(name: "Cist Timetable", board_id: b.id) if b.name == 'Studies' }
		@user = Trello::Member.find(username)
		



		# @label_response = @client.post("/labels", { 'name' => "testing", 'idBoard' => board_id, 'color' => "green" })

		# card = Trello::Card.create(name: "sdfds", list_id: @ctList.id, card_labels: :testing)
		# card.card_labels = [:red, '5649cf3b0d393a511ec9077a']
		# card.update!
		# label = @client.create("/labels", {name: 'lk', idBoard: board_id, color: :green})

		list_names = Array.new 

		CSV.foreach("/home/mary/Downloads/TimeTable_16_11_2015 (11).csv", :headers => true, :encoding => "windows-1251:utf-8") do |row|
			name = row[0].split(/[0-9]{1}/)[0]
			name.gsub!(/_|\*/, '') if (name.include? '_') || (name.include? '*')


			type = name.split(//).last(3).join.gsub( /.{1}$/, '' )
			if type == 'Лк'
				c_labels = [ :yellow ]
			elsif type == 'Лб'
				c_labels = [ :purple ]
			elsif type == 'Пз'
				c_labels = [ :green ]
			end
			due = DateTime.strptime(row[1] + ' ' + row[2] + ' +2', '%d.%m.%Y %H:%M:%S %z')
			#debug


			listName = name.gsub( /.{4}$/, '' )


			@user.boards.each do |b| 	
				if b.name == boardName && type != 'Лк'
					if listName == ''
						next
					end
					if !(list_names.include? listName)
						@ctList = Trello::List.create(name: listName, board_id: b.id)
						if !(list_names.include? listName)
							list_names.push(listName)
						end


						card = Trello::Card.create(name: name, list_id: @ctList.id, card_labels: c_labels )
						card.due = due
						card.update!
					else
						b.lists.find do |list| 
							if list.name == listName
								card = Trello::Card.create(name: name, list_id: list.id, card_labels: c_labels ) 
								due = DateTime.strptime(row[1] + ' ' + row[2] + ' +2', '%d.%m.%Y %H:%M:%S %z')
								card.due = due
								card.update!
							end
						end
					end
				end
				#debug
			end
		end
	end
end