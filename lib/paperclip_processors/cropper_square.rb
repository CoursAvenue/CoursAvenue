module Paperclip
  class CropperSquare < Thumbnail
    def transformation_command
      if square_command
        # super returns an array like this: ["-resize", "100x", "-crop", "100x100+0+0", "+repage"]
        square_command + super.join(' ').sub(/ -crop \S+/, '').split(' ')
      else
        super
      end
    end

    def square_command
      %w(-virtual-pixel white -set option:distort:viewport "%[fx:max(w,h)]x%[fx:max(w,h)]-%[fx:max((h-w)/2,0)]-%[fx:max((w-h)/2,0)]" -filter point -distort SRT 0 +repage)
    end
  end
end
