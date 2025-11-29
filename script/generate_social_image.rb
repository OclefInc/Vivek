require 'vips'

input_path = Rails.root.join("app/assets/images/favi-red.png")
output_path = Rails.root.join("app/assets/images/social_share.png")

puts "Processing #{input_path}..."

# Load image
im = Vips::Image.new_from_file(input_path.to_s)

# Flatten against white background to remove transparency
# This ensures the final image is a solid card (no checkerboard/transparency)
if im.has_alpha?
  im = im.flatten(background: [255, 255, 255])
end

# Target dimensions
target_width = 520
target_height = 270

# Calculate position to center
x = (target_width - im.width) / 2
y = (target_height - im.height) / 2

# Embed the image into the center of the new canvas
# Since we flattened it, it's now 3 bands (RGB), so background is [255, 255, 255]
out = im.embed(x, y, target_width, target_height, extend: :background, background: [255, 255, 255])

out.write_to_file(output_path.to_s)
puts "Success! Created #{output_path} (#{target_width}x#{target_height})"
