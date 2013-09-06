# Sim Card Gem

Access and control cellphone SIM card functionality via AT commands.

The first pieces of code are based on following sample: http://www.dzone.com/snippets/send-and-receive-sms-text

## Changelog

### 0.0.3

* SignalQuality added.

### 0.0.2

Can only list and delete arrived SMS messages, which is helpful enough when you need [redirect SMS messages](https://gist.github.com/petervojtek/6297229).

## Hardware

You probably need a GSM modem. If you use linux, these few USB modems work for me:

 * [Vodafone MD950](https://github.com/sk-vpohybe/stopa-monitor/wiki/3G-modem-Vodafone-MD950)
 * [Huawei E169](https://github.com/sk-vpohybe/stopa-monitor/wiki/3G-modem-Huawei-E169-E620-E800)

but there are surely many more that work as well.

Use `dmesg` and `lsusb` to determine which `/dev/tty*` file is the device connected to.
You may need to use `usb_modeswitch` if the USB device does not acts as GSM modem by default.
You can check if the device is properly connected by running `screen /dev/ttyUSB0 9600` as sudoer.
Then enter command `AT` and you should see response `OK`.

## Installation

gem is hosted on [rubygems.org](https://rubygems.org/gems/sim_card)

```
gem install sim_card
```

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

## Further Reading

 * [AT Commands Reference Guide](https://www.sparkfun.com/datasheets/Cellular%20Modules/AT_Commands_Reference_Guide_r0.pdf)
