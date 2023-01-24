# PROFIBUS-DP Driver for Toit
This package supports the Profibus-DP fieldbus protocol. The package allows communication with a passive Profibus-DP enabled device. Certain features are implemented at the moment, such as setting up a slave to achieve the data exchange state. See the [dp.toit](src/dp.toit) and [dp_master.toit](src/dp_master.toit) files to view features and services implemented. The package cannot be used in a multi-master network, as master token sharing has not been implemented yet. 

# Resources
Profibus DP Manual by Max Felser: https://felser.ch/profibus-manual/index.html

Introduction to Profibus DP by Acromag: https://www.acromag.com/wp-content/uploads/2019/06/Acromag_Intro_ProfibusDP_698A.pdf

Specification: https://www.profibus.com/download/profibus-standard-dp-specification 

# Examples
The Profibus-DP driver comes with [one example](examples/dp_example.toit) of how to use the driver for your project. It can be found in the examples folder. *Note*: To use the example you need a ESP32 microcontroller and a transceiver, such as the [SparkFun Transceiver Breakout - RS-485](https://www.sparkfun.com/products/10124), to convert UART serial stream to RS-485.

# Dependencies
- [Toit](https://github.com/toitlang/toit) 2.0.0-alpha.39 or later.
- [rs485](https://github.com/toitware/toit-rs485) 1.2.0 or later.

# Features and bugs
Please file feature requests and bugs at the [issue tracker][tracker].

[tracker]: https://github.com/Consibio/toit-profibus/issues

# License