# frozen_string_literal: true

require 'open3'
require 'tmpdir'

EXPECTED_PAGE_BORDER = 5.0 # Millimeters
EXPECTED_AREA_MARGIN = 2.0 # Millimeters

EXPECTED_PAGE_BOUNDARY = LatexTesting::Boundary.new(left: 0.0, top: 0.0, bottom: 105.0, right: 148.0).freeze
EXPECTED_TITLE_BOUNDARY = LatexTesting::Boundary.new(
  left: EXPECTED_PAGE_BORDER,
  top: EXPECTED_PAGE_BORDER,
  height: 15.0,
  right: EXPECTED_PAGE_BOUNDARY.right - EXPECTED_PAGE_BORDER
).freeze
EXPECTED_FRONT_CONTENT_BOUNDARY = LatexTesting::Boundary.new(
  left: EXPECTED_PAGE_BORDER,
  top: EXPECTED_TITLE_BOUNDARY.bottom + EXPECTED_AREA_MARGIN,
  right: EXPECTED_PAGE_BOUNDARY.right - EXPECTED_PAGE_BORDER,
  bottom: EXPECTED_PAGE_BOUNDARY.bottom - EXPECTED_PAGE_BORDER
).freeze
EXPECTED_BACK_CONTENT_BOUNDARY = LatexTesting::Boundary.new(
  left: EXPECTED_PAGE_BORDER,
  top: EXPECTED_PAGE_BORDER,
  right: EXPECTED_PAGE_BOUNDARY.right - EXPECTED_PAGE_BORDER,
  bottom: EXPECTED_PAGE_BOUNDARY.bottom - EXPECTED_PAGE_BORDER
).freeze

LAYOUT_BOUNDARY_TOLERANCE = 0.01 # Millimeters
LAYOUT_BOUNDARY_WITH_TOLERANCE = lambda do |boundary|
  LatexTesting::Boundary.new(
    left: boundary.left - LAYOUT_BOUNDARY_TOLERANCE,
    top: boundary.top - LAYOUT_BOUNDARY_TOLERANCE,
    right: boundary.right + LAYOUT_BOUNDARY_TOLERANCE,
    bottom: boundary.bottom + LAYOUT_BOUNDARY_TOLERANCE
  ).freeze
end
EXPECTED_TITLE_BOUNDARY_WITH_TOLERANCE = LAYOUT_BOUNDARY_WITH_TOLERANCE.call(EXPECTED_TITLE_BOUNDARY)
EXPECTED_FRONT_CONTENT_BOUNDARY_WITH_TOLERANCE = LAYOUT_BOUNDARY_WITH_TOLERANCE.call(EXPECTED_FRONT_CONTENT_BOUNDARY)
EXPECTED_BACK_CONTENT_BOUNDARY_WITH_TOLERANCE = LAYOUT_BOUNDARY_WITH_TOLERANCE.call(EXPECTED_BACK_CONTENT_BOUNDARY)

HEADER_COLOR = [0.75, 0, 0].freeze
CONTENT_COLOR = [0, 0, 0.75].freeze
CONTINUATION_COLOR = [0, 0.5, 0].freeze
REFERENCE_COLOR = [0, 0.75, 0, 0.25].freeze

RASTERIZED_PAGE_HAS_NONWHITE_PIXELS = lambda do |pdf_path, page_number, forbidden_title_width: nil|
  Dir.mktmpdir('pnpcards-raster-') do |directory|
    image_path = File.join(directory, 'page.ppm')
    _stdout, stderr, status = Open3.capture3(
      'gs', '-q', '-dSAFER', '-dBATCH', '-dNOPAUSE', '-sDEVICE=ppmraw', '-r300',
      "-dFirstPage=#{page_number}", "-dLastPage=#{page_number}", "-sOutputFile=#{image_path}", pdf_path
    )
    raise "Ghostscript failed to rasterize PDF page #{page_number}: #{stderr}" unless status.success?
    raise "Ghostscript did not produce a raster for PDF page #{page_number}" unless File.file?(image_path)

    image = File.binread(image_path)
    header_position = 0
    header_tokens = []
    header_delimiters = [9, 10, 11, 12, 13, 32, 35]
    while header_tokens.length < 4
      loop do
        raise "Ghostscript produced an invalid PPM raster for PDF page #{page_number}" if header_position >= image.bytesize

        byte = image.getbyte(header_position)
        if [9, 10, 11, 12, 13, 32].include?(byte)
          header_position += 1
        elsif byte == 35
          header_position += 1 while header_position < image.bytesize && ![10, 13].include?(image.getbyte(header_position))
          raise "Ghostscript produced an invalid PPM raster for PDF page #{page_number}" if header_position >= image.bytesize
        else
          break
        end
      end

      token_start = header_position
      header_position += 1 while header_position < image.bytesize && !header_delimiters.include?(image.getbyte(header_position))
      raise "Ghostscript produced an invalid PPM raster for PDF page #{page_number}" if token_start == header_position

      header_tokens << image.byteslice(token_start, header_position - token_start)
    end
    unless header_tokens[0] == 'P6' && header_tokens[1].match?(/\A\d+\z/) &&
           header_tokens[2].match?(/\A\d+\z/) && header_tokens[3] == '255'
      raise "Ghostscript produced an invalid PPM raster for PDF page #{page_number}"
    end

    delimiter = image.getbyte(header_position)
    raise "Ghostscript produced an invalid PPM raster for PDF page #{page_number}" unless [9, 10, 11, 12, 13, 32].include?(delimiter)

    header_position += delimiter == 13 && image.getbyte(header_position + 1) == 10 ? 2 : 1
    expected_pixel_bytes = header_tokens[1].to_i * header_tokens[2].to_i * 3
    pixels = image.byteslice(header_position, expected_pixel_bytes)
    unless pixels&.bytesize == expected_pixel_bytes
      raise "Ghostscript produced an incomplete PPM raster for PDF page #{page_number}"
    end

    if forbidden_title_width
      width = header_tokens[1].to_i
      points_per_mm = 300.0 / 25.4
      (0...(21.8 * points_per_mm).floor).any? do |y|
        (0...width).any? do |x|
          x_mm = (x + 0.5) / points_per_mm
          y_mm = (y + 0.5) / points_per_mm
          forbidden = y_mm < 4.8 || x_mm < 4.8 ||
                      (y_mm > 20.2 && x_mm < 5.0 + forbidden_title_width) ||
                      (forbidden_title_width == 121.0 && x_mm > 126.2 && x_mm < 127.8)
          offset = 3 * (y * width + x)
          forbidden && pixels.getbyte(offset) < 70 && pixels.getbyte(offset + 1) < 70 && pixels.getbyte(offset + 2) < 70
        end
      end
    else
      pixels.each_byte.any? { |channel| channel < 255 }
    end
  end
end

EXPECTED_TITLE_WITH_REFERENCE_BOUNDARY = LatexTesting::Boundary.new(
  left: EXPECTED_PAGE_BORDER,
  top: EXPECTED_PAGE_BORDER,
  width: 121.0,
  height: 15.0
).freeze
PDF_TEST_TEXT_LINE = Struct.new(:text, :boundary)
PDF_TEXT_IN_DRAW_ORDER = lambda do |page|
  processor = HexaPDF::Content::SmartTextExtractor::TextRunProcessor.new
  page.process_contents(processor)
  processor.text_runs.map(&:string).join.gsub(/\s+/, '')
end
PDF_BODY_LINES = lambda do |page, first_marker|
  page.text_lines
  processor = HexaPDF::Content::SmartTextExtractor::TextRunProcessor.new
  page.process_contents(processor)
  runs = processor.text_runs.reject { |run| run.string.empty? }
  start = runs.each_index.find do |index|
    runs[index..].map(&:string).join.gsub(/\s+/, '').start_with?(first_marker)
  end
  raise "Missing body marker #{first_marker}" unless start

  LatexTesting::Assertion::Execution::PDFExecution::TextLineExtractor.new(page).send(:build_lines, runs[start..])
end
TITLE_TEXT_BOUNDARY_TOLERANCE = LAYOUT_BOUNDARY_TOLERANCE # Millimeters
TITLE_TEXT_BOUNDARY_WITH_TOLERANCE = lambda do |boundary|
  LatexTesting::Boundary.new(
    left: boundary.left - TITLE_TEXT_BOUNDARY_TOLERANCE,
    top: boundary.top - TITLE_TEXT_BOUNDARY_TOLERANCE,
    right: boundary.right + TITLE_TEXT_BOUNDARY_TOLERANCE,
    bottom: boundary.bottom + TITLE_TEXT_BOUNDARY_TOLERANCE
  ).freeze
end
PDF_TEXT_LINE_IN_AREA = lambda do |page, expected_text, left_mm:, right_mm:, top_mm:, bottom_mm:|
  processor = HexaPDF::Content::SmartTextExtractor::TextRunProcessor.new
  page.process_contents(processor)
  media_box = page.box(:media)
  points_per_mm = 72.0 / 25.4
  left = left_mm * points_per_mm - 0.01
  right = right_mm * points_per_mm + 0.01
  top = media_box.top - top_mm * points_per_mm
  bottom = media_box.top - bottom_mm * points_per_mm
  candidates = processor.text_runs.select do |run|
    run.left >= left && run.left < right && run.baseline <= top && run.baseline >= bottom
  end
  runs = nil
  candidates.each_index do |index|
    line = []
    text = ''
    candidates[index..].each do |run|
      break unless line.empty? || (run.baseline - line.first.baseline).abs < 0.01

      line << run
      text += run.string
      break unless expected_text.start_with?(text)
      if text == expected_text
        runs = line
        break
      end
    end
    break if runs
  end
  return nil unless runs

  PDF_TEST_TEXT_LINE.new(
    text: expected_text,
    boundary: LatexTesting::Boundary.new(
      left: runs.map(&:left).min - media_box.left,
      top: media_box.top - runs.map(&:top).max,
      right: runs.map(&:right).max - media_box.left,
      bottom: media_box.top - runs.map(&:bottom).min
    )
  )
end
EXPECTED_REFERENCE_BOUNDARY = LatexTesting::Boundary.new(
  left: EXPECTED_PAGE_BORDER + EXPECTED_TITLE_WITH_REFERENCE_BOUNDARY.width + EXPECTED_AREA_MARGIN,
  top: EXPECTED_PAGE_BORDER,
  width: 15.0,
  height: 15.0
).freeze

fixture 'Page Splitting' do
  file '01-page-splitting.tex'

  test 'The PDF has 6 pages' do
    expect(generated_pdf.pages.count).to eq(6)
  end

  test('No debug frames appear on any page.') do
    expect(generated_pdf.pages).to all(have_attributes(frames: have_attributes(count: 0)))
  end

  test 'Page 1 contains the short-content title and its content.' do
    expect(PDF_TEXT_IN_DRAW_ORDER.call(generated_pdf.pages[0])).to eq('ShortcontentSHORTCONTENTFITSONFRONT')
  end

  test 'Page 2 is a blank back page.' do
    expect(generated_pdf.pages[1].text_lines).to be_empty
  end

  test "Page 3 has the front title 'Natural overflow'." do
    expect(generated_pdf.pages[2].text_lines[0].text).to include('Natural overflow')
  end

  test 'Pages 3 and 4 contain the complete Lorem Ipsum text in order.' do
    lines = generated_pdf.pages[2].text_lines.drop(1).map(&:text) + generated_pdf.pages[3].text_lines.map(&:text)
    actual_text = lines.each_with_index.each_with_object(+'') do |(line, index), text|
      if index.positive?
        if lines[index - 1].rstrip.end_with?('-')
          text.rstrip!
          text.chop!
        else
          text << ' '
        end
      end
      text << line
    end

    expected_text = <<~LOREM
      Lorem ipsum dolor sit amet, consectetur adipiscing elit. Vestibulum vel ornare nibh, a lacinia lacus. Phasellus hendrerit posuere dui, elementum ultricies augue pellentesque a. Nullam fermentum sollicitudin ipsum non dignissim. Fusce rhoncus turpis id condimentum mollis. Nullam ac libero et lacus eleifend fringilla. Maecenas ut condimentum leo. Praesent hendrerit augue commodo odio auctor, et congue nunc porta. Sed id bibendum lectus. Orci varius natoque penatibus et magnis dis parturient montes, nascetur ridiculus mus. Praesent aliquam diam id justo sollicitudin iaculis.

      Donec suscipit tempor pellentesque. Proin ipsum turpis, volutpat non eros sit amet, sollicitudin suscipit lectus. Praesent a lacus mollis justo dictum pellentesque. Etiam sodales lectus sit amet luctus dictum. Duis nec massa nibh. Quisque pharetra sem quis porttitor lobortis. Curabitur dictum, purus vel commodo imperdiet, sem magna iaculis est, id eleifend nisi risus pretium velit. Suspendisse id quam tempor, gravida diam at, placerat nibh. Suspendisse ante odio, malesuada vitae ultricies non, facilisis in elit. In hac habitasse platea dictumst. Pellentesque egestas orci eros. Suspendisse aliquet diam non sapien venenatis, non sollicitudin dui placerat. Integer molestie odio eu pellentesque sodales. Suspendisse eleifend tortor eget nibh sodales, nec iaculis massa posuere. Phasellus a purus nec diam aliquam placerat vel vitae mauris.

      Integer pharetra, odio at vestibulum pulvinar, lorem orci pharetra justo, a pretium neque lorem vitae neque. Proin aliquet velit lacinia, pharetra massa non, rhoncus dolor. Quisque lacinia volutpat tincidunt. Fusce in libero placerat, aliquam dui vel, tempor mi. Fusce tempus odio sed tincidunt lacinia. Pellentesque et tempor leo. Nullam scelerisque nibh non orci luctus scelerisque. Sed porttitor, ante quis eleifend elementum, dolor magna congue ligula, vitae posuere libero nisl sit amet enim. Mauris venenatis mauris quam, vitae aliquam leo ullamcorper fringilla. Nullam gravida non libero eleifend aliquet. Donec in urna at mauris ornare ornare id et turpis.

      Phasellus posuere turpis non ipsum egestas faucibus. Vivamus sit amet egestas erat, et pulvinar ipsum. Fusce aliquet pretium tempus. Praesent id nunc at odio interdum placerat dignissim quis tellus. Nunc posuere, nunc sed aliquet lacinia, tellus est maximus dolor, eget dignissim purus est a nulla. Nullam sodales eleifend sollicitudin. Aenean sollicitudin vel tellus eu luctus. Pellentesque auctor molestie nisi a scelerisque. Curabitur tellus lorem, euismod sed felis ut, ullamcorper pretium est.
    LOREM

    expect(actual_text.gsub(/\s+/, ' ').strip).to eq(expected_text.gsub(/\s+/, ' ').strip)
  end

  test 'Page 4 continues the Lorem Ipsum text on an untitled continuation page.' do
    lines = generated_pdf.pages[3].text_lines
    expect(lines).not_to be_empty
  end

  test 'Page 5 contains the title and only the content before the explicit page break.' do
    lines = generated_pdf.pages[4].text_lines.map(&:text)
    normalized_lines = lines.map { |line| line == 'Explicit page break' ? line : line.gsub(/\s+/, '') }
    expect(normalized_lines).to eq(['Explicit page break', 'CONTENTBEFORENEWPAGE'])
  end

  test 'Page 6 contains only the content after the explicit page break.' do
    lines = generated_pdf.pages[5].text_lines.map(&:text)
    normalized_lines = lines.map { |line| line.gsub(/\s+/, '') }
    expect(normalized_lines).to eq(['CONTENTAFTERNEWPAGE'])
  end
end

fixture 'A6 Geometry' do
  file '02-a6-geometry.tex'

  test('The PDF has eight pages.') { expect(generated_pdf.pages.count).to eq(8) }

  test 'All pages are A6 landscape format (148 mm x 105 mm).' do
    generated_pdf.pages.each do |page|
      expect(page.convert_unit(page.boundary.width, LatexTesting::TargetUnit::MILLIMETERS)).to be_within(LAYOUT_BOUNDARY_TOLERANCE).of(EXPECTED_PAGE_BOUNDARY.width)
      expect(page.convert_unit(page.boundary.height,
                               LatexTesting::TargetUnit::MILLIMETERS)).to be_within(LAYOUT_BOUNDARY_TOLERANCE).of(EXPECTED_PAGE_BOUNDARY.height)
    end
  end

  test 'The page 1 title is within the expected title boundary.' do
    page = generated_pdf.pages[4]
    title_lines = page.text_lines.select { |line| line.text == 'A6 geometry' }
    expect(title_lines.count).to eq(1)

    expect(RASTERIZED_PAGE_HAS_NONWHITE_PIXELS.call(pdf_path, 5, forbidden_title_width: 138.0)).to be(false)
  end

  test 'All front content lines are within the page 1 content boundary.' do
    page = generated_pdf.pages[4]
    front_content_lines = page.text_lines.select { |line| line.text.start_with?('FRONT CONTENT LINE') }
    expect(front_content_lines).not_to be_empty

    front_content_lines.each do |line|
      boundary = page.convert_unit(line.boundary, LatexTesting::TargetUnit::MILLIMETERS)
      matcher = be_within(EXPECTED_FRONT_CONTENT_BOUNDARY_WITH_TOLERANCE)
      expect(boundary).to matcher, -> { "#{line.text}: #{matcher.failure_message}" }
    end
  end

  test 'No continuation line is on page 1' do
    page = generated_pdf.pages[4]
    continuation_lines = page.text_lines.select { |line| line.text.start_with?('CONTINUATION LINE') }
    expect(continuation_lines).to be_empty
  end

  test 'Page 2 has no title frame.' do
    page = generated_pdf.pages[5]
    expect(page.frames.none? { |frame| frame.color == HEADER_COLOR }).to be(true)
  end

  test 'All back content lines are within the page 2 content boundary.' do
    page = generated_pdf.pages[5]
    continuation_lines = page.text_lines.select { |line| line.text.start_with?('CONTINUATION LINE') }
    expect(continuation_lines).not_to be_empty

    continuation_lines.each do |line|
      boundary = page.convert_unit(line.boundary, LatexTesting::TargetUnit::MILLIMETERS)
      matcher = be_within(EXPECTED_BACK_CONTENT_BOUNDARY_WITH_TOLERANCE)
      expect(boundary).to matcher, -> { "#{line.text}: #{matcher.failure_message}" }
    end
  end

  test 'The first front content line starts within 1 mm of the content area top.' do
    page = generated_pdf.pages[4]
    first_content_line = page.text_lines.find { |line| line.text.start_with?('FRONT CONTENT LINE') }
    expect(first_content_line).not_to be_nil, 'page 1: first content line is missing'

    line_boundary = page.convert_unit(first_content_line.boundary, LatexTesting::TargetUnit::MILLIMETERS)
    offset = line_boundary.top - EXPECTED_FRONT_CONTENT_BOUNDARY.top
    expect(offset).to be_between(0, 1).inclusive, "page 1: first content line offset is #{offset} mm"
  end

  test 'The first back content line starts within 1 mm of the content area top.' do
    [3, 5].each do |page_index|
      page = generated_pdf.pages[page_index]
      first_content_line = page.text_lines.find { |line| line.text.start_with?('CONTINUATION LINE') }
      expect(first_content_line).not_to be_nil, "page #{page_index + 1}: first content line is missing"
      next unless first_content_line

      line_boundary = page.convert_unit(first_content_line.boundary, LatexTesting::TargetUnit::MILLIMETERS)
      offset = line_boundary.top - EXPECTED_BACK_CONTENT_BOUNDARY.top
      expect(offset).to be_between(0, 1).inclusive, "page #{page_index + 1}: first content line offset is #{offset} mm"
    end
  end

  test 'Page 2 only contains continuation lines' do
    page = generated_pdf.pages[5]
    expect(page.text_lines.map(&:text)).to all(start_with('CONTINUATION LINE'))
  end

  test 'Header is 5 mm from the top of page 1.' do
    page = generated_pdf.pages[4]
    expect(page.convert_unit(page.boundary.top - page.frames.single { |candidate| candidate.color == HEADER_COLOR }.top,
                             LatexTesting::TargetUnit::MILLIMETERS)).to be_within(LAYOUT_BOUNDARY_TOLERANCE).of(EXPECTED_TITLE_BOUNDARY.top)
  end

  test 'Header is 5 mm from the left of page 1.' do
    page = generated_pdf.pages[4]
    expect(page.convert_unit(page.frames.single { |candidate| candidate.color == HEADER_COLOR }.left - page.boundary.left,
                             LatexTesting::TargetUnit::MILLIMETERS)).to be_within(LAYOUT_BOUNDARY_TOLERANCE).of(EXPECTED_TITLE_BOUNDARY.left)
  end

  test 'Header is 5 mm from the right of page 1.' do
    page = generated_pdf.pages[4]
    expect(page.convert_unit(page.boundary.right - page.frames.single { |candidate| candidate.color == HEADER_COLOR }.right,
                             LatexTesting::TargetUnit::MILLIMETERS)).to be_within(LAYOUT_BOUNDARY_TOLERANCE).of(EXPECTED_PAGE_BORDER)
  end

  test 'Header is 15 mm tall.' do
    page = generated_pdf.pages[4]
    expect(page.convert_unit(page.frames.single { |candidate| candidate.color == HEADER_COLOR }.height,
                             LatexTesting::TargetUnit::MILLIMETERS)).to be_within(LAYOUT_BOUNDARY_TOLERANCE).of(EXPECTED_TITLE_BOUNDARY.height)
  end

  test 'There is a 2 mm gap between the header and front content.' do
    page = generated_pdf.pages[4]
    header = page.frames.single { |candidate| candidate.color == HEADER_COLOR }
    front = page.frames.single { |candidate| candidate.color == CONTENT_COLOR }
    expect(page.convert_unit(header.bottom - front.top,
                             LatexTesting::TargetUnit::MILLIMETERS)).to be_within(LAYOUT_BOUNDARY_TOLERANCE).of(EXPECTED_AREA_MARGIN)
  end

  test 'Front content is 5 mm from the left of page 1.' do
    page = generated_pdf.pages[4]
    expect(page.convert_unit(page.frames.single { |candidate| candidate.color == CONTENT_COLOR }.left - page.boundary.left,
                             LatexTesting::TargetUnit::MILLIMETERS)).to be_within(LAYOUT_BOUNDARY_TOLERANCE).of(EXPECTED_PAGE_BORDER)
  end

  test 'Front content is 5 mm from the right of page 1.' do
    page = generated_pdf.pages[4]
    expect(page.convert_unit(page.boundary.right - page.frames.single { |candidate| candidate.color == CONTENT_COLOR }.right,
                             LatexTesting::TargetUnit::MILLIMETERS)).to be_within(LAYOUT_BOUNDARY_TOLERANCE).of(EXPECTED_PAGE_BORDER)
  end

  test 'Front content is 5 mm from the bottom of page 1.' do
    page = generated_pdf.pages[4]
    expect(page.convert_unit(page.frames.single { |candidate| candidate.color == CONTENT_COLOR }.bottom - page.boundary.bottom,
                             LatexTesting::TargetUnit::MILLIMETERS)).to be_within(LAYOUT_BOUNDARY_TOLERANCE).of(EXPECTED_PAGE_BORDER)
  end

  test 'Continuation is 5 mm from the top of page 2.' do
    page = generated_pdf.pages[5]
    expect(page.convert_unit(page.boundary.top - page.frames.single { |candidate| candidate.color == CONTINUATION_COLOR }.top,
                             LatexTesting::TargetUnit::MILLIMETERS)).to be_within(LAYOUT_BOUNDARY_TOLERANCE).of(EXPECTED_PAGE_BORDER)
  end

  test 'Continuation is 5 mm from the left of page 2.' do
    page = generated_pdf.pages[5]
    expect(page.convert_unit(page.frames.single { |candidate| candidate.color == CONTINUATION_COLOR }.left - page.boundary.left,
                             LatexTesting::TargetUnit::MILLIMETERS)).to be_within(LAYOUT_BOUNDARY_TOLERANCE).of(EXPECTED_PAGE_BORDER)
  end

  test 'Continuation is 5 mm from the right of page 2.' do
    page = generated_pdf.pages[5]
    expect(page.convert_unit(page.boundary.right - page.frames.single { |candidate| candidate.color == CONTINUATION_COLOR }.right,
                             LatexTesting::TargetUnit::MILLIMETERS)).to be_within(LAYOUT_BOUNDARY_TOLERANCE).of(EXPECTED_PAGE_BORDER)
  end

  test 'Continuation is 5 mm from the bottom of page 2.' do
    page = generated_pdf.pages[5]
    expect(page.convert_unit(page.frames.single { |candidate| candidate.color == CONTINUATION_COLOR }.bottom - page.boundary.bottom,
                             LatexTesting::TargetUnit::MILLIMETERS)).to be_within(LAYOUT_BOUNDARY_TOLERANCE).of(EXPECTED_PAGE_BORDER)
  end

  test 'Layout boundaries allow the tolerance on every edge.' do
    boundaries = [
      [EXPECTED_TITLE_BOUNDARY, EXPECTED_TITLE_BOUNDARY_WITH_TOLERANCE],
      [EXPECTED_FRONT_CONTENT_BOUNDARY, EXPECTED_FRONT_CONTENT_BOUNDARY_WITH_TOLERANCE],
      [EXPECTED_BACK_CONTENT_BOUNDARY, EXPECTED_BACK_CONTENT_BOUNDARY_WITH_TOLERANCE]
    ]
    edge_directions = { left: -1, top: -1, right: 1, bottom: 1 }

    boundaries.each do |expected, tolerated|
      edge_directions.each do |edge, direction|
        at_tolerance = LatexTesting::Boundary.new(
          **expected.to_h.merge(edge => expected[edge] + direction * LAYOUT_BOUNDARY_TOLERANCE)
        )
        beyond_tolerance = LatexTesting::Boundary.new(
          **expected.to_h.merge(edge => expected[edge] + direction * (LAYOUT_BOUNDARY_TOLERANCE + 0.0001))
        )

        expect(at_tolerance).to be_within(tolerated)
        expect(beyond_tolerance).not_to be_within(tolerated)
      end
    end
  end

  test 'The normal layout title is within the expected boundary with and without debug frames.' do
    aggregate_failures do
      [0, 6].each do |page_index|
        page = generated_pdf.pages[page_index]
        title_lines = page.text_lines.select { |line| line.text == 'Normal layout geometry' }
        expect(title_lines.count).to eq(1), "page #{page_index + 1}: expected one title line"
        next unless title_lines.one?

        boundary = page.convert_unit(title_lines.first.boundary, LatexTesting::TargetUnit::MILLIMETERS)
        expect(boundary).to be_within(EXPECTED_TITLE_BOUNDARY_WITH_TOLERANCE), "page #{page_index + 1}"
      end
    end
  end

  test 'The normal front marker is within the expected boundary with and without debug frames.' do
    aggregate_failures do
      [0, 6].each do |page_index|
        page = generated_pdf.pages[page_index]
        marker_lines = page.text_lines.select { |line| line.text == 'NORMALFRONTMARKER' }
        expect(marker_lines.count).to eq(1), "page #{page_index + 1}: expected one front marker"
        next unless marker_lines.one?

        boundary = page.convert_unit(marker_lines.first.boundary, LatexTesting::TargetUnit::MILLIMETERS)
        expect(boundary).to be_within(EXPECTED_FRONT_CONTENT_BOUNDARY_WITH_TOLERANCE), "page #{page_index + 1}"
      end
    end
  end

  test 'The normal back marker is within the expected boundary with and without debug frames.' do
    aggregate_failures do
      [1, 7].each do |page_index|
        page = generated_pdf.pages[page_index]
        marker_lines = page.text_lines.select { |line| line.text == 'NORMALBACKMARKER' }
        expect(marker_lines.count).to eq(1), "page #{page_index + 1}: expected one back marker"
        next unless marker_lines.one?

        boundary = page.convert_unit(marker_lines.first.boundary, LatexTesting::TargetUnit::MILLIMETERS)
        expect(boundary).to be_within(EXPECTED_BACK_CONTENT_BOUNDARY_WITH_TOLERANCE), "page #{page_index + 1}"
      end
    end
  end

  test 'The first normal front content line starts within 1 mm of the area top with and without debug frames.' do
    aggregate_failures do
      [0, 6].each do |page_index|
        page = generated_pdf.pages[page_index]
        first_content_line = page.text_lines.find { |line| line.text == 'NORMALFRONTMARKER' }
        expect(first_content_line).not_to be_nil, "page #{page_index + 1}: first front content line is missing"
        next unless first_content_line

        line_boundary = page.convert_unit(first_content_line.boundary, LatexTesting::TargetUnit::MILLIMETERS)
        offset = line_boundary.top - EXPECTED_FRONT_CONTENT_BOUNDARY.top
        expect(offset).to be_between(0, 1).inclusive, "page #{page_index + 1}: first front line offset is #{offset} mm"
      end
    end
  end

  test 'The first normal back content line starts within 1 mm of the area top with and without debug frames.' do
    aggregate_failures do
      [1, 7].each do |page_index|
        page = generated_pdf.pages[page_index]
        first_content_line = page.text_lines.find { |line| line.text == 'NORMALBACKMARKER' }
        expect(first_content_line).not_to be_nil, "page #{page_index + 1}: first back content line is missing"
        next unless first_content_line

        line_boundary = page.convert_unit(first_content_line.boundary, LatexTesting::TargetUnit::MILLIMETERS)
        offset = line_boundary.top - EXPECTED_BACK_CONTENT_BOUNDARY.top
        expect(offset).to be_between(0, 1).inclusive, "page #{page_index + 1}: first back line offset is #{offset} mm"
      end
    end
  end

  test 'The normal layout debug variant draws the expected frames.' do
    expect(generated_pdf.pages[6].frames.map(&:color)).to contain_exactly(HEADER_COLOR, CONTENT_COLOR)
    expect(generated_pdf.pages[7].frames.map(&:color)).to contain_exactly(CONTINUATION_COLOR)
  end

  test 'Normal layout text lines and positions are unchanged by debug frames.' do
    [[0, 6], [1, 7]].each do |normal_page_index, debug_page_index|
      normal_page = generated_pdf.pages[normal_page_index]
      debug_page = generated_pdf.pages[debug_page_index]
      normal_lines = normal_page.text_lines
      debug_lines = debug_page.text_lines

      expect(debug_lines.map(&:text)).to eq(normal_lines.map(&:text))

      normal_lines.zip(debug_lines).each do |normal_line, debug_line|
        normal_boundary = normal_page.convert_unit(normal_line.boundary, LatexTesting::TargetUnit::MILLIMETERS)
        debug_boundary = debug_page.convert_unit(debug_line.boundary, LatexTesting::TargetUnit::MILLIMETERS)

        %i[left top right bottom].each do |edge|
          matcher = be_within(LAYOUT_BOUNDARY_TOLERANCE).of(normal_boundary[edge])
          expect(debug_boundary[edge]).to matcher, "#{normal_line.text} #{edge}"
        end
      end
    end
  end
end

fixture 'Card Environment' do
  file '03-card-environment.tex'
  test('The PDF has four pages.') { expect(generated_pdf.pages.count).to eq(4) }

  test 'Card one front contains its title and both content markers only.' do
    text = PDF_TEXT_IN_DRAW_ORDER.call(generated_pdf.pages[0])
    expect(text).to include('CardOne')
    expect(text).to include('CARDONEFIRSTMARKER', 'CARDONESECONDMARKER')
    expect(text).not_to include('CARDTWOFIRSTMARKER', 'CARDTWOSECONDMARKER')
  end

  test 'Card one back is blank.' do
    expect(generated_pdf.pages[1].text_lines).to be_empty
  end

  test 'Card two front contains its title and both content markers only.' do
    text = PDF_TEXT_IN_DRAW_ORDER.call(generated_pdf.pages[2])
    expect(text).to include('CardTwo')
    expect(text).to include('CARDTWOFIRSTMARKER', 'CARDTWOSECONDMARKER')
    expect(text).not_to include('CARDONEFIRSTMARKER', 'CARDONESECONDMARKER')
  end

  test 'Card two back is blank.' do
    expect(generated_pdf.pages[3].text_lines).to be_empty
  end

  test 'A printed front is visible and both short-card backs are raster-white.' do
    expect(RASTERIZED_PAGE_HAS_NONWHITE_PIXELS.call(pdf_path, 1)).to be(true)
    [2, 4].each do |page_number|
      expect(RASTERIZED_PAGE_HAS_NONWHITE_PIXELS.call(pdf_path, page_number)).to be(false)
    end
  end
end

fixture 'Inline Verbatim' do
  file '23-inline-verbatim.tex'

  test 'Inline verbatim preserves special characters and renders after the complete body is read.' do
    expect(generated_pdf.pages.count).to eq(2)

    text = generated_pdf.pages[0].text_lines.map(&:text).join.gsub(/\s+/, '')
    expect(text).to include('BEFOREMARKER', 'a_b%{}\\#$&_^~', 'AFTERMARKER')
    expect(log.index('CARD-BODY-COMPLETE')).to be < log.index('CARD-OUTPUT-BEGIN')
  end
end

fixture 'Supported Card Contents' do
  file '24-supported-card-contents.tex'

  test 'Both APIs preserve text, paragraphs, formatting, lists, and tables in card order.' do
    expect(generated_pdf.pages.count).to eq(8)

    expected_titles = ['Environment without reference', 'Command with reference',
                       'Command without reference', 'Environment with reference']
    expected_references = [nil, 'Ref 123', nil, 'Ref 456']
    expected_markers = ['TEXT INTRODUCTION', 'SECOND PARAGRAPH', 'BOLD CONTENT MARKER',
                        'LIST ITEM ALPHA', 'LIST ITEM BRAVO', 'TABLE LEFT', 'TABLE RIGHT',
                        'IMAGE-LEFT', 'IMAGE-RIGHT', 'CONTENT FINISH']
    front_indices = [0, 2, 4, 6]

    front_indices.each_with_index do |page_index, card_index|
      front = generated_pdf.pages[page_index]
      back = generated_pdf.pages[page_index + 1]
      lines = PDF_BODY_LINES.call(front, 'TEXTINTRODUCTION')
      normalized_text = PDF_TEXT_IN_DRAW_ORDER.call(front)

      expect(normalized_text).to include(expected_titles[card_index].gsub(/\s+/, ''))
      if expected_references[card_index]
        expect(normalized_text).to include(expected_references[card_index].gsub(/\s+/, ''))
      else
        expect(normalized_text).not_to include('Ref123', 'Ref456')
      end
      expected_markers.each { |marker| expect(normalized_text).to include(marker.gsub(/\s+/, '')) }
      expect(expected_markers.map { |marker| normalized_text.index(marker.gsub(/\s+/, '')) })
        .to eq(expected_markers.map { |marker| normalized_text.index(marker.gsub(/\s+/, '')) }.sort)
      expect(back.text_lines).to be_empty

      lines.each do |line|
        boundary = front.convert_unit(line.boundary, LatexTesting::TargetUnit::MILLIMETERS)
        expect(boundary).to be_within(EXPECTED_FRONT_CONTENT_BOUNDARY_WITH_TOLERANCE)
      end
    end

    baseline_lines = PDF_BODY_LINES.call(generated_pdf.pages[0], 'TEXTINTRODUCTION')
    front_indices.drop(1).each do |page_index|
      lines = PDF_BODY_LINES.call(generated_pdf.pages[page_index], 'TEXTINTRODUCTION')
      expect(lines.map(&:text)).to eq(baseline_lines.map(&:text))
      lines.zip(baseline_lines).each do |line, baseline_line|
        boundary = generated_pdf.pages[page_index].convert_unit(line.boundary, LatexTesting::TargetUnit::MILLIMETERS)
        baseline_boundary = generated_pdf.pages[0].convert_unit(baseline_line.boundary, LatexTesting::TargetUnit::MILLIMETERS)
        %i[left top right bottom].each do |edge|
          expect(boundary[edge]).to be_within(LAYOUT_BOUNDARY_TOLERANCE).of(baseline_boundary[edge])
        end
      end
    end
  end

  test 'All pages from both APIs retain A6 landscape dimensions.' do
    generated_pdf.pages.each do |page|
      expect(page.convert_unit(page.boundary.width, LatexTesting::TargetUnit::MILLIMETERS))
        .to be_within(LAYOUT_BOUNDARY_TOLERANCE).of(EXPECTED_PAGE_BOUNDARY.width)
      expect(page.convert_unit(page.boundary.height, LatexTesting::TargetUnit::MILLIMETERS))
        .to be_within(LAYOUT_BOUNDARY_TOLERANCE).of(EXPECTED_PAGE_BOUNDARY.height)
    end
  end

  test 'A printed front is visible and every short-card back is raster-white.' do
    expect(RASTERIZED_PAGE_HAS_NONWHITE_PIXELS.call(pdf_path, 1)).to be(true)
    [2, 4, 6, 8].each do |page_number|
      expect(RASTERIZED_PAGE_HAS_NONWHITE_PIXELS.call(pdf_path, page_number)).to be(false)
    end
  end

  test 'The included PDF image is placed in the card body with its visible width reflected between text markers.' do
    page = generated_pdf.pages[0]
    xobjects = page.resources[:XObject]
    expect(xobjects).not_to be_nil
    expect(xobjects.to_hash.values.any? { |object| object[:Subtype] == :Form }).to be(true)

    image_line = page.text_lines.find do |line|
      line.text.include?('IMAGE-LEFT') && line.text.include?('IMAGE-RIGHT')
    end
    expect(image_line).not_to be_nil
    return if image_line.nil?

    boundary = page.convert_unit(image_line.boundary, LatexTesting::TargetUnit::MILLIMETERS)
    expect(boundary.width).to be > 50.0
  end
end

fixture 'Saved Verbatim Workaround' do
  file '25-saved-verbatim-workaround.tex'

  test 'Saved fancyvrb content with special characters renders between surrounding card text.' do
    expect(generated_pdf.pages.count).to eq(2)

    text = generated_pdf.pages[0].text_lines.map(&:text).join.gsub(/\s+/, '')
    expect(text).to include('BEFORE-SAVED-VERBATIM', 'saved_a_b%{}\\#$&_^~', 'secondline', 'AFTER-SAVED-VERBATIM')
  end
end

fixture 'Debug Frame Equivalence' do
  file '05-debug-frame-equivalence.tex'

  test 'Normal and debug cards have identical text lines and positions.' do
    expect(generated_pdf.pages.count).to eq(16)

    (0..7).each do |page_index|
      normal_page = generated_pdf.pages[page_index]
      debug_page = generated_pdf.pages[page_index + 8]
      normal_lines = normal_page.text_lines
      debug_lines = debug_page.text_lines

      expect(debug_lines.map(&:text)).to eq(normal_lines.map(&:text))
      expect(debug_lines.count).to eq(normal_lines.count)

      normal_lines.zip(debug_lines).each do |normal_line, debug_line|
        normal_boundary = normal_page.convert_unit(normal_line.boundary, LatexTesting::TargetUnit::MILLIMETERS)
        debug_boundary = debug_page.convert_unit(debug_line.boundary, LatexTesting::TargetUnit::MILLIMETERS)

        %i[left top right bottom].each do |edge|
          matcher = be_within(LAYOUT_BOUNDARY_TOLERANCE).of(normal_boundary[edge])
          expect(debug_boundary[edge]).to matcher, "#{normal_line.text} #{edge}"
        end
      end
    end
  end

  test 'The Card command and card environment have identical text lines and positions.' do
    [[0, 4], [2, 6], [8, 12], [10, 14]].each do |command_page_index, environment_page_index|
      [0, 1].each do |page_offset|
        command_page = generated_pdf.pages[command_page_index + page_offset]
        environment_page = generated_pdf.pages[environment_page_index + page_offset]
        command_lines = command_page.text_lines
        environment_lines = environment_page.text_lines

        expect(environment_lines.map(&:text)).to eq(command_lines.map(&:text))
        expect(environment_lines.count).to eq(command_lines.count)

        command_lines.zip(environment_lines).each do |command_line, environment_line|
          command_boundary = command_page.convert_unit(command_line.boundary, LatexTesting::TargetUnit::MILLIMETERS)
          environment_boundary = environment_page.convert_unit(environment_line.boundary, LatexTesting::TargetUnit::MILLIMETERS)

          %i[left top right bottom].each do |edge|
            matcher = be_within(LAYOUT_BOUNDARY_TOLERANCE).of(command_boundary[edge])
            expect(environment_boundary[edge]).to matcher, "#{command_line.text} #{edge}"
          end
        end
      end
    end
  end
end

fixture 'Card Delegation' do
  file '06-card-delegation.tex'

  test 'The Card command preserves legacy calls and delegates its optional reference, title, and content.' do
    begin_marker = 'CARD-DELEGATION-BEGIN:Delegation title'
    end_marker = 'CARD-DELEGATION-END:Delegation title'

    expect(log).to include(
      'CARD-DELEGATION-REFERENCE:',
      'CARD-DELEGATION-BEGIN:Legacy title',
      'CARD-DELEGATION-END:Legacy title',
      'CARD-DELEGATION-REFERENCE:Delegation reference',
      begin_marker,
      end_marker
    )
    expect(log.index(begin_marker)).to be < log.index(end_marker)
    expect(generated_pdf.pages.flat_map(&:text_lines).map(&:text).join).to include(
      'LEGACYCONTENTMARKER', 'DELEGATEDCONTENTMARKER'
    )
  end
end

fixture 'Card Reference State' do
  file '07-card-reference-state.tex'

  test 'Missing, empty, whitespace-only, and relax-only references are absent.' do
    expect(log.scan(/^CARD-REFERENCE:ABSENT$/)).to eq(Array.new(5, 'CARD-REFERENCE:ABSENT'))
  end

  test 'Visible, formatted, macro-generated, and command references are present per card.' do
    expect(log).to include(
      'CARD-REFERENCE:PRESENT:Visible reference',
      'CARD-REFERENCE:PRESENT:\\textbf {Formatted reference}',
      'CARD-REFERENCE:PRESENT:\\VisibleReference ',
      'CARD-REFERENCE:PRESENT:Command reference',
      'CARD-REFERENCE:PRESENT:First reference',
      'CARD-REFERENCE:ABSENT',
      'CARD-REFERENCE:PRESENT:Second reference'
    )
  end
end

fixture 'Reference Rendering' do
  file '08-reference-rendering.tex'

  test 'Normal and debug reference cards keep their page count and front/back order.' do
    expect(generated_pdf.pages.count).to eq(24)
    [1, 3, 5, 7, 9, 11, 13, 15, 17, 19, 21, 23].each do |back_page_index|
      expect(generated_pdf.pages[back_page_index].text_lines).to be_empty
    end
  end

  test 'A single-line reference prints completely within its own area.' do
    page = generated_pdf.pages[2]
    reference_line = page.text_lines.find { |line| line.text.gsub(/\s+/, '') == 'WdZ.567' }
    expect(reference_line).not_to be_nil
    return if reference_line.nil?

    reference_boundary = page.convert_unit(reference_line.boundary, LatexTesting::TargetUnit::MILLIMETERS)
    expect(reference_boundary).to be_within(LAYOUT_BOUNDARY_WITH_TOLERANCE.call(EXPECTED_REFERENCE_BOUNDARY))
  end

  test 'An explicit two-line reference keeps both lines in order and within the reference area.' do
    page = generated_pdf.pages[4]
    reference_lines = page.text_lines.select do |line|
      %w[WdZ.567 Wdz.567].include?(line.text.gsub(/\s+/, ''))
    end
    expect(reference_lines.map { |line| line.text.gsub(/\s+/, '') }).to eq(%w[WdZ.567 Wdz.567])
    return unless reference_lines.length == 2

    boundaries = reference_lines.map do |line|
      page.convert_unit(line.boundary, LatexTesting::TargetUnit::MILLIMETERS)
    end
    boundaries.each do |boundary|
      expect(boundary).to be_within(LAYOUT_BOUNDARY_WITH_TOLERANCE.call(EXPECTED_REFERENCE_BOUNDARY))
    end
    expect(boundaries[1].top).to be > boundaries[0].top
  end

  test 'A naturally wrapped reference remains complete on two lines.' do
    lines = generated_pdf.pages[6].text_lines.map(&:text)
    expect(lines).to include('WdZ. 567', 'Wdz. 567')
  end

  test 'Formatted and macro-generated references are rendered, and their active size is 9 pt with 11 pt leading.' do
    formatted_lines = generated_pdf.pages[8].text_lines.map(&:text)
    expect(formatted_lines.join(' ')).to include('Bold ref')
    expect(generated_pdf.pages[10].text_lines.map(&:text)).to include('MacroRef')
    expect(log).to include('REFERENCE-FONT:9pt:11.0pt')
  end

  test 'A rendered reference has the same width as the same text set directly at 9 pt.' do
    reference_line = generated_pdf.pages[2].text_lines.find { |line| line.text.gsub(/\s+/, '') == 'WdZ.567' }
    control_line = generated_pdf.pages[22].text_lines.find { |line| line.text.gsub(/\s+/, '') == 'WdZ.567' }
    expect(reference_line).not_to be_nil
    expect(control_line).not_to be_nil
    return if reference_line.nil? || control_line.nil?

    reference_boundary = generated_pdf.pages[2].convert_unit(reference_line.boundary, LatexTesting::TargetUnit::MILLIMETERS)
    control_boundary = generated_pdf.pages[22].convert_unit(control_line.boundary, LatexTesting::TargetUnit::MILLIMETERS)
    expect(reference_boundary.width).to be_within(LAYOUT_BOUNDARY_TOLERANCE).of(control_boundary.width)
  end

  test 'A nonempty title and its reference both appear on the same front.' do
    text = PDF_TEXT_IN_DRAW_ORDER.call(generated_pdf.pages[12])
    expect(text).to include('Titlebesidereference', 'Command', 'reference')
    expect(generated_pdf.pages[13].text_lines).to be_empty
  end

  test 'References only appear on their own fronts, and normal mode has no frames.' do
    expect(generated_pdf.pages[0].text_lines.map { |line| line.text.gsub(/\s+/, '') }).not_to include('WdZ.567', 'Wdz.567')
    expect(generated_pdf.pages[2].text_lines.map { |line| line.text.gsub(/\s+/, '') }).to include('WdZ.567')
    expect(generated_pdf.pages[4].text_lines.map { |line| line.text.gsub(/\s+/, '') }).to include('WdZ.567', 'Wdz.567')
    14.times do |page_index|
      expect(generated_pdf.pages[page_index].frames.to_a).to be_empty
    end
  end

  test 'The front content position is unchanged by a reference.' do
    no_reference_page = generated_pdf.pages[0]
    reference_page = generated_pdf.pages[2]
    no_reference_line = no_reference_page.text_lines.find { |line| line.text.gsub(/\s+/, '') == 'REFERENCECONTENTPOSITIONMARKER' }
    reference_line = reference_page.text_lines.find { |line| line.text.gsub(/\s+/, '') == 'REFERENCECONTENTPOSITIONMARKER' }
    expect(no_reference_line).not_to be_nil
    expect(reference_line).not_to be_nil
    return if no_reference_line.nil? || reference_line.nil?

    no_reference_boundary = no_reference_page.convert_unit(no_reference_line.boundary, LatexTesting::TargetUnit::MILLIMETERS)
    reference_boundary = reference_page.convert_unit(reference_line.boundary, LatexTesting::TargetUnit::MILLIMETERS)
    %i[left top right bottom].each do |edge|
      expect(reference_boundary[edge]).to be_within(LAYOUT_BOUNDARY_TOLERANCE).of(no_reference_boundary[edge])
    end
    expect(reference_boundary).to be_within(EXPECTED_FRONT_CONTENT_BOUNDARY_WITH_TOLERANCE)
  end

  test 'Debug frames identify the reference area only when a reference exists.' do
    no_reference_frames = generated_pdf.pages[14].frames.map(&:color)
    expect(no_reference_frames).to contain_exactly(HEADER_COLOR, CONTENT_COLOR)

    [16, 18].each do |page_index|
      frames = generated_pdf.pages[page_index].frames
      expect(frames.map(&:color)).to contain_exactly(HEADER_COLOR, REFERENCE_COLOR, CONTENT_COLOR)
      expect(frames.count { |frame| frame.color == REFERENCE_COLOR }).to eq(1)
    end
  end

  test 'Debug frames have the required header widths, reference size, gap, and page inset.' do
    page = generated_pdf.pages[18]
    title_frame = page.frames.single { |frame| frame.color == HEADER_COLOR }
    reference_frame = page.frames.single { |frame| frame.color == REFERENCE_COLOR }
    frame_boundary = lambda do |frame|
      LatexTesting::Boundary.new(
        left: page.convert_unit(frame.left, LatexTesting::TargetUnit::MILLIMETERS),
        top: page.convert_unit(page.boundary.top - frame.top, LatexTesting::TargetUnit::MILLIMETERS),
        right: page.convert_unit(frame.right, LatexTesting::TargetUnit::MILLIMETERS),
        bottom: page.convert_unit(page.boundary.top - frame.bottom, LatexTesting::TargetUnit::MILLIMETERS)
      )
    end
    title_boundary = frame_boundary.call(title_frame)
    reference_boundary = frame_boundary.call(reference_frame)

    expect(title_boundary).to be_within(LAYOUT_BOUNDARY_WITH_TOLERANCE.call(EXPECTED_TITLE_WITH_REFERENCE_BOUNDARY))
    expect(reference_boundary).to be_within(LAYOUT_BOUNDARY_WITH_TOLERANCE.call(EXPECTED_REFERENCE_BOUNDARY))
    expect(reference_boundary.left - title_boundary.right).to be_within(LAYOUT_BOUNDARY_TOLERANCE).of(EXPECTED_AREA_MARGIN)

    full_page = generated_pdf.pages[14]
    full_frame = full_page.frames.single { |frame| frame.color == HEADER_COLOR }
    expect(full_page.convert_unit(full_frame.right - full_frame.left, LatexTesting::TargetUnit::MILLIMETERS))
      .to be_within(LAYOUT_BOUNDARY_TOLERANCE).of(138.0)
  end

  test 'Debug and normal reference cards have identical text and positions.' do
    [[2, 16], [4, 18], [4, 20]].each do |normal_page_index, debug_page_index|
      normal_page = generated_pdf.pages[normal_page_index]
      debug_page = generated_pdf.pages[debug_page_index]
      expect(debug_page.text_lines.map(&:text)).to eq(normal_page.text_lines.map(&:text))

      normal_page.text_lines.zip(debug_page.text_lines).each do |normal_line, debug_line|
        normal_boundary = normal_page.convert_unit(normal_line.boundary, LatexTesting::TargetUnit::MILLIMETERS)
        debug_boundary = debug_page.convert_unit(debug_line.boundary, LatexTesting::TargetUnit::MILLIMETERS)
        %i[left top right bottom].each do |edge|
          expect(debug_boundary[edge]).to be_within(LAYOUT_BOUNDARY_TOLERANCE).of(normal_boundary[edge])
        end
      end
    end
  end
end

fixture 'Reference Three Lines' do
  file '09-reference-three-lines.tex'
  expect_compilation_failure
  requires_log 'Package pnpcards Error: Reference exceeds two lines'
end

fixture 'Reference Too Wide' do
  file '10-reference-too-wide.tex'
  expect_compilation_failure
  requires_log 'Package pnpcards Error: Reference does not fit horizontally'
end

fixture 'Reference Too High' do
  file '11-reference-too-high.tex'
  expect_compilation_failure
  requires_log 'Package pnpcards Error: Reference does not fit vertically'
end

fixture 'Reference First Line Too Wide' do
  file '13-reference-first-line-too-wide.tex'
  expect_compilation_failure
  requires_log 'Package pnpcards Error: Reference does not fit horizontally'
end

fixture 'Reference Three Paragraphs' do
  file '16-reference-three-paragraphs.tex'
  expect_compilation_failure
  requires_log 'Package pnpcards Error: Reference exceeds two lines'
end

fixture 'Reference Near Boundary' do
  file '14-reference-near-boundary.tex'
  test('Near-width one- and two-line references compile on their own fronts.') do
    expect(generated_pdf.pages.count).to eq(4)
  end

  test 'Near-width reference text is visible at the right edge of its own reference area.' do
    [[0, 'NEARWIDTHONEBODY', ['WdZ.567']], [2, 'NEARWIDTHTWOBODY', %w[WdZ.567 Wdz.567]]].each do |page_index, body, expected_lines|
      page = generated_pdf.pages[page_index]
      expect(page.text_lines.map { |line| line.text.gsub(/\s+/, '') }).to include(body)
      actual_lines = page.text_lines.select do |line|
        %w[WdZ.567 Wdz.567].include?(line.text.gsub(/\s+/, ''))
      end
      expect(actual_lines.map { |line| line.text.gsub(/\s+/, '') }).to eq(expected_lines)

      actual_lines.each do |line|
        boundary = page.convert_unit(line.boundary, LatexTesting::TargetUnit::MILLIMETERS)
        expect(boundary.left).to be >= EXPECTED_REFERENCE_BOUNDARY.left - LAYOUT_BOUNDARY_TOLERANCE
        expect(boundary.right).to be <= EXPECTED_REFERENCE_BOUNDARY.right + LAYOUT_BOUNDARY_TOLERANCE
        expect(boundary.right).to be_within(1.5).of(EXPECTED_REFERENCE_BOUNDARY.right)
        expect(boundary.top).to be >= EXPECTED_REFERENCE_BOUNDARY.top - LAYOUT_BOUNDARY_TOLERANCE
        expect(boundary.bottom).to be <= EXPECTED_REFERENCE_BOUNDARY.bottom + LAYOUT_BOUNDARY_TOLERANCE
      end
    end
    [1, 3].each { |page_index| expect(generated_pdf.pages[page_index].text_lines).to be_empty }
  end
end

fixture 'Reference Card Sequence' do
  file '15-reference-card-sequence.tex'
  test 'Each card has only its own reference and reference frame, never on the back.' do
    expect(generated_pdf.pages.count).to eq(18)
    expected = [nil, nil, nil, nil, 'Alpha', 'Bravo', 'MacroRef', nil, 'Charlie']
    titles = %w[One Two Three Four Five Six Seven Eight Nine]
    expected.each_with_index do |reference, index|
      front = generated_pdf.pages[index * 2]
      back = generated_pdf.pages[index * 2 + 1]
      expect(PDF_TEXT_IN_DRAW_ORDER.call(front)).to eq(titles[index] + reference.to_s + 'Body')
      expect(front.frames.count { |frame| frame.color == REFERENCE_COLOR }).to eq(reference.nil? ? 0 : 1)
      expect(back.text_lines).to be_empty
      expect(back.frames.count { |frame| frame.color == REFERENCE_COLOR }).to eq(0)
    end
  end

  test 'All pages in the normal and debug reference sequence retain A6 landscape dimensions.' do
    generated_pdf.pages.each do |page|
      expect(page.convert_unit(page.boundary.width, LatexTesting::TargetUnit::MILLIMETERS))
        .to be_within(LAYOUT_BOUNDARY_TOLERANCE).of(EXPECTED_PAGE_BOUNDARY.width)
      expect(page.convert_unit(page.boundary.height, LatexTesting::TargetUnit::MILLIMETERS))
        .to be_within(LAYOUT_BOUNDARY_TOLERANCE).of(EXPECTED_PAGE_BOUNDARY.height)
    end
  end

  test 'A printed debug front is visible and all short-card backs are raster-white.' do
    expect(RASTERIZED_PAGE_HAS_NONWHITE_PIXELS.call(pdf_path, 1)).to be(true)
    (2..18).step(2) do |page_number|
      expect(RASTERIZED_PAGE_HAS_NONWHITE_PIXELS.call(pdf_path, page_number)).to be(false)
    end
  end
end

fixture 'Empty Cards' do
  file '17-empty-cards.tex'

  test 'Fully empty cards from both APIs each retain their own front and back pages.' do
    expect(generated_pdf.pages.count).to eq(24)
    [2, 4, 6, 8, 14, 16, 18, 20].each do |index|
      expect(generated_pdf.pages[index].text_lines).to be_empty
      expect(generated_pdf.pages[index + 1].text_lines).to be_empty
    end
    [[0, 'Before'], [10, 'After'], [12, 'Debugbefore'], [22, 'Debugafter']].each do |index, title|
      expect(PDF_TEXT_IN_DRAW_ORDER.call(generated_pdf.pages[index])).to eq(title + 'Body')
      expect(generated_pdf.pages[index + 1].text_lines).to be_empty
    end
  end
end

fixture 'Title Boundaries' do
  file '18-title-boundaries.tex'

  test 'Normal titles scale from one 10 pt bold line and are height-limited with or without a reference.' do
    expect(generated_pdf.pages.count).to eq(10)
    expect(log.scan('TITLE-FONT:10pt').size).to eq(2)
    control = log[/TITLE-CONTROL:([\d.]+pt)/, 1]
    measured = log.scan(/TITLE-MEASURED:([\d.]+pt)/).flatten
    measured_heights = log.scan(/TITLE-HEIGHT-MEASURED:([\d.]+pt)/).flatten
    available_widths = log.scan(/TITLE-AVAILABLE-WIDTH:([\d.]+pt)/).flatten
    available_heights = log.scan(/TITLE-AVAILABLE-HEIGHT:([\d.]+pt)/).flatten
    expect(control).not_to be_nil
    expect(measured.length).to eq(5)
    expect(measured_heights.length).to eq(5)
    expect(available_widths.length).to eq(5)
    expect(available_heights.length).to eq(5)
    expect(measured.first(2).map(&:to_f).first).to be > control.to_f
    expect(measured.first(2).map(&:to_f).first).to be_within(0.01).of(measured[1].to_f)
    measured_heights.first(2).each do |height|
      expect(height.to_f).to be_within(0.05).of(available_heights.first.to_f)
    end
    [2, 3, 4].each do |index|
      expect(measured[index].to_f).to be_within(0.05).of(available_widths[index].to_f)
    end
    [0, 2].each do |index|
      width = index.zero? ? 138.0 : 121.0
      title = PDF_TEXT_LINE_IN_AREA.call(
        generated_pdf.pages[index], 'Title', left_mm: 5.0, right_mm: 5.0 + width,
        top_mm: 5.0, bottom_mm: 30.0
      )
      expect(title).not_to be_nil
      expect(generated_pdf.pages[index + 1].text_lines).to be_empty
    end
  end

  test 'Titles just inside each width and the shared intermediate title are accepted.' do
    [[4, 'Full width title'], [6, 'Narrow title'], [8, 'Only without reference']].each do |index, title|
      page = generated_pdf.pages[index]
      title_line = page.text_lines.find { |line| line.text.include?(title) }
      expect(title_line).not_to be_nil
      next if title_line.nil?

      boundary = page.convert_unit(title_line.boundary, LatexTesting::TargetUnit::MILLIMETERS)
      if index == 6
        title_frame = page.frames.single { |frame| frame.color == HEADER_COLOR }
        expect(boundary.left).to be_within(LAYOUT_BOUNDARY_TOLERANCE).of(EXPECTED_TITLE_WITH_REFERENCE_BOUNDARY.left)
        expect(page.convert_unit(title_frame.left - page.boundary.left, LatexTesting::TargetUnit::MILLIMETERS))
          .to be_within(LAYOUT_BOUNDARY_TOLERANCE).of(EXPECTED_TITLE_WITH_REFERENCE_BOUNDARY.left)
        expect(page.convert_unit(title_frame.width, LatexTesting::TargetUnit::MILLIMETERS))
          .to be_within(LAYOUT_BOUNDARY_TOLERANCE).of(EXPECTED_TITLE_WITH_REFERENCE_BOUNDARY.width)
        expect(page.convert_unit(page.boundary.top - title_frame.top, LatexTesting::TargetUnit::MILLIMETERS))
          .to be_within(LAYOUT_BOUNDARY_TOLERANCE).of(EXPECTED_TITLE_WITH_REFERENCE_BOUNDARY.top)
        expect(page.convert_unit(title_frame.height, LatexTesting::TargetUnit::MILLIMETERS))
          .to be_within(LAYOUT_BOUNDARY_TOLERANCE).of(EXPECTED_TITLE_WITH_REFERENCE_BOUNDARY.height)
        expect(page.convert_unit(page.boundary.right - title_frame.right, LatexTesting::TargetUnit::MILLIMETERS))
          .to be_within(LAYOUT_BOUNDARY_TOLERANCE).of(EXPECTED_PAGE_BOUNDARY.right - EXPECTED_TITLE_WITH_REFERENCE_BOUNDARY.right)
      else
        expect(boundary).to be_within(EXPECTED_TITLE_BOUNDARY_WITH_TOLERANCE)
      end
    end
  end
end

fixture 'Title Width Fitting' do
  file '19-title-too-wide.tex'

  test 'A title 0.1 mm wider than its area is scaled to fit.' do
    expect(generated_pdf.pages.count).to eq(2)
    title = PDF_TEXT_LINE_IN_AREA.call(
      generated_pdf.pages[0], 'Toowide', left_mm: 5.0, right_mm: 143.0, top_mm: 5.0, bottom_mm: 21.0
    )
    expect(title).not_to be_nil
    return if title.nil?

    boundary = generated_pdf.pages[0].convert_unit(title.boundary, LatexTesting::TargetUnit::MILLIMETERS)
    expect(boundary).to be_within(TITLE_TEXT_BOUNDARY_WITH_TOLERANCE.call(EXPECTED_TITLE_BOUNDARY))
    expect(generated_pdf.pages[1].text_lines).to be_empty
  end
end

fixture 'Title Width Fitting With Reference' do
  file '20-title-too-wide-with-reference.tex'

  test 'A referenced title 0.1 mm wider than its area stays separate from the reference.' do
    expect(generated_pdf.pages.count).to eq(2)
    page = generated_pdf.pages[0]
    title = PDF_TEXT_LINE_IN_AREA.call(
      page, 'Onlywithoutreference', left_mm: 5.0, right_mm: 126.0, top_mm: 5.0, bottom_mm: 21.0
    )
    reference = PDF_TEXT_LINE_IN_AREA.call(page, 'Ref', left_mm: 128.0, right_mm: 143.0, top_mm: 5.0, bottom_mm: 21.0)
    expect(title).not_to be_nil
    expect(reference).not_to be_nil
    return if title.nil? || reference.nil?

    title_boundary = page.convert_unit(title.boundary, LatexTesting::TargetUnit::MILLIMETERS)
    reference_boundary = page.convert_unit(reference.boundary, LatexTesting::TargetUnit::MILLIMETERS)
    expect(title_boundary.right).to be < reference_boundary.left
    expect(page.text_lines.map(&:text).join.gsub(/\s+/, '')).to include('Onlywithoutreference', 'Ref')
    expect(generated_pdf.pages[1].text_lines).to be_empty
  end
end

fixture 'Title Height Fitting' do
  file '21-title-too-high.tex'

  test 'A title 0.1 mm higher than its area is scaled to fit.' do
    expect(generated_pdf.pages.count).to eq(2)
    expect(RASTERIZED_PAGE_HAS_NONWHITE_PIXELS.call(pdf_path, 1)).to be(true)
    expect(generated_pdf.pages[1].text_lines).to be_empty
  end
end

fixture 'Title Height Fitting With Reference' do
  file '22-title-too-high-with-reference.tex'

  test 'A referenced title 0.1 mm higher than its area is scaled to fit.' do
    expect(generated_pdf.pages.count).to eq(2)
    expect(generated_pdf.pages[0].text_lines.map(&:text).join.gsub(/\s+/, '')).to include('Ref')
    expect(RASTERIZED_PAGE_HAS_NONWHITE_PIXELS.call(pdf_path, 1)).to be(true)
    expect(generated_pdf.pages[1].text_lines).to be_empty
  end
end

fixture 'Title Below Minimum With Reference Only' do
  file '43-title-below-minimum-reference-only.tex'
  expect_compilation_failure
  requires_log 'Card 2'

  test 'The error identifies the 7 pt minimum and the horizontal cause.' do
    expect(log).to include('Title requires less than 7 pt', 'Cause: horizontally')
  end
end

fixture 'Title Below Minimum Width' do
  file '44-title-below-minimum-width.tex'
  expect_compilation_failure

  test 'The error identifies the 7 pt minimum and the horizontal cause.' do
    expect(log).to include('Title requires less than 7 pt', 'Cause: horizontally')
  end
end

fixture 'Title Below Minimum Width With Reference' do
  file '45-title-below-minimum-width-with-reference.tex'
  expect_compilation_failure

  test 'The error identifies the 7 pt minimum and the horizontal cause.' do
    expect(log).to include('Title requires less than 7 pt', 'Cause: horizontally')
  end
end

fixture 'Title Below Minimum Height' do
  file '46-title-below-minimum-height.tex'
  expect_compilation_failure

  test 'The error identifies the 7 pt minimum and the vertical cause.' do
    expect(log).to include('Title requires less than 7 pt', 'Cause: vertically')
  end
end

fixture 'Title Exact 10 pt' do
  file '47-title-exact-10-pt.tex'

  test 'A title exactly at the 10 pt horizontal boundary keeps its base size.' do
    expect(generated_pdf.pages.count).to eq(2)
    page = generated_pdf.pages[0]
    title = PDF_TEXT_LINE_IN_AREA.call(page, 'EXACTTEN', left_mm: 5.0, right_mm: 143.0, top_mm: 5.0, bottom_mm: 21.0)
    body = page.text_lines.find { |line| line.text.gsub(/\s+/, '') == 'BODY' }
    expect(title).not_to be_nil
    expect(body).not_to be_nil
    return if title.nil? || body.nil?

    title_boundary = page.convert_unit(title.boundary, LatexTesting::TargetUnit::MILLIMETERS)
    body_boundary = page.convert_unit(body.boundary, LatexTesting::TargetUnit::MILLIMETERS)
    expect(title_boundary.height).to be_within(0.01).of(body_boundary.height)
    expect(generated_pdf.pages[1].text_lines).to be_empty
  end
end

fixture 'Title Exact 7 pt' do
  file '48-title-exact-7-pt.tex'

  test 'Exactly 7 pt remains valid and fills each available title width.' do
    expect(generated_pdf.pages.count).to eq(4)
    measured = log.scan(/EXACT-SEVEN-BOX-WIDTH-\d+:([\d.]+pt)/).flatten
    available = log.scan(/EXACT-SEVEN-AVAILABLE-WIDTH-\d+:([\d.]+pt)/).flatten
    expect(measured.length).to eq(2)
    expect(available.length).to eq(2)
    measured.zip(available).each do |actual, expected|
      expect(actual.to_f).to be_within(0.01).of(expected.to_f)
    end

    [0, 2].each_with_index do |page_index, index|
      width = index.zero? ? 138.0 : 121.0
      title = PDF_TEXT_LINE_IN_AREA.call(
        generated_pdf.pages[page_index], 'EXACTSEVEN', left_mm: 5.0, right_mm: 5.0 + width,
        top_mm: 5.0, bottom_mm: 21.0
      )
      expect(title).not_to be_nil
      next if title.nil?

      boundary = generated_pdf.pages[page_index].convert_unit(title.boundary, LatexTesting::TargetUnit::MILLIMETERS)
      expected_height = 10.0 * 0.7 * 25.4 / 72.0
      expect(boundary.height).to be_within(0.05).of(expected_height)
      expect(generated_pdf.pages[page_index + 1].text_lines).to be_empty
    end
  end
end

fixture 'Title Just Below 7 pt' do
  file '49-title-just-below-7-pt.tex'
  expect_compilation_failure

  test 'A just-under-7-pt title reports the horizontal minimum.' do
    expect(log).to include('Title requires less than 7 pt', 'Cause: horizontally')
  end
end

fixture 'Title Empty Dimensions And Formatting' do
  file '50-title-empty-dimensions-and-formatting.tex'

  test 'Empty titles stay empty and one-dimensional and formatted titles scale safely.' do
    expect(generated_pdf.pages.count).to eq(10)
    dimensions = log.scan(/TITLE-EDGE-DIMS-(\d+):([\d.]+pt):([\d.]+pt):([\d.]+pt)/).to_h do |index, width, height, depth|
      [index.to_i, [width.to_f, height.to_f, depth.to_f]]
    end
    expect(dimensions[1]).to eq([0.0, 0.0, 0.0])
    expect(dimensions[2]).to eq([0.0, 0.0, 0.0])
    expect(dimensions[3][0]).to eq(0.0)
    expect(dimensions[3][1] + dimensions[3][2]).to be_within(0.05 * 72.27 / 25.4).of(15.0 * 72.27 / 25.4)
    expect(dimensions[4][1] + dimensions[4][2]).to eq(0.0)
    expect(dimensions[5][0]).to be > 0.0
    expect(log).to include('TITLE-MACRO-EXECUTION-COUNT:1')
    expect(generated_pdf.pages[0].text_lines.map(&:text).join.gsub(/\s+/, '')).to include('EMPTYBODY')
    expect(generated_pdf.pages[2].text_lines.map(&:text).join.gsub(/\s+/, '')).to include('REF', 'EMPTYREFERENCEBODY')
    [[4, 'ZEROWIDTH'], [6, 'ZEROHEIGHT'], [8, 'FORMATTED']].each do |page_index, text|
      processor = HexaPDF::Content::SmartTextExtractor::TextRunProcessor.new
      generated_pdf.pages[page_index].process_contents(processor)
      expect(processor.text_runs.map(&:string).join.gsub(/\s+/, '')).to include(text)
    end
    [1, 3, 5, 7, 9].each { |page_index| expect(generated_pdf.pages[page_index].text_lines).to be_empty }
  end
end

fixture 'Title Rounded Box Bounds' do
  file '51-title-rounded-box-bounds.tex'

  test 'Scaled box dimensions never exceed their available areas.' do
    expect(generated_pdf.pages.count).to eq(238)
    expect(log).not_to include('Package title-test Error')
  end
end

fixture 'Title Scaling Twelve Point' do
  file '52-title-scaling-twelve-point.tex'

  test 'The 10 pt base is independent of the document default and long text shrinks above 7 pt.' do
    expect(generated_pdf.pages.count).to eq(6)
    expect(log.scan('TWELVE-DOC-TITLE-BASE:10pt').size).to eq(2)
    factors = log.scan(/TWELVE-DOC-TITLE-FACTOR-\d+:([\d.]+)/).flatten.map(&:to_f)
    expect(factors.length).to eq(3)
    expect(factors[0]).to be_between(0.7, 1.0)
    expect(factors[1]).to be_between(0.7, factors[0])
    expect(factors[2]).to be_within(0.0001).of(15.0 / 21.0)
    [0, 2].each do |index|
      processor = HexaPDF::Content::SmartTextExtractor::TextRunProcessor.new
      generated_pdf.pages[index].process_contents(processor)
      expect(processor.text_runs.map(&:string).join).to include('M' * 45)
    end
    [1, 3, 5].each { |index| expect(generated_pdf.pages[index].text_lines).to be_empty }
  end
end

fixture 'Title Tiny Dimensions' do
  file '53-title-tiny-dimensions.tex'

  test 'A single scaled point grows to fill its nonzero dimension without arithmetic overflow.' do
    expect(generated_pdf.pages.count).to eq(4)
    widths = log.scan(/TINY-TITLE-WIDTH-\d+:([\d.]+)pt/).flatten.map(&:to_f)
    heights = log.scan(/TINY-TITLE-HEIGHT-\d+:([\d.]+)pt/).flatten.map(&:to_f)
    expect(widths.length).to eq(2)
    expect(heights.length).to eq(2)
    expect(widths[0]).to be_within(0.01).of(138.0 * 72.27 / 25.4)
    expect(heights[0]).to eq(0.0)
    expect(widths[1]).to eq(0.0)
    expect(heights[1]).to be_within(0.01).of(15.0 * 72.27 / 25.4)
  end
end

fixture 'Title Halt On Error Compilation' do
  file '47-title-exact-10-pt.tex'

  test 'Ticket fixtures have the expected exit status with halt-on-error.' do
    positive = %w[18-title-boundaries 19-title-too-wide 20-title-too-wide-with-reference
                  21-title-too-high 22-title-too-high-with-reference 41-title-scaling
                  42-card-specific-title-scaling 47-title-exact-10-pt 48-title-exact-7-pt
                  50-title-empty-dimensions-and-formatting 51-title-rounded-box-bounds
                  52-title-scaling-twelve-point 53-title-tiny-dimensions]
    negative = {
      '43-title-below-minimum-reference-only' => 'horizontally',
      '44-title-below-minimum-width' => 'horizontally',
      '45-title-below-minimum-width-with-reference' => 'horizontally',
      '46-title-below-minimum-height' => 'vertically',
      '49-title-just-below-7-pt' => 'horizontally'
    }
    root = File.expand_path('../../../..', __dir__)
    env = { 'TEXINPUTS' => "#{File.join(root, 'tex/latex/pnpcards')}:" }
    Dir.mktmpdir('pnpcards-halt-', File.join(root, 'out')) do |directory|
      (positive + negative.keys).each do |name|
        source = File.join(__dir__, "#{name}.tex")
        output, status = Open3.capture2e(
          env, 'latexmk', '-pdf', '-interaction=nonstopmode', '-halt-on-error', "-outdir=#{directory}", source
        )
        expect([name, status.success?]).to eq([name, positive.include?(name)])
        next unless negative.key?(name)

        log_path = File.join(directory, "#{name}.log")
        expect(File.file?(log_path)).to be(true)
        log_content = File.file?(log_path) ? File.read(log_path) : output
        expect(log_content).to include('Package pnpcards Error:', 'Title requires less than 7 pt', "Cause: #{negative[name]}")
      end
    end
  end
end

fixture 'Title Scaling' do
  file '41-title-scaling.tex'

  test 'Short titles grow beyond 10 pt and remain height-limited with or without a reference.' do
    expect(generated_pdf.pages.count).to eq(8)
    short_pages = [generated_pdf.pages[0], generated_pdf.pages[2]]
    short_lines = short_pages.each_with_index.map do |page, index|
      width = index.zero? ? 138.0 : 121.0
      PDF_TEXT_LINE_IN_AREA.call(page, 'M', left_mm: 5.0, right_mm: 5.0 + width, top_mm: 5.0, bottom_mm: 30.0)
    end
    controls = short_pages.map do |page|
      PDF_TEXT_LINE_IN_AREA.call(page, 'CONTROLM', left_mm: 5.0, right_mm: 143.0, top_mm: 21.5, bottom_mm: 35.0)
    end
    expect(short_lines).not_to include(nil)
    expect(controls).not_to include(nil)
    return if short_lines.include?(nil) || controls.include?(nil)

    short_boundaries = short_pages.zip(short_lines).map do |page, line|
      page.convert_unit(line.boundary, LatexTesting::TargetUnit::MILLIMETERS)
    end
    control_boundaries = short_pages.zip(controls).map do |page, line|
      page.convert_unit(line.boundary, LatexTesting::TargetUnit::MILLIMETERS)
    end
    short_boundaries.each_with_index do |boundary, index|
      expect(boundary.height).to be > control_boundaries[index].height + 0.05
    end
    expect(short_boundaries[0].height).to be_within(0.05).of(short_boundaries[1].height)
  end

  test 'Long titles scale down uniformly to their available widths and stay clear of references.' do
    no_reference_page = generated_pdf.pages[4]
    reference_page = generated_pdf.pages[6]
    long_text = 'M' * 28
    title_lines = [no_reference_page, reference_page].each_with_index.map do |page, index|
      width = index.zero? ? 138.0 : 121.0
      PDF_TEXT_LINE_IN_AREA.call(page, long_text, left_mm: 5.0, right_mm: 5.0 + width, top_mm: 5.0, bottom_mm: 21.0)
    end
    expect(title_lines).not_to include(nil)
    return if title_lines.include?(nil)

    title_boundaries = [no_reference_page, reference_page].zip(title_lines).map do |page, line|
      page.convert_unit(line.boundary, LatexTesting::TargetUnit::MILLIMETERS)
    end
    expect(title_boundaries[1].width).to be < title_boundaries[0].width
    expect(title_boundaries[1].height).to be < title_boundaries[0].height
    expect(title_boundaries[0].width / title_boundaries[1].width)
      .to be_within(0.03).of(title_boundaries[0].height / title_boundaries[1].height)

    reference_line = PDF_TEXT_LINE_IN_AREA.call(
      reference_page, 'Ref', left_mm: 128.0, right_mm: 143.0, top_mm: 5.0, bottom_mm: 21.0
    )
    expect(reference_line).not_to be_nil
    return if reference_line.nil?

    reference_boundary = reference_page.convert_unit(reference_line.boundary, LatexTesting::TargetUnit::MILLIMETERS)
    expect(title_boundaries[1].right).to be < reference_boundary.left
  end

  test 'Scaled title text remains inside its fixed header area in normal and debug mode.' do
    [0, 2, 4, 6].each do |page_index|
      page = generated_pdf.pages[page_index]
      title_text = page_index < 4 ? 'M' : 'M' * 28
      width = [0, 4].include?(page_index) ? 138.0 : 121.0
      title = PDF_TEXT_LINE_IN_AREA.call(
        page, title_text, left_mm: 5.0, right_mm: 5.0 + width, top_mm: 5.0, bottom_mm: 30.0
      )
      expect(title).not_to be_nil
      next if title.nil?

      boundary = page.convert_unit(title.boundary, LatexTesting::TargetUnit::MILLIMETERS)
      area = [0, 4].include?(page_index) ? EXPECTED_TITLE_BOUNDARY : EXPECTED_TITLE_WITH_REFERENCE_BOUNDARY
      expect(boundary.left).to be >= area.left - LAYOUT_BOUNDARY_TOLERANCE
      expect(boundary.right).to be <= area.right + LAYOUT_BOUNDARY_TOLERANCE
      expect(RASTERIZED_PAGE_HAS_NONWHITE_PIXELS.call(pdf_path, page_index + 1, forbidden_title_width: width)).to be(false)
      expect(page.text_lines.select { |line| line.text.gsub(/\s+/, '') == 'LONGBODY' }.length).to eq(page_index >= 4 ? 1 : 0)
    end
    expect(generated_pdf.pages[1].text_lines).to be_empty
    expect(generated_pdf.pages[3].text_lines).to be_empty
    expect(generated_pdf.pages[4].frames.map(&:color)).to contain_exactly(HEADER_COLOR, CONTENT_COLOR)
    expect(generated_pdf.pages[6].frames.map(&:color)).to contain_exactly(HEADER_COLOR, REFERENCE_COLOR, CONTENT_COLOR)
    [5, 7].each do |page_index|
      expect(generated_pdf.pages[page_index].text_lines).to be_empty
      expect(generated_pdf.pages[page_index].frames.to_a).to be_empty
    end
  end
end

fixture 'Card Specific Title Scaling' do
  file '42-card-specific-title-scaling.tex'

  test 'Short and long titles keep per-card sizes in both orders and through both APIs.' do
    expect(generated_pdf.pages.count).to eq(8)
    pages = generated_pdf.pages
    expected_titles = ['M', 'M' * 28, 'M' * 28, 'M']
    title_boundaries = expected_titles.each_with_index.map do |title, card_index|
      page = pages[card_index * 2]
      title_line = page.text_lines.find { |line| line.text.gsub(/\s+/, '') == title }
      expect(title_line).not_to be_nil
      next if title_line.nil?

      page.convert_unit(title_line.boundary, LatexTesting::TargetUnit::MILLIMETERS)
    end
    return if title_boundaries.include?(nil)

    expect(title_boundaries[0].height).to be > title_boundaries[1].height
    expect(title_boundaries[3].height).to be > title_boundaries[2].height
    expect(title_boundaries[0].height).to be_within(0.05).of(title_boundaries[3].height)
    expect(title_boundaries[1].height).to be_within(0.05).of(title_boundaries[2].height)
    [1, 3, 5, 7].each { |page_index| expect(pages[page_index].text_lines).to be_empty }
  end
end

fixture 'Reference Page Splitting' do
  file '12-reference-page-splitting.tex'

  test 'References remain on their own fronts for explicit and natural breaks.' do
    expect(generated_pdf.pages.count).to eq(16)
    8.times do |card|
      front = PDF_TEXT_IN_DRAW_ORDER.call(generated_pdf.pages[card * 2])
      back = PDF_TEXT_IN_DRAW_ORDER.call(generated_pdf.pages[card * 2 + 1])
      expect(front).to include('Ref123', 'CONTENTLINE01')
      expect(back).not_to include('Ref123')
      expect(back).to include(card.even? ? 'CONTENTLINE03' : 'CONTENTLINE12')
    end
  end

  test 'Both APIs and debug mode preserve all text and positions on each side.' do
    [[0, 4], [2, 6], [0, 8], [2, 10], [4, 12], [6, 14]].each do |first, second|
      [0, 1].each do |offset|
        left_page = generated_pdf.pages[first + offset]
        right_page = generated_pdf.pages[second + offset]
        left_lines = left_page.text_lines
        right_lines = right_page.text_lines
        expect(right_lines.map(&:text)).to eq(left_lines.map(&:text))
        left_lines.zip(right_lines).each do |left, right|
          left_boundary = left_page.convert_unit(left.boundary, LatexTesting::TargetUnit::MILLIMETERS)
          right_boundary = right_page.convert_unit(right.boundary, LatexTesting::TargetUnit::MILLIMETERS)
          %i[left top right bottom].each do |edge|
            expect(right_boundary[edge]).to be_within(LAYOUT_BOUNDARY_TOLERANCE).of(left_boundary[edge])
          end
        end
      end
    end
  end

  test 'Every content line is preserved in order within its front or back area.' do
    [0, 2].each do |front_index|
      front = generated_pdf.pages[front_index]
      back = generated_pdf.pages[front_index + 1]
      expected = front_index.zero? ? 4 : 12
      text = [front, back].map { |page| PDF_TEXT_IN_DRAW_ORDER.call(page) }.join
      expect(text.scan(/CONTENTLINE\d\d/)).to eq((1..expected).map { |i| format('CONTENTLINE%02d', i) })
      (1..expected).each do |number|
        marker = format('CONTENTLINE%02d', number)
        lines = [front, back].each_with_index.filter_map do |page, index|
          line = PDF_TEXT_LINE_IN_AREA.call(
            page, marker, left_mm: 5.0, right_mm: 143.0, top_mm: index.zero? ? 22.0 : 5.0, bottom_mm: 100.0
          )
          next unless line

          area = index.zero? ? EXPECTED_FRONT_CONTENT_BOUNDARY_WITH_TOLERANCE : EXPECTED_BACK_CONTENT_BOUNDARY_WITH_TOLERANCE
          expect(page.convert_unit(line.boundary, LatexTesting::TargetUnit::MILLIMETERS)).to be_within(area)
          line
        end
        expect(lines.length).to eq(1)
      end
    end
  end
end

fixture 'Natural Overflow Repeated Title' do
  file '27-page-limit-natural-repeated-title.tex'
  expect_compilation_failure
  requires_log 'Package pnpcards Error: Card 3'
  requires_log 'two-page limit'
  test 'The error identifies the repeated title.' do
    expect(log[/! Package pnpcards Error:.*?(?=\n\s*\n)/m]).to include('Repeated title')
  end
end

fixture 'Natural Overflow Empty Title' do
  file '28-page-limit-natural-empty-title.tex'
  expect_compilation_failure
  requires_log 'Package pnpcards Error: Card 3'
  requires_log 'two-page limit'
end

fixture 'Natural Overflow Formatted Title' do
  file '29-page-limit-natural-formatted-title.tex'
  expect_compilation_failure
  requires_log 'Package pnpcards Error: Card 2'
  requires_log 'two-page limit'
  test 'The title is reported without executing its macro again.' do
    expect(log[/! Package pnpcards Error:.*?(?=\n\s*\n)/m]).to include('\\TitleEffect')
    expect(log.scan('TITLE-EXECUTED').size).to eq(1)
  end
end

fixture 'Page Limit Boundary' do
  file '26-page-limit-boundary.tex'

  test 'Exactly two pages contain all boundary markers in order.' do
    expect(generated_pdf.pages.count).to eq(2)
    expect(generated_pdf.pages[0].text_lines.map(&:text)).to eq(['Boundary', 'FRONTTOP', 'FRONTBOTTOM'])
    expect(generated_pdf.pages[1].text_lines.map(&:text)).to eq(['BACKTOP', 'BACKBOTTOM'])
  end

  test 'Each marker remains within its respective page area.' do
    generated_pdf.pages.each_with_index do |page, index|
      area = index.zero? ? EXPECTED_FRONT_CONTENT_BOUNDARY_WITH_TOLERANCE : EXPECTED_BACK_CONTENT_BOUNDARY_WITH_TOLERANCE
      page.text_lines.select { |line| line.text.start_with?('FRONT', 'BACK') }.each do |line|
        expect(page.convert_unit(line.boundary, LatexTesting::TargetUnit::MILLIMETERS)).to be_within(area)
      end
    end
  end

  requires_log 'BOUNDARY-FRONT-EXACT'
  requires_log 'BOUNDARY-BACK-EXACT'
end

fixture 'Page Limit Unbreakable' do
  file '30-page-limit-unbreakable.tex'
  expect_compilation_failure
  requires_log 'Package pnpcards Error: Card 1'
  requires_log 'two-page limit'
end

fixture 'Page Limit Shrinkable Glue' do
  file '31-page-limit-shrinkable-glue.tex'
  test 'Shrinkable spacing at the boundary remains valid.' do
    expect(generated_pdf.pages.count).to eq(2)
    expect(PDF_TEXT_IN_DRAW_ORDER.call(generated_pdf.pages[0])).to eq('ShrinkableSHRINKTOPSHRINKBOTTOM')
    expect(generated_pdf.pages[1].text_lines.map(&:text)).to eq(['BACKCONTENT'])
  end
end

[
  ['Page Limit Two Breaks', '32-page-limit-two-breaks.tex', 2],
  ['Page Limit Consecutive Breaks', '33-page-limit-consecutive-breaks.tex', 1],
  ['Page Limit Trailing Breaks', '34-page-limit-trailing-breaks.tex', 1],
  ['Page Limit Break Then Natural', '35-page-limit-break-then-natural.tex', 1],
  ['Page Limit Natural Then Trailing Break', '36-page-limit-natural-then-trailing-break.tex', 2],
  ['Page Limit Natural Then Break', '37-page-limit-natural-then-break.tex', 1]
].each do |name, filename, index|
  fixture name do
    file filename
    expect_compilation_failure
    requires_log "Package pnpcards Error: Card #{index}"
    requires_log 'two-page limit'
  end
end

fixture 'Page Limit Valid Breaks' do
  file '38-page-limit-valid-breaks.tex'
  test 'Empty cards and single beginning or ending breaks stay on their own two pages.' do
    expect(generated_pdf.pages.count).to eq(10)
    pages = generated_pdf.pages.map { |page| PDF_TEXT_IN_DRAW_ORDER.call(page) }
    expect(pages).to eq(['Beginning', 'STARTBACK', 'EndingFRONTEND', '', 'Empty', '',
                         'MiddleFRONTMIDDLE', 'BACKMIDDLE', 'AfterAFTERCONTENT', ''])
  end
end

fixture 'Page Limit Exact Break And Structure' do
  file '39-page-limit-exact-break-and-structure.tex'
  test 'An exact front with one break and trailing structure remains valid.' do
    expect(generated_pdf.pages.count).to eq(2)
    expect(PDF_TEXT_IN_DRAW_ORDER.call(generated_pdf.pages[0])).to eq('ExactbreakFRONT')
    expect(generated_pdf.pages[1].text_lines.map(&:text)).to eq(['BACK'])
  end
end

fixture 'Page Limit Back One Sp Too High' do
  file '40-page-limit-back-one-sp-too-high.tex'
  expect_compilation_failure
  requires_log 'Package pnpcards Error: Card 1'
  requires_log 'two-page limit'
end
