require "test_helper"
require "a2_printer"

describe A2Printer do
  def sent_bytes
    @test_connection.bytes
  end

  before do
    @test_connection = TestConnection.new
    @printer = A2Printer.new(@test_connection)
  end

  it "can be reset" do
    @printer.reset
    sent_bytes.must_equal [27, 64]
  end

  it "prints a test page" do
    @printer.test_page
    sent_bytes.must_equal [18, 84]
  end

  it "can be flushed" do
    @printer.flush
    sent_bytes.must_equal [12]
  end

  it "can be set offline" do
    @printer.offline
    sent_bytes.must_equal [27, 61, 0]
  end

  it "can be set offline" do
    @printer.online
    sent_bytes.must_equal [27, 61, 1]
  end

  describe "feeding" do
    it "feeds a single line" do
      @printer.feed
      sent_bytes.must_equal [10]
    end

    it "feeds multiple lines" do
      @printer.feed(3)
      sent_bytes.must_equal [10, 10, 10]
    end
  end

  describe "initializing" do
    it "resets the print settings" do
      @printer.begin(100)
      sent_bytes.must_equal [
        27, 64, # reset
        27, 55, # start control parameter command
                7, # dots
                100, # heat time
                50, # heat interval
        18, 35, # start print density command
                (15 << 4) | 15 # print density
      ]
    end

    it "sets the defaults" do
      @printer.expects(:online)
      @printer.expects(:justify).with(:left)
      @printer.expects(:normal)
      @printer.expects(:underline_off)
      @printer.expects(:set_line_height).with(32)
      @printer.set_default
    end
  end

  describe "printing characters" do
    it "sends the characters as bytes" do
      @printer.print("hello")
      sent_bytes.must_equal %w(h e l l o).map(&:ord)
    end

    it "sends a newline character when printing with println" do
      @printer.println("hello")
      sent_bytes.must_equal %w(h e l l o).map(&:ord) + [10]
    end
  end

  describe "printing bitmaps" do
    describe "shorter than 255 rows" do
      before do
        @printer.print_bitmap(width=8, height=8, [1,2,3,4,5,6,7,8])
      end

      it "writes the prefix" do
        sent_bytes[0,2].must_equal [18, 42]
      end

      it "writes the number of rows of the bitmap" do
        sent_bytes[2,1].must_equal [8]
      end

      it "writes the width of the bitmap in bytes" do
        sent_bytes[3,1].must_equal [1]
      end

      it "writes the bitmap data" do
        sent_bytes[4..-1].must_equal [1,2,3,4,5,6,7,8]
      end
    end

    describe "longer than 255 rows" do
      before do
        @printer.print_bitmap(width=8, height=256, [3]*256)
      end

      it "writes the prefix" do
        sent_bytes[0,2].must_equal [18, 42]
      end

      it "writes the number of rows of the first bitmap chunk" do
        sent_bytes[2,1].must_equal [255]
      end

      it "writes the width of the bitmap in bytes" do
        sent_bytes[3,1].must_equal [1]
      end

      it "writes the first chunk of bitmap data" do
        sent_bytes[4,255].must_equal [3] * 255
      end

      it "writes the prefix a second time" do
        sent_bytes[259,2].must_equal [18, 42]
      end

      it "writes the number of rows of the second bitmap chunk" do
        sent_bytes[261,1].must_equal [1]
      end

      it "writes the width of the bitmap in bytes" do
        sent_bytes[262,1].must_equal [1]
      end

      it "writes the second chunk of bitmap data" do
        sent_bytes[263..-1].must_equal [3]
      end
    end

    describe "from an IO object" do
      before do
        data = StringIO.new(([3]*8).map(&:chr).join)
        @printer.print_bitmap(width=8, height=8, data)
      end

      it "writes the prefix" do
        sent_bytes[0,2].must_equal [18, 42]
      end

      it "writes the number of rows of the bitmap" do
        sent_bytes[2,1].must_equal [8]
      end

      it "writes the width of the bitmap in bytes" do
        sent_bytes[3,1].must_equal [1]
      end

      it "writes the bitmap data" do
        sent_bytes[4..-1].must_equal [3,3,3,3,3,3,3,3]
      end
    end

    describe "where width and height aren't given" do
      before do
        data = StringIO.new(([8,0,8,0] + [3]*8).map(&:chr).join)
        @printer.print_bitmap(data)
      end

      it "writes the prefix" do
        sent_bytes[0,2].must_equal [18, 42]
      end

      it "writes the number of rows of the bitmap" do
        sent_bytes[2,1].must_equal [8]
      end

      it "writes the width of the bitmap in bytes" do
        sent_bytes[3,1].must_equal [1]
      end

      it "writes the bitmap data" do
        sent_bytes[4..-1].must_equal [3,3,3,3,3,3,3,3]
      end
    end
  end
end