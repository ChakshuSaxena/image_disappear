require 'mini_magick'

def capture_image_and_process(output_folder)
  begin
    # Step 1: Capture an image from the camera using 'imagesnap' (assuming installed via Homebrew)
    timestamp = Time.now.strftime("%Y%m%d_%H%M%S")
    captured_image_path = File.join(output_folder, "captured_image_#{timestamp}.jpg")
    system("imagesnap -q #{captured_image_path}")

    # Step 2: Load the captured image using MiniMagick
    captured_image = MiniMagick::Image.open(captured_image_path)

    # Step 3: Extract the background from the captured image
    background_image = captured_image.clone
    background_image.negate
    background_image.format("jpg")
    background_image_path = File.join(output_folder, "background_image_#{timestamp}.jpg")
    background_image.write(background_image_path)

    # Step 4: Find cloth-covered area (example: polygon masking)
    mask_image = MiniMagick::Image.open(captured_image_path)
    mask_image.combine_options do |c|
      c.fill("black")
      c.draw("polygon 100,100 300,100 300,300 100,300")  # Replace with actual cloth area coordinates
      c.alpha("transparent")
    end

    # Step 5: Composite background onto clothed area
    result_image = captured_image.composite(background_image) do |c|
      c.compose("Over")
    end

    # Step 6: Apply the mask to only the clothed area
    result_image = result_image.composite(mask_image) do |c|
      c.compose("DstIn")
    end

    # Step 7: Save original captured image and background image
    original_image_path = File.join(output_folder, "original_image_#{timestamp}.jpg")
    captured_image.write(original_image_path)

    # Step 8: Save processed image
    output_file = File.join(output_folder, "processed_image_#{timestamp}.jpg")
    result_image.write(output_file)
    puts "Processed image saved: '#{output_file}'"

  rescue => e
    puts "Error: #{e.message}"
    puts e.backtrace.join("\n")
  end
end

# Example usage:
output_folder = '/Users/chakshusaxena/Downloads'

capture_image_and_process(output_folder)
