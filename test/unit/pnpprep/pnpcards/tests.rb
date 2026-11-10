require "open3"

testsuite "PnpCards" do
    test "Page Splitting" do
        file "01-page-splitting.tex"
    end

    test "A6 Geometry" do
        file "02-a6-geometry.tex"

        assert "A6 page and area geometry from border colors" do
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
                    "gs", "-q", "-dSAFER", "-dBATCH", "-dNOPAUSE",
                    "-sDEVICE=ppmraw", "-r#{resolution.to_i}",
                    "-dFirstPage=#{page}", "-dLastPage=#{page}",
                    "-sOutputFile=%stdout", pdf_path
                )
                fail "Ghostscript failed for page #{page}: #{error}" unless status.success?

                ppm.force_encoding(Encoding::BINARY)
                header = /\AP6\n(?:#[^\n]*\n)*(\d+)\s+(\d+)\s+255\n/n.match(ppm)
                fail "Could not read rasterized page #{page}" unless header

                width, height = header.captures.map(&:to_i)
                expected_size = [(148.0 * scale).round, (105.0 * scale).round]
                unless (width - expected_size[0]).abs <= 1 &&
                       (height - expected_size[1]).abs <= 1
                    fail "Page #{page} is #{width}x#{height}px, expected A6 landscape"
                end

                pixels = ppm.byteslice(header.end(0)..).bytes
                unless pixels.length == width * height * 3
                    fail "Rasterized page #{page} has an invalid pixel count"
                end

                areas.each do |name, expected_mm|
                    predicate = colors.fetch(name)
                    xs = []
                    ys = []
                    pixels.each_slice(3).with_index do |(r, g, b), index|
                        next unless predicate.call(r, g, b)

                        xs << index % width
                        ys << index / width
                    end
                    fail "#{name} border not found on page #{page}" if xs.empty?

                    actual_px = [xs.min, xs.max, ys.min, ys.max]
                    expected_px = expected_mm.map { |mm| mm * scale }
                    unless actual_px.zip(expected_px).all? { |actual, expected| (actual - expected).abs <= 2 }
                        fail "#{name} border on page #{page} has incorrect geometry"
                    end
                end
            end
        end
    end

    test "Card Environment" do
        file "03-card-environment.tex"
    end

    test "Explicit Page Break" do
        file "04-explicit-page-break.tex"
    end

end