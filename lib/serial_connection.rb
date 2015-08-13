require "serialport"

class SerialConnection
  def initialize(port_str=nil, baud_rate = 19200)
    port_str ||= "/dev/tty.usbserial-FTF8DKJT"
    data_bits = 8
    stop_bits = 1
    parity = SerialPort::NONE
    @serial = SerialPort.new(port_str, baud_rate, data_bits, stop_bits, parity)
    @serial.sync = true
  end

  def putc(byte)
    @serial.putc(byte)
  end
end

