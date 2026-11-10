require 'open3'

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
    user_assert 'The PDF has two pages.'
    user_assert 'Both pages are A6 landscape format (148 mm x 105 mm).'
    user_assert 'All four outer frame edges are 5 mm from the page edges.'
    user_assert 'On page 1, the class-generated title frame measures 138 mm x 15 mm.'
    user_assert 'On page 1, the front content frame measures 138 mm x 78 mm.'
    user_assert 'On page 1, there is a 2 mm gap below the title frame.'
    user_assert 'The page 1 frames and gap use the full 95 mm between the 5 mm top and bottom margins.'
    user_assert 'FRONT CONTENT LINE 01 onward appears in the page 1 front content frame.'
    user_assert 'The page 2 class-generated continuation frame measures 138 mm x 95 mm.'
    user_assert 'The page 2 continuation frame fills the full printable height.'
    user_assert 'Page 2 has no title frame.'
    user_assert 'Page 2 starts with CONTINUATION LINE 10.'
    user_assert 'The page 2 continuation frame is visibly taller than the front content frame.'
    user_assert 'No frame crosses the 5 mm margins.'

    assert 'A6 page and area geometry from border colors' do
      resolution = 144.0
      scale = resolution / 25.4
      colors = {
        red: ->(r, g, b) { r > 100 && g < 10 && b < 10 },
        blue: ->(r, g, b) { b > 100 && g < 10 && r < 10 },
        green: ->(r, g, b) { g > 40 && r < 10 && b < 10 }
      }
      expected_areas = {
        1 => {
          red: [5.0, 143.0, 5.0, 20.0],
          blue: [5.0, 143.0, 22.0, 100.0]
        },
        2 => {
          green: [5.0, 143.0, 5.0, 100.0]
        }
      }

      expected_areas.each do |page, areas|
        ppm, error, status = Open3.capture3(
          'gs', '-q', '-dSAFER', '-dBATCH', '-dNOPAUSE',
          '-sDEVICE=ppmraw', "-r#{resolution.to_i}",
          "-dFirstPage=#{page}", "-dLastPage=#{page}",
          '-sOutputFile=%stdout', pdf_path
        )
        raise "Ghostscript failed for page #{page}: #{error}" unless status.success?

        ppm.force_encoding(Encoding::BINARY)
        header = /\AP6\n(?:#[^\n]*\n)*(\d+)\s+(\d+)\s+255\n/n.match(ppm)
        raise "Could not read rasterized page #{page}" unless header

        width, height = header.captures.map(&:to_i)
        expected_size = [(148.0 * scale).round, (105.0 * scale).round]
        unless (width - expected_size[0]).abs <= 1 &&
               (height - expected_size[1]).abs <= 1
          raise "Page #{page} is #{width}x#{height}px, expected A6 landscape"
        end

        pixels = ppm.byteslice(header.end(0)..).bytes
        raise "Rasterized page #{page} has an invalid pixel count" unless pixels.length == width * height * 3

        areas.each do |name, expected_mm|
          predicate = colors.fetch(name)
          xs = []
          ys = []
          pixels.each_slice(3).with_index do |(r, g, b), index|
            next unless predicate.call(r, g, b)

            xs << index % width
            ys << index / width
          end
          raise "#{name} border not found on page #{page}" if xs.empty?

          actual_px = [xs.min, xs.max, ys.min, ys.max]
          expected_px = expected_mm.map { |mm| mm * scale }
          unless actual_px.zip(expected_px).all? { |actual, expected| (actual - expected).abs <= 2 }
            raise "#{name} border on page #{page} has incorrect geometry"
          end
        end
      end
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
