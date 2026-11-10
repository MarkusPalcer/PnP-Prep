testsuite 'PnpCards' do
  test 'Page Splitting' do
    file '01-page-splitting.tex'
    user_assert 'Pages use A6 landscape format.'
    assert 'The PDF has 6 pages' do
      generated_pdf do
        number_of_pages = pages.count
        raise "#{number_of_pages} found" unless number_of_pages == 6
      end
    end

    assert 'No debug frames appear on any page.' do
      generated_pdf do
        pages.each_with_index do |page, index|
          frame_count = page.frames.count

          if frame_count.positive?
            raise "Page #{index + 1} has #{frame_count} frames, expected #{expected_frame_counts[index]}"
          end
        end
      end
    end

    user_assert 'Page 1 has a front title area.'
    user_assert 'Page 1 shows SHORT CONTENT FITS ON FRONT in the front content area.'
    user_assert 'Page 2 is a blank back page.'
    user_assert "Page 3 has the front title 'Natural overflow'."
    user_assert 'Page 3 begins the Lorem Ipsum text in the front content area.'
    user_assert 'Page 4 continues the Lorem Ipsum text from the top of the untitled continuation area.'
    user_assert "Page 5 has the front title 'Explicit page break'."
    user_assert 'Page 5 shows CONTENT BEFORE NEWPAGE in the content area.'
    user_assert 'The front side on page 5 is not full.'
    user_assert 'Page 5 contains no debug text.'
    user_assert 'Page 6 shows CONTENT AFTER NEWPAGE at the top.'
    user_assert 'Page 6 has no title area.'
  end

  test 'A6 Geometry' do
    file '02-a6-geometry.tex'
    assert 'The PDF has two pages.' do
      generated_pdf do
        raise "Expected 2 pages, found #{pages.count}" unless pages.count == 2
      end
    end

    assert 'All pages are A6 landscape format (148 mm x 105 mm).' do
      generated_pdf do
        expected_size = [148.0, 105.0]
        pages.each_with_index do |page, index|
          actual_size = page.box(:media).then do |box|
            [box.width, box.height].map { |points| points * 25.4 / 72 }
          end
          next if actual_size.zip(expected_size).all? { |actual, expected| (actual - expected).abs <= 0.01 }

          raise "Page #{index + 1} is #{actual_size.join(' x ')} mm, expected 148 x 105 mm"
        end
      end
    end

    user_assert 'FRONT CONTENT LINE 01 onward appears in the page 1 front content frame.'
    user_assert 'Page 2 has no title frame.'
    user_assert 'Page 2 starts with CONTINUATION LINE 10.'

    assert_mm = lambda do |description, page_index, expected_mm, &measurement|
      assert description do
        generated_pdf do
          page = pages[page_index]
          actual_mm = page.convert_unit(measurement.call(page), LatexTesting::TargetUnit::MILLIMETERS)
          unless (actual_mm - expected_mm).abs <= 0.01
            raise "Expected #{expected_mm} mm, found #{actual_mm.round(3)} mm"
          end
        end
      end
    end
    frame = lambda do |page, color|
      page.frames.single { |candidate| candidate.color == color }
    end

    assert_mm.call('Header is 5 mm from the top of page 1.', 0, 5.0) do |page|
      page.boundary.top - frame.call(page, [0.75, 0, 0]).top
    end
    assert_mm.call('Header is 5 mm from the left of page 1.', 0, 5.0) do |page|
      frame.call(page, [0.75, 0, 0]).left - page.boundary.left
    end
    assert_mm.call('Header is 5 mm from the right of page 1.', 0, 5.0) do |page|
      page.boundary.right - frame.call(page, [0.75, 0, 0]).right
    end

    assert_mm.call('Header is 15 mm tall.', 0, 15.0) { |page| frame.call(page, [0.75, 0, 0]).height }

    assert_mm.call('There is a 2 mm gap between the header and front content.', 0, 2.0) do |page|
      header = frame.call(page, [0.75, 0, 0])
      front = frame.call(page, [0, 0, 0.75])
      header.bottom - front.top
    end

    assert_mm.call('Front content is 5 mm from the left of page 1.', 0, 5.0) do |page|
      frame.call(page, [0, 0, 0.75]).left - page.boundary.left
    end

    assert_mm.call('Front content is 5 mm from the right of page 1.', 0, 5.0) do |page|
      page.boundary.right - frame.call(page, [0, 0, 0.75]).right
    end

    assert_mm.call('Front content is 5 mm from the bottom of page 1.', 0, 5.0) do |page|
      frame.call(page, [0, 0, 0.75]).bottom - page.boundary.bottom
    end

    assert_mm.call('Continuation is 5 mm from the top of page 2.', 1, 5.0) do |page|
      page.boundary.top - frame.call(page, [0, 0.5, 0]).top
    end

    assert_mm.call('Continuation is 5 mm from the left of page 2.', 1, 5.0) do |page|
      frame.call(page, [0, 0.5, 0]).left - page.boundary.left
    end

    assert_mm.call('Continuation is 5 mm from the right of page 2.', 1, 5.0) do |page|
      page.boundary.right - frame.call(page, [0, 0.5, 0]).right
    end

    assert_mm.call('Continuation is 5 mm from the bottom of page 2.', 1, 5.0) do |page|
      frame.call(page, [0, 0.5, 0]).bottom - page.boundary.bottom
    end
  end

  test 'Card Environment' do
    file '03-card-environment.tex'
    user_assert 'Page 1 is the front of card 1.'
    user_assert "The page 1 title area shows 'Mit Referenz'."
    user_assert 'The page 1 content area shows the two lines of card text.'
    user_assert "The reference 'WdZ 102' does not appear on page 1."
    user_assert 'Page 2 is the blank back page for card 1.'
    user_assert 'Page 3 is the front of card 2.'
    user_assert "The page 3 title area shows 'Ohne Referenz'."
    user_assert 'The page 3 content area shows the two lines of card text.'
    user_assert 'Page 4 is the blank back page for card 2.'
    user_assert 'No content appears outside the designated card areas.'
  end

  test 'Explicit Page Break' do
    file '04-explicit-page-break.tex'
    user_assert "Page 1 has the title 'Expliziter Umbruch'."
    user_assert "Page 1 shows only 'VORNE VOR UMBRUCH' in the content area."
    user_assert 'The front side on page 1 is not full.'
    user_assert 'No debug text appears on page 1.'
    user_assert "Page 2 shows 'HINTEN NACH UMBRUCH' at the top."
    user_assert 'Page 2 has no title area.'
    user_assert "Page 3 has the title 'Natuerlicher Ueberlauf'."
    user_assert 'Page 3 shows the beginning of the Lorem Ipsum text in the front content area.'
    user_assert 'The page 3 front body area is filled.'
    user_assert 'Page 4 continues the Lorem Ipsum text from the top.'
    user_assert 'Page 4 has no title area.'
    user_assert "No debug text such as 'Explicit break marker detected' appears on any page."
  end
end
