module DataHelper
	def read_file
		path = []
		File.open("public/new_abboip.txt", "r").each_line do |line|
			path.push = line.split
		end
	end
end