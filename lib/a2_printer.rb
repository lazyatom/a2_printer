require "serial_connection"

class A2Printer
  def initialize(connection)
    @connection = connection
    @print_mode = 0
  end

  def test_page
    write_bytes(18, 84)
  end

  def begin(heat_time=150)
    reset()

    heat_interval = 50 # 2 is default from page 23 of datasheet. Controls speed of printing and darkness
    print_density = 15 # Not sure what the default is. Testing shows the max helps darken text. From page 23.
    print_break_time = 15 # Not sure what the default is. Testing shows the max helps darken text. From page 23.

    write_bytes(27, 55)
    write_bytes(7) # Default 64 dots = 8*('7'+1)
    write_bytes(heat_time) # Default 80 or 800us
    write_bytes(heat_interval) # Default 2 or 20us

    # Modify the print density and timeout
    write_bytes(18, 35)
    print_setting = (print_density<<4) | print_break_time
    write_bytes(print_setting) # Combination of print_density and print_break_time
  end

  # reset printer
  def reset
    write_bytes(27, 64)
  end

  # reset formatting
  def set_default
    online
    normal
    underline_off
    justify(:left)
    set_line_height(32)
    set_barcode_height(50)
  end

  # Feeds by the specified number of lines
  def feed(lines=1)
    # The datasheet claims sending bytes 27, 100, <x> will work
    # but it feeds much much more.
    lines.times { write(10) }
  end

  # Feeds by the specified number of rows of pixels
  def feed_rows(rows)
    write_bytes(27, 74, rows)
  end

  def flush
    write_bytes(12)
  end

  def test_page
    write_bytes(18, 84)
  end

  def print(string)
    string.bytes { |b| write(b) }
  end

  def println(string)
    print(string + "\n")
  end

  def write(c)
    return if (c == 0x13)
    write_bytes(c)
  end

  def write_bytes(*bytes)
    bytes.each { |b| @connection.putc(b) }
  end

  # Character commands

  INVERSE_MASK = (1 << 1)
  UPDOWN_MASK = (1 << 2)
  BOLD_MASK = (1 << 3)
  DOUBLE_HEIGHT_MASK = (1 << 4)
  DOUBLE_WIDTH_MASK = (1 << 5)
  STRIKE_MASK = (1 << 6)

  def set_print_mode(mask)
    @print_mode |= mask;
    write_print_mode
  end

  def unset_print_mode(mask)
    @print_mode &= ~mask;
    write_print_mode
  end

  def write_print_mode
    write_bytes(27, 33, @print_mode)
  end

  # This will reset bold, inverse, strikeout, upside down and font size
  # It does not reset underline, justification or line height
  def normal
    @print_mode = 0
    write_print_mode
  end

  def inverse_on
    set_print_mode(INVERSE_MASK)
  end

  def inverse_off
    unset_print_mode(INVERSE_MASK)
  end

  def upside_down_on
    set_print_mode(UPDOWN_MASK);
  end

  def upside_down_off
    unset_print_mode(UPDOWN_MASK);
  end

  def double_height_on
    set_print_mode(DOUBLE_HEIGHT_MASK)
  end

  def double_height_off
    unset_print_mode(DOUBLE_HEIGHT_MASK)
  end

  def double_width_on
    set_print_mode(DOUBLE_WIDTH_MASK)
  end

  def double_width_off
    unset_print_mode(DOUBLE_WIDTH_MASK)
  end

  def strike_on
    set_print_mode(STRIKE_MASK)
  end

  def strike_off
    unset_print_mode(STRIKE_MASK)
  end

  def bold_on
    set_print_mode(BOLD_MASK)
  end

  def bold_off
    unset_print_mode(BOLD_MASK)
  end

  def set_size(size)
    byte = case size
    when :small
      0
    when :medium
      10
    when :large
      25
    end

    write_bytes(29, 33, byte, 10)
  end

  # Underlines of different weights can be produced:
  # 0 - no underline
  # 1 - normal underline
  # 2 - thick underline
  def underline_on(weight=1)
    write_bytes(27, 45, weight)
  end

  def underline_off
    underline_on(0)
  end

  def justify(position)
    byte = case position
    when :left
      0
    when :center
      1
    when :right
      2
    end

    write_bytes(0x1B, 0x61, byte)
  end

  # Bitmaps

  class Bitmap
    attr_reader :width, :height

    def initialize(width_or_source, height=nil, source=nil)
      if height.nil? && source.nil?
        set_source(width_or_source)
        extract_width_and_height_from_data
      else
        set_source(source)
        @width = width_or_source
        @height = height
      end
    end

    def each_block
      row_start = 0
      width_in_bytes = width / 8
      while row_start < height do
        chunk_height = ((height - row_start) > 255) ? 255 : (height - row_start)
        bytes = (0...(width_in_bytes * chunk_height)).map { @data.getbyte }
        yield width_in_bytes, chunk_height, bytes
        row_start += 255
      end
    end

    private

    def set_source(source)
      if source.respond_to?(:getbyte)
        @data = source
      else
        @data = StringIO.new(source.map(&:chr).join)
      end
    end

    def extract_width_and_height_from_data
      tmp = @data.getbyte
      @width = (@data.getbyte << 8) + tmp
      tmp = @data.getbyte
      @height = (@data.getbyte << 8) + tmp
    end
  end

  def print_bitmap(*args)
    bitmap = Bitmap.new(*args)
    return if (bitmap.width > 384) # maximum width of the printer
    bitmap.each_block do |w, h, bytes|
      write_bytes(18, 42)
      write_bytes(h, w)
      write_bytes(*bytes)
    end
  end

  # def print_bitmap(stream)
  #   tmp = stream.getbyte
  #   width = (stream.getbyte << 8) + tmp
  #
  #   tmp = stream.getbyte
  #   height = (stream.getbyte << 8) + tmp
  #
  #   print_bitmap(width, height, stream)
  # end

  # Barcodes

  def set_barcode_height(val)
    # default is 50
    write_bytes(29, 104, val)
  end

  UPC_A   = 0
  UPC_E   = 1
  EAN13   = 2
  EAN8    = 3
  CODE39  = 4
  I25     = 5
  CODEBAR = 6
  CODE93  = 7
  CODE128 = 8
  CODE11  = 9
  MSI     = 10

  def print_barcode(text, type)
    write_bytes(29, 107, type) # set the type first
    text.bytes { |b| write(b) }
    write(0) # Terminator
  end

  # Take the printer offline. Print commands sent after this will be
  # ignored until `online` is called
  def offline
    write_bytes(27, 61, 0)
  end

  # Take the printer back online. Subsequent print commands will be
  # obeyed.
  def online
    write_bytes(27, 61, 1)
  end

  # Put the printer into a low-energy state immediately
  def sleep
    sleep_after(0)
  end

  # Put the printer into a low-energy state after the given number
  # of seconds
  def sleep_after(seconds)
    write_bytes(27, 56, seconds)
  end

  # Wake the printer from a low-energy state. This command will wait
  # for 50ms (as directed by the datasheet) before allowing further
  # commands to be send.
  def wake
    write_bytes(255)
    # delay(50) # ?
  end

  # ==== not working? ====
  def tab
    write(9)
  end

  def set_char_spacing(spacing)
    write_bytes(27, 32, 0, 10)
  end

  def set_line_height(val=32)
    write_bytes(27, 51, val) # default is 32
  end
end