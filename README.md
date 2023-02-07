# PROFIBUS-DP Driver for Toit
This package supports the Profibus-DP fieldbus protocol. The package allows communication with a passive Profibus-DP enabled device. Certain features are implemented at the moment, such as setting up a slave to achieve the data exchange state. See the [dp.toit](src/dp.toit) and [dp_master.toit](src/dp_master.toit) files to view features and services implemented. The package cannot be used in a multi-master network, as master token sharing has not been implemented yet. 

# Resources
Profibus DP Manual by Max Felser: <a href="https://felser.ch/profibus-manual/index.html" target="_blank">https://felser.ch/profibus-manual/index.html</a>

Introduction to Profibus DP by Acromag: <a href="https://www.acromag.com/wp-content/uploads/2019/06/Acromag_Intro_ProfibusDP_698A.pdf" target="_blank">https://www.acromag.com/wp-content/uploads/2019/06/Acromag_Intro_ProfibusDP_698A.pdf</a> 

Specification: <a href="https://www.profibus.com/download/profibus-standard-dp-specification " target="_blank">https://www.profibus.com/download/profibus-standard-dp-specification</a> 

# Examples
The Profibus-DP driver comes with [one example](examples/dp_example.toit) of how to use the driver for your project. It can be found in the examples folder. *Note*: To use the example you need a ESP32 microcontroller and a transceiver, such as the <a href="https://www.sparkfun.com/products/10124" target="_blank">SparkFun Transceiver Breakout - RS-485</a>, to convert UART serial stream to RS-485.

# Dependencies
- <a href="https://github.com/toitlang/toit" target="_blank">Toit</a> 2.0.0-alpha.39 or later.
- <a href="https://github.com/toitware/toit-rs485" target="_blank">rs485</a> 1.2.0 or later.

# Features and bugs
Please file feature requests and bugs at the [issue tracker][tracker].

[tracker]: https://github.com/Consibio/toit-profibus/issues

# License