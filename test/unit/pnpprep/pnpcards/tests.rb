# frozen_string_literal: true

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

fixture 'Page Splitting' do
  file '01-page-splitting.tex'

  test 'The PDF has 6 pages' do
    expect(generated_pdf.pages.count).to eq(6)
  end

  test('No debug frames appear on any page.') do
    expect(generated_pdf.pages).to all(have_attributes(frames: have_attributes(count: 0)))
  end

  test 'Page 1 contains the short-content title and its content.' do
    expect(generated_pdf.pages[0].text_lines.map(&:text)).to eq(['Short content', 'SHORTCONTENTFITSONFRONT'])
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

    boundary = page.convert_unit(title_lines.first.boundary, LatexTesting::TargetUnit::MILLIMETERS)
    expect(boundary).to be_within(EXPECTED_TITLE_BOUNDARY_WITH_TOLERANCE)
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
    lines = generated_pdf.pages[0].text_lines
    text = lines.map(&:text).join(' ')
    expect(lines.map(&:text)).to include('Card One')
    expect(text).to include('CARDONEFIRSTMARKER', 'CARDONESECONDMARKER')
    expect(text).not_to include('CARDTWOFIRSTMARKER', 'CARDTWOSECONDMARKER')
  end

  test 'Card one back is blank.' do
    expect(generated_pdf.pages[1].text_lines).to be_empty
  end

  test 'Card two front contains its title and both content markers only.' do
    lines = generated_pdf.pages[2].text_lines
    text = lines.map(&:text).join(' ')
    expect(lines.map(&:text)).to include('Card Two')
    expect(text).to include('CARDTWOFIRSTMARKER', 'CARDTWOSECONDMARKER')
    expect(text).not_to include('CARDONEFIRSTMARKER', 'CARDONESECONDMARKER')
  end

  test 'Card two back is blank.' do
    expect(generated_pdf.pages[3].text_lines).to be_empty
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

  test 'The Card command delegates its title and content to the card environment.' do
    begin_marker = 'CARD-DELEGATION-BEGIN:Delegation title'
    end_marker = 'CARD-DELEGATION-END:Delegation title'

    expect(log).to include(begin_marker, end_marker)
    expect(log.index(begin_marker)).to be < log.index(end_marker)
    expect(generated_pdf.pages.flat_map(&:text_lines).map(&:text).join).to include('DELEGATEDCONTENTMARKER')
  end
end
