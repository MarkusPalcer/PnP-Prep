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
    user_assert 'No debug frames appear on any page.'
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

    frame_geometry = nil
    collect_frame_geometry = lambda do |execution|
      frame_geometry ||= execution.generated_pdf do
        stroke_collector = Class.new(HexaPDF::Content::Processor) do
          attr_reader :strokes

          def initialize(resources)
            super
            @path = []
            @strokes = []
          end

          def move_to(x, y)
            @path = [graphics_state.ctm.evaluate(x, y)]
          end

          def line_to(x, y)
            @path << graphics_state.ctm.evaluate(x, y)
          end

          def stroke_path
            color = graphics_state.stroke_color
            @strokes << {
              color: color.components,
              width: graphics_state.line_width,
              cap: graphics_state.line_cap_style.value,
              matrix: graphics_state.ctm.to_a,
              points: @path.dup
            }
            @path.clear
          end
        end

        collect_strokes = lambda do |page|
          processor = stroke_collector.new(page.resources)
          HexaPDF::Content::Parser.parse(page.contents, processor)
          processor.strokes
        end
        measure_frame = lambda do |page, page_strokes, expected_color|
          strokes = page_strokes.select do |stroke|
            stroke[:color].length == expected_color.length &&
              stroke[:color].zip(expected_color).all? { |actual, expected| (actual - expected).abs <= 0.001 }
          end
          raise "Expected four frame strokes in RGB #{expected_color.inspect}" unless strokes.length == 4
          raise 'Frame strokes must use butt caps' unless strokes.all? { |stroke| stroke[:cap] == 0 }

          widths = strokes.map { |stroke| stroke[:width] }
          raise 'Frame strokes must have a consistent width' unless widths.max - widths.min <= 0.001

          strokes.each do |stroke|
            unless stroke[:matrix][0..3].zip([1, 0, 0, 1])
              .all? { |actual, expected| (actual - expected).abs <= 0.001 }
              raise 'Frame strokes must not be scaled or rotated'
            end
            raise 'Frame borders must be straight line segments' unless stroke[:points].length == 2
          end

          horizontal, vertical = strokes.partition do |stroke|
            (stroke[:points][0][1] - stroke[:points][1][1]).abs <= 0.001
          end
          unless horizontal.length == 2 && vertical.length == 2 &&
                 vertical.all? { |stroke| (stroke[:points][0][0] - stroke[:points][1][0]).abs <= 0.001 }
            raise 'Expected two horizontal and two vertical frame strokes'
          end

          half_width = widths.first / 2
          left = vertical.flat_map { |stroke| stroke[:points].map(&:first) }.min - half_width
          right = vertical.flat_map { |stroke| stroke[:points].map(&:first) }.max + half_width
          bottom = horizontal.flat_map { |stroke| stroke[:points].map(&:last) }.min - half_width
          top = horizontal.flat_map { |stroke| stroke[:points].map(&:last) }.max + half_width
          horizontal_x = horizontal.flat_map { |stroke| stroke[:points].map(&:first) }
          vertical_y = vertical.flat_map { |stroke| stroke[:points].map(&:last) }
          unless (horizontal_x.min - left).abs <= 0.001 &&
                 (horizontal_x.max - right).abs <= 0.001 &&
                 (vertical_y.min - bottom - half_width).abs <= 0.001 &&
                 (vertical_y.max - top + half_width).abs <= 0.001
            raise 'Frame stroke endpoints do not form a rectangle'
          end

          box_left, box_bottom, box_right, box_top = page.box(:media).value
          mm_per_point = 25.4 / 72
          {
            left: (left - box_left) * mm_per_point,
            right: (box_right - right) * mm_per_point,
            top: (box_top - top) * mm_per_point,
            bottom: (bottom - box_bottom) * mm_per_point,
            bottom_from_top: (box_top - bottom) * mm_per_point,
            width: (right - left) * mm_per_point,
            height: (top - bottom) * mm_per_point
          }
        end

        page_strokes = pages.map { |page| collect_strokes.call(page) }
        {
          header: measure_frame.call(pages[0], page_strokes[0], [0.75, 0, 0]),
          front: measure_frame.call(pages[0], page_strokes[0], [0, 0, 0.75]),
          continuation: measure_frame.call(pages[1], page_strokes[1], [0, 0.5, 0])
        }
      end
    end
    assert_mm = lambda do |description, expected_mm, &measurement|
      assert description do
        actual_mm = measurement.call(collect_frame_geometry.call(self))
        unless (actual_mm - expected_mm).abs <= 0.01
          fail "Expected #{expected_mm} mm, found #{actual_mm.round(3)} mm"
        end
      end
    end

    assert_mm.call('Header is 5 mm from the top of page 1.', 5.0) { |frames| frames[:header][:top] }
    assert_mm.call('Header is 5 mm from the left of page 1.', 5.0) { |frames| frames[:header][:left] }
    assert_mm.call('Header is 5 mm from the right of page 1.', 5.0) { |frames| frames[:header][:right] }
    assert_mm.call('Header bottom is 20 mm from the top of page 1.', 20.0) do |frames|
      frames[:header][:bottom_from_top]
    end
    assert_mm.call('Header is 138 mm wide.', 138.0) { |frames| frames[:header][:width] }
    assert_mm.call('Header is 15 mm tall.', 15.0) { |frames| frames[:header][:height] }
    assert_mm.call('Front content is 22 mm from the top of page 1.', 22.0) { |frames| frames[:front][:top] }
    assert_mm.call('Front content is 5 mm from the left of page 1.', 5.0) { |frames| frames[:front][:left] }
    assert_mm.call('Front content is 5 mm from the right of page 1.', 5.0) { |frames| frames[:front][:right] }
    assert_mm.call('Front content is 5 mm from the bottom of page 1.', 5.0) { |frames| frames[:front][:bottom] }
    assert_mm.call('Front content is 138 mm wide.', 138.0) { |frames| frames[:front][:width] }
    assert_mm.call('Front content is 78 mm tall.', 78.0) { |frames| frames[:front][:height] }
    assert_mm.call('There is a 2 mm gap between the header and front content.', 2.0) do |frames|
      frames[:front][:top] - frames[:header][:top] - frames[:header][:height]
    end
    assert_mm.call('Continuation is 5 mm from the top of page 2.', 5.0) { |frames| frames[:continuation][:top] }
    assert_mm.call('Continuation is 5 mm from the left of page 2.', 5.0) { |frames| frames[:continuation][:left] }
    assert_mm.call('Continuation is 5 mm from the right of page 2.', 5.0) { |frames| frames[:continuation][:right] }
    assert_mm.call('Continuation is 5 mm from the bottom of page 2.', 5.0) { |frames| frames[:continuation][:bottom] }
    assert_mm.call('Continuation is 138 mm wide.', 138.0) { |frames| frames[:continuation][:width] }
    assert_mm.call('Continuation is 95 mm tall.', 95.0) { |frames| frames[:continuation][:height] }
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
