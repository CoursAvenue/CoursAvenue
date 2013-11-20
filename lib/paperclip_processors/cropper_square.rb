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
      %w(\\( +clone -rotate 90 +clone -mosaic +level-colors white \\) +swap -gravity center -composite)
    end
  end
end
