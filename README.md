# Sim Card Gem

Access and control cellphone SIM card functionality via AT commands

## Hardware

You will need som GSM modem to connect to your computer.
If you use linux, these few USB modems work for me:

 * [Vodafone MD950](https://github.com/sk-vpohybe/stopa-monitor/wiki/3G-modem-Vodafone-MD950)
 * [Huawei E169](https://github.com/sk-vpohybe/stopa-monitor/wiki/3G-modem-Huawei-E169-E620-E800)

but there are surely many more that work as well.

Use `dmesg` and `lsusb` to determine what `/dev/tty*` file is the device connected to.
You may need to use `usb_modeswitch` if the USB device does not behaves as GSM modem by default.
You may check if the device is properly connected by running `screen /dev/ttyUSB0 9600` as sudoer.
Then enter command `AT` and you should see response `OK`.

## Usage

```
require 'serialport'
require 'sim_card'

sim = SimCard::Sim.new :port => '/dev/ttyACM0', :speed => 9600, :sms_center_no => '+421949909909', :pin => '5557'
p sim.sms_messages
first_sms_message = sim.sms_messages[0]
sim.delete_sms_message first_sms_message
sim.close

```