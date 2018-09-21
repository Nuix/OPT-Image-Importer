# This class provides a way to iterate entries in an OPT file, either by each record
# or by each document (collection of records).
class OpticonLoadfileParser
	def self.each_record(file_path,&block)
		File.open(file_path,"r:utf-8") do |file|
			line_number = 0
			file.each_line do |line|
				line_number += 1
				yield(OpticonLoadfileRecord.from_line(line,line_number))
			end
		end
	end

	def self.each_document(file_path,&block)
		current_document = nil
		each_record(file_path) do |record|
			if record.is_document
				if !current_document.nil?
					yield(current_document)
				end
				current_document = [record]
			else
				current_document << record
			end
		end
		if !current_document.nil? && current_document.size > 0
			yield(current_document)
		end
	end
end

# This class represents the information parsed from a single entry in an OPT file.
class OpticonLoadfileRecord
	attr_accessor :id
	attr_accessor :volume
	attr_accessor :path
	attr_accessor :is_document
	attr_accessor :pages
	attr_accessor :line_number

	def self.from_line(line,line_number)
		record = new
		parts = line.split(",")
		record.id = parts[0]
		record.volume = parts[1]
		record.path = parts[2].gsub(/^[\\\/]/,"")
		record.is_document = parts[3].strip.downcase == "y"
		record.pages = parts[6]
		record.line_number = line_number
		return record
	end

	def to_s
		result = []
		result << "Line Number: #{@line_number}"
		result << "ID: #{@id}"
		result << "Volume: #{@volume}"
		result << "Path: #{@path}"
		result << "Pages: #{@pages}"
		return result.join("\n")
	end
end