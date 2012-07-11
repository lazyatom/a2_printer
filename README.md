A2 Printer
==========

A small library for working with cheap thermal "A2" printers, such as those available from Adafruit and Sparkfun.

Simple example
------

    serial_connection = SerialConnection.new("/dev/serial")
    printer = A2Printer.new(serial_connection)

    printer.begin
    printer.println("Hello world!")
    printer.feed
    printer.bold_on
    printer.println("BOOM!")
    printer.bold_off


Writing to a file
--------

This can be useful if you're going to use some other mechanism to send the bytes to the printer

    commands_file = File.open("serial_commands.data", "w")
    printer = A2Printer.new(commands_file)
    printer.begin
    printer.println("Hello world!")

    # etc ...

    commands_file.close
