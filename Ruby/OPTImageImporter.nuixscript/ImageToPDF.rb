# Based on Java example code found here:
# http://www.rgagnon.com/javadetails/java-image-to-pdf-using-itext.html

java_import "java.io.FileOutputStream"
java_import "com.itextpdf.text.Document"
java_import "com.itextpdf.text.Rectangle"
java_import "com.itextpdf.text.pdf.PdfWriter"
java_import "com.itextpdf.text.pdf.RandomAccessFileOrArray"
java_import "com.itextpdf.text.Image"

class ImageToPDF
	def self.make_pdf(input_image_files,output_pdf_file,&block)
		input_image_files = Array(input_image_files)
		document = nil
		writer = nil
		input_image_files.each_with_index do |image_file,image_file_index|
			image = Image.getInstance(image_file)
			image_width = image.getWidth
			image_height = image.getHeight
			page_size = Rectangle.new(image_width,image_height)
			if block_given?
				yield(image_file,image_file_index,image_width,image_height)
			end
			if document.nil?
				document = Document.new(page_size,0,0,0,0)
				writer = PdfWriter.getInstance(document, FileOutputStream.new(java.io.File.new(output_pdf_file)))
				writer.setStrictImageSequence(true)
				writer.setCompressionLevel(9)
				document.open
			end
			document.add(image)
			document.newPage
		end
		document.close
	end
end