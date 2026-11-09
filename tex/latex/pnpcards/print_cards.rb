#!/usr/bin/env ruby
# Print PDF pages as A6-Cards with Duplex
# Needs Gem hexapdf
#
# Usage: ruby print_cards.rb input.pdf [output.pdf]
#
# Expects input PDF with cards in logical order (front1, back1, front2, back2, ...)
# Reorders 8 pages at a time for duplex printing on A4 (4 A6 cards per sheet).
#
# Input order (logical):  K1V K1R K2V K2R K3V K3R K4V K4R
# Output order (print):   K1V K2V K3V K4V K2R K1R K4R K3R
# Print setting: Duplex, "Flip on short edge"
#
# NOTE: Requires all cards to be exactly 2 pages. 4-page cards are not yet supported.

require 'hexapdf'

pdf_path = ARGV[0]
output_path = ARGV[1] || "#{pdf_path.chomp('.pdf')}_a6cards.pdf"

doc = HexaPDF::Document.open(pdf_path)
new_doc = HexaPDF::Document.new

# Make number of pages a multiple of 8 by adding blank pages if necessary
# while (doc.pages.count % 8) != 0
#  doc.pages.add doc.pages[0].
# end

(0...doc.pages.count).step(8) do |i|
  new_doc.pages << new_doc.import(doc.pages[i + 0]) # Card 1 Front
  new_doc.pages << new_doc.import(doc.pages[i + 2]) # Card 2 Front
  new_doc.pages << new_doc.import(doc.pages[i + 4]) # Card 3 Front
  new_doc.pages << new_doc.import(doc.pages[i + 6]) # Card 4 Front
  new_doc.pages << new_doc.import(doc.pages[i + 3]) # Card 2 Back
  new_doc.pages << new_doc.import(doc.pages[i + 1]) # Card 1 Back
  new_doc.pages << new_doc.import(doc.pages[i + 7]) # Card 4 Back
  new_doc.pages << new_doc.import(doc.pages[i + 5]) # Card 3 Back
end

new_doc.write(output_path)
puts "Written to #{output_path}. Print duplex with 'Flip on short edge'"
