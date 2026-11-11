fixture 'Page Splitting' do
  file '01-page-splitting.tex'
  manual_test 'Pages use A6 landscape format.'
  test 'The PDF has 6 pages' do
    expect(generated_pdf.pages.count).to eq(6)
  end

  test('No debug frames appear on any page.') do
    expect(generated_pdf.pages).to all(have_attributes(frames: have_attributes(count: 0)))
  end

  manual_test 'Page 1 has a front title area.'
  manual_test 'Page 1 shows SHORT CONTENT FITS ON FRONT in the front content area.'
  manual_test 'Page 2 is a blank back page.'
  manual_test "Page 3 has the front title 'Natural overflow'."
  manual_test 'Page 3 begins the Lorem Ipsum text in the front content area.'
  manual_test 'Page 4 continues the Lorem Ipsum text from the top of the untitled continuation area.'
  manual_test "Page 5 has the front title 'Explicit page break'."
  manual_test 'Page 5 shows CONTENT BEFORE NEWPAGE in the content area.'
  manual_test 'The front side on page 5 is not full.'
  manual_test 'Page 5 contains no debug text.'
  manual_test 'Page 6 shows CONTENT AFTER NEWPAGE at the top.'
  manual_test 'Page 6 has no title area.'
end

fixture 'A6 Geometry' do
  file '02-a6-geometry.tex'

  test('The PDF has two pages.') { expect(generated_pdf.pages.count).to eq(2) }

  test 'All pages are A6 landscape format (148 mm x 105 mm).' do
    generated_pdf.pages.each do |page|
      expect(page.convert_unit(page.boundary.width, LatexTesting::TargetUnit::MILLIMETERS)).to be_within(0.01).of(148.0)
      expect(page.convert_unit(page.boundary.height,
                               LatexTesting::TargetUnit::MILLIMETERS)).to be_within(0.01).of(105.0)
    end
  end

  manual_test 'FRONT CONTENT LINE 01 onward appears in the page 1 front content frame.'
  manual_test 'Page 2 has no title frame.'
  manual_test 'Page 2 starts with CONTINUATION LINE 10.'

  test 'Header is 5 mm from the top of page 1.' do
    page = generated_pdf.pages[0]
    expect(page.convert_unit(page.boundary.top - page.frames.single { |candidate| candidate.color == [0.75, 0, 0] }.top,
                              LatexTesting::TargetUnit::MILLIMETERS)).to be_within(0.01).of(5.0)
  end

  test 'Header is 5 mm from the left of page 1.' do
    page = generated_pdf.pages[0]
    expect(page.convert_unit(page.frames.single { |candidate| candidate.color == [0.75, 0, 0] }.left - page.boundary.left,
                              LatexTesting::TargetUnit::MILLIMETERS)).to be_within(0.01).of(5.0)
  end

  test 'Header is 5 mm from the right of page 1.' do
    page = generated_pdf.pages[0]
    expect(page.convert_unit(page.boundary.right - page.frames.single { |candidate| candidate.color == [0.75, 0, 0] }.right,
                              LatexTesting::TargetUnit::MILLIMETERS)).to be_within(0.01).of(5.0)
  end

  test 'Header is 15 mm tall.' do
    page = generated_pdf.pages[0]
    expect(page.convert_unit(page.frames.single { |candidate| candidate.color == [0.75, 0, 0] }.height,
                              LatexTesting::TargetUnit::MILLIMETERS)).to be_within(0.01).of(15.0)
  end

  test 'There is a 2 mm gap between the header and front content.' do
    page = generated_pdf.pages[0]
    header = page.frames.single { |candidate| candidate.color == [0.75, 0, 0] }
    front = page.frames.single { |candidate| candidate.color == [0, 0, 0.75] }
    expect(page.convert_unit(header.bottom - front.top,
                              LatexTesting::TargetUnit::MILLIMETERS)).to be_within(0.01).of(2.0)
  end

  test 'Front content is 5 mm from the left of page 1.' do
    page = generated_pdf.pages[0]
    expect(page.convert_unit(page.frames.single { |candidate| candidate.color == [0, 0, 0.75] }.left - page.boundary.left,
                              LatexTesting::TargetUnit::MILLIMETERS)).to be_within(0.01).of(5.0)
  end

  test 'Front content is 5 mm from the right of page 1.' do
    page = generated_pdf.pages[0]
    expect(page.convert_unit(page.boundary.right - page.frames.single { |candidate| candidate.color == [0, 0, 0.75] }.right,
                              LatexTesting::TargetUnit::MILLIMETERS)).to be_within(0.01).of(5.0)
  end

  test 'Front content is 5 mm from the bottom of page 1.' do
    page = generated_pdf.pages[0]
    expect(page.convert_unit(page.frames.single { |candidate| candidate.color == [0, 0, 0.75] }.bottom - page.boundary.bottom,
                              LatexTesting::TargetUnit::MILLIMETERS)).to be_within(0.01).of(5.0)
  end

  test 'Continuation is 5 mm from the top of page 2.' do
    page = generated_pdf.pages[1]
    expect(page.convert_unit(page.boundary.top - page.frames.single { |candidate| candidate.color == [0, 0.5, 0] }.top,
                              LatexTesting::TargetUnit::MILLIMETERS)).to be_within(0.01).of(5.0)
  end

  test 'Continuation is 5 mm from the left of page 2.' do
    page = generated_pdf.pages[1]
    expect(page.convert_unit(page.frames.single { |candidate| candidate.color == [0, 0.5, 0] }.left - page.boundary.left,
                              LatexTesting::TargetUnit::MILLIMETERS)).to be_within(0.01).of(5.0)
  end

  test 'Continuation is 5 mm from the right of page 2.' do
    page = generated_pdf.pages[1]
    expect(page.convert_unit(page.boundary.right - page.frames.single { |candidate| candidate.color == [0, 0.5, 0] }.right,
                              LatexTesting::TargetUnit::MILLIMETERS)).to be_within(0.01).of(5.0)
  end

  test 'Continuation is 5 mm from the bottom of page 2.' do
    page = generated_pdf.pages[1]
    expect(page.convert_unit(page.frames.single { |candidate| candidate.color == [0, 0.5, 0] }.bottom - page.boundary.bottom,
                              LatexTesting::TargetUnit::MILLIMETERS)).to be_within(0.01).of(5.0)
  end
end

fixture 'Card Environment' do
  file '03-card-environment.tex'
  manual_test 'Page 1 is the front of card 1.'
  manual_test "The page 1 title area shows 'Mit Referenz'."
  manual_test 'The page 1 content area shows the two lines of card text.'
  manual_test "The reference 'WdZ 102' does not appear on page 1."
  manual_test 'Page 2 is the blank back page for card 1.'
  manual_test 'Page 3 is the front of card 2.'
  manual_test "The page 3 title area shows 'Ohne Referenz'."
  manual_test 'The page 3 content area shows the two lines of card text.'
  manual_test 'Page 4 is the blank back page for card 2.'
  manual_test 'No content appears outside the designated card areas.'
end

fixture 'Explicit Page Break' do
  file '04-explicit-page-break.tex'
  manual_test "Page 1 has the title 'Expliziter Umbruch'."
  manual_test "Page 1 shows only 'VORNE VOR UMBRUCH' in the content area."
  manual_test 'The front side on page 1 is not full.'
  manual_test 'No debug text appears on page 1.'
  manual_test "Page 2 shows 'HINTEN NACH UMBRUCH' at the top."
  manual_test 'Page 2 has no title area.'
  manual_test "Page 3 has the title 'Natuerlicher Ueberlauf'."
  manual_test 'Page 3 shows the beginning of the Lorem Ipsum text in the front content area.'
  manual_test 'The page 3 front body area is filled.'
  manual_test 'Page 4 continues the Lorem Ipsum text from the top.'
  manual_test 'Page 4 has no title area.'
  manual_test "No debug text such as 'Explicit break marker detected' appears on any page."
end
