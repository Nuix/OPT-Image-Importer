# Menu Title: Image to PDF Importer
# Needs Case: true
# Needs Selected Items: false

script_directory = File.dirname(__FILE__)
require File.join(script_directory,"Nx.jar").gsub("/","\\")
java_import "com.nuix.nx.NuixConnection"
java_import "com.nuix.nx.LookAndFeelHelper"
java_import "com.nuix.nx.dialogs.ChoiceDialog"
java_import "com.nuix.nx.dialogs.TabbedCustomDialog"
java_import "com.nuix.nx.dialogs.CommonDialogs"
java_import "com.nuix.nx.dialogs.ProgressDialog"
java_import "com.nuix.nx.digest.DigestHelper"

LookAndFeelHelper.setWindowsIfMetal
NuixConnection.setUtilities($utilities)
NuixConnection.setCurrentNuixVersion(NUIX_VERSION)

require File.join(script_directory,"OpticonLoadfileParser.rb").gsub("/","\\")
require File.join(script_directory,"ImageToPDF.rb").gsub("/","\\")

dialog = TabbedCustomDialog.new("Image to PDF Importer")

main_tab = dialog.addTab("main_tab","Main")

main_tab.appendOpenFileChooser("opticon_file","Opticon File","Opticon Load File (*.OPT)","opt")
main_tab.appendDirectoryChooser("temp_directory","Temp Directory")
main_tab.setText("temp_directory","C:\\Temp")
main_tab.appendCheckBox("delete_temp_pdfs","Delete Temporary PDFs",true)

main_tab.appendRadioButton("match_docid","Match Production Set DOCID","match_grp",true)
main_tab.appendRadioButton("match_item_property","Match Metadata Property","match_grp",false)
main_tab.appendComboBox("item_id_property","Item ID Property",["BEGINBATES","DOCID"])
main_tab.enabledOnlyWhenChecked("item_id_property","match_item_property")

# Define table control allowing use to define volumes which may be present in an OPT and their associated
# image root paths which will be used to take OPT entry relative paths belonging to a given volume and build
# the absolute path used to locate any given image on disk.
volumes_tab = dialog.addTab("volumes_tab","Volume Paths")
volumes_tab.appendHeader("Note: You can have an entry with a blank value for volume, which will match OPT records without a volume.")
volumes_tab.appendDynamicTable("volume_paths","Volume Paths",["Volume","Path"],[]) do |record,col,is_write,value|
	if is_write
		case col
		when 0
			record["volume"] = value
		when 1
			record["path"] = value
		end
	else
		case col
		when 0
			next record["volume"]
		when 1
			next record["path"]
		end
	end
end
table = volumes_tab.getControl("volume_paths")
table.getModel.setDefaultCheckState(true)
table.getModel.setColumnEditable(0)
table.getModel.setColumnEditable(1)
table.setUserCanAddRecords(true) do
	next {
		"volume" => "VOLUME",
		"path" => "C:\\",
	}
end

# Customize how volume paths list is serialized
volumes_tab.whenSerializing("volume_paths") do |control|
	next control.getRecords
end

# Customize how volume paths list is deserialized
volumes_tab.whenDeserializing("volume_paths") do |data,control|
	control.setRecords(data)
end

# Defines some settings validations
dialog.validateBeforeClosing do |values|
	if !java.io.File.new(values["opticon_file"]).exists
		CommonDialogs.showError("Please provide a valid Opticon loadfile path.")
		next false
	end

	if values["volume_paths"].size < 1
		CommonDialogs.showError("Please provide at least one volume path.")
		next false
	end

	if values["temp_directory"].strip.empty?
		CommonDialogs.showError("Please provide a temp directory.")
		next false
	end

	next true
end

dialog.display
if dialog.getDialogResult == true
	values = dialog.toMap
	opticon_file = values["opticon_file"]
	volume_paths = values["volume_paths"]
	path_by_volume = {}
	temp_directory = values["temp_directory"]
	delete_temp_pdfs = values["delete_temp_pdfs"]

	match_docid = values["match_docid"]
	match_item_property = values["match_item_property"]
	item_id_property = values["item_id_property"]

	ProgressDialog.forBlock do |pd|
		pd.setTitle("Image to PDF Importer")
		pd.setAbortButtonVisible(true)

		pd.logMessage("Opticon File: #{opticon_file}")
		volume_paths.each do |vol_path|
			path_by_volume[vol_path["volume"].downcase] = vol_path["path"]
			pd.logMessage("#{vol_path["volume"]}: #{vol_path["path"]}")
		end

		pd.logMessage("Temp Directory: #{temp_directory}")
		if !java.io.File.new(temp_directory).exists
			pd.logMessage("Creating temp directory...")
			java.io.File.new(temp_directory).mkdirs
		end

		# Used to import the PDFs we generate into Nuix associated to an item
		pdf_importer = $utilities.getPdfPrintImporter

		not_imported_count = 0

		# Iterate each document, which may be 1 or more entries in the actual loadfile
		OpticonLoadfileParser.each_document(opticon_file) do |document|
			break if pd.abortWasRequested
			first_id = document.first.id
			pd.logMessage("Processing #{first_id}, #{document.size} pages...")

			all_records_resolved = true
			image_files = document.map do |record|
				image_directory = path_by_volume[record.volume.downcase]
				if image_directory.nil?
					image_directory = path_by_volume["*"]
				end
				if image_directory.nil?
					pd.logMessage("!!! Unable to resolve relative path for volume: #{record.volume}")
					pd.logMessage("!!! Skipping document: #{first_id}")
					all_records_resolved = false
				else
					next File.join(image_directory,record.path).gsub("/","\\")
				end
			end
			next if !all_records_resolved

			temp_pdf_file = File.join(temp_directory,"#{first_id}.pdf")
			pd.setMainStatusAndLogIt("Generating PDF for #{first_id}...")
			pd.logMessage("\tPDF: #{temp_pdf_file}")
			ImageToPDF.make_pdf(image_files,temp_pdf_file) do |image_file,image_file_index,image_width,image_height|
				pd.setSubStatus("#{File.basename(image_file)}: #{image_file_index+1} #{image_width}x#{image_height}")
			end
			pd.setMainStatus("Importing PDF")

			#Find the items
			import_count = 0
			if match_item_property
				items = $current_case.search("properties:\"#{item_id_property}: #{first_id}\"")
				items.each do |item|
					if item.getProperties[item_id_property] == first_id
						pdf_importer.importItem(item,temp_pdf_file)
						import_count += 1
					end
				end

				if import_count < 1
					pd.logMessage("Unable to find any matches in '#{item_id_property}' for '#{first_id}', PDF not imported!")
					not_imported_count += 1
				end
			elsif match_docid
				items = $current_case.search("document-id:\"#{first_id}\"")
				items.each do |item|
					pdf_importer.importItem(item,temp_pdf_file)
					import_count += 1
				end

				if import_count < 1
					pd.logMessage("Unable to find any matches for DOCID '#{first_id}', PDF not imported!")
					not_imported_count += 1
				end
			end

			if delete_temp_pdfs
				pd.setMainStatus("Deleting Temporary PDF...")
				File.delete(temp_pdf_file)
			end
		end

		if not_imported_count > 0
			pd.logMessage("#{not_imported_count} document IDs could not be located in case, please review log messages.")
		end

		if pd.abortWasRequested
			pd.setMainStatusAndLogIt("User Aborterd")
		else
			if not_imported_count > 0
				pd.setMainStatusAndLogIt("Completed: Some PDFs not Imported!")
			else
				pd.setCompleted
			end
		end
	end
end