# Algo

# Step 1: Load the image
# Step 2: Convert image to grayscale
# Step 3: Apply a simple threshold to segment the person (assuming person is darker than background)
# Step 4: Apply a morphological transformation to remove noise
# Step 5: Replace pixels corresponding to the person with background pixels
# Step 6: Save or display the modified image
require 'opencv'

include OpenCV

def make_person_disappear(image_path)
  begin
    # ***********-----------Step 1-----**************
    image = CvMat.load(image_path, CV_LOAD_IMAGE_COLOR)
    
    if image.empty?
      puts "Error: Unable to load image '#{image_path}'"
      return
    end
    
    # ***********-----------Step 2-----**************
    gray_image = image.BGR2GRAY
    
    # ***********-----------Step 3-----*********
    _, thresh = gray_image.threshold(127, 255, CV_THRESH_BINARY_INV)
    
    # ***********-----------Step 4-----*********
    kernel = IplConvKernel.new(5, 5, 2, 2, CV_SHAPE_RECT)
    closing = thresh.close(kernel)
    
    # ***********-----------Step 5-----*********
    result = image.clone
    closing.each_index do |y|
      closing.width.times do |x|
        if closing[y, x] == 255
          result[y, x] = CvScalar.new(0, 0, 0)  # Set to black (background color)
        end
      end
    end
    
    # ***********-----------Step 6-----*********
    result.save_image('output.jpg')
    puts "Person made invisible successfully. Check 'output.jpg'"
    
  rescue => e
    puts "Error: #{e.message}"
  end
end

# Example usage:
image_path = 'input_image.jpg'
make_person_disappear(image_path)
