# Project Description
This project includes various hardware implementation of SIMON cipher using FPGA and a hybrid solution involving encryption in software and decryption in hardware. 

## Abstract
SIMON block cipher offers light weight encryption of 128 bits data, various hardware implementation of it using FPGA and a hybrid solution involving encryption in software and decryption in hardware. We will also discuss the design justifications, limitations and perform resource analysis on a development board with 5CSEMA5F31C6.

## Introduction
SIMON is a lightweight block cipher presented by the NSA in 2013. In recent years due to the popularity
of IoT (Internet of things) devices there is a huge interest in lightweight cryptography. This is due to the need
for security when communicating between “master” and “slave” devices and the constraints due to low
capability processors. Common algorithms such as AES performs well in devices with high processing power
but unfortunately too intensive for IoT devices. When building a network cluster of devices many different
types of cryptography are required.
SIMON is optimized for hardware but still fully operational in software. It requires much less hardware
footprint than other ciphers. Additionally, the encryption process is very similar to the decryption process,
making it possible to use the same hardware to perform both operations.
In this report we will first explain the specification and operation of SIMON cipher. We will then explore some
real-world applications that this cipher would be used due to its unique features. Three designs will then be
explored – optimized for area, optimized for performance and a hybrid solution which encrypts in software
written in embedded C running on Linux and decrypts using FPGA. Each design will be explained, and
justification, waveform and results will be explored. We will then conclude with limitations and further work.

## Simon Cipher
SIMON is specified to have 10 different configurations consisting of different block and key sizes. The
structure is based on a Feistel network consisting of a round function processing data iteratively

## Key Generation
The SIMON cipher uses the master key to generate key words. Depending on the number of key words there
are different versions of the key generation function. However, the bitwise operations (Figure 1 - VHDL
code for bitwise operations in key generation) remain the same for different number of key words. The value
of the constants is listed in (Table 2 - Constants for key generation). Figure 2 - SIMON key generation block
diagram for 128 bits key length shows the operation for generating a new key. The c constant is first XORed
with the LSB of z constant. The result of this is then XORed with key (i+1) where i represents the number of
iterations. Key (i+0) is right shifted 4 bits and 3 bits, and the result of the shifts is XORed with the previous
results. This then forms the new key (I + 2). The operation is very similar for 192 bits key length see Figure 3
- SIMON key generation block diagram for 192 bits key length.

## Sub-folders Structure
- quartus_output_files
This folder contains an .sof file which can be uploaded to the FPGA on the De1-SoC board using the programming tool in 
Quartus.

- quartus_project
This folder contains the project file of Quartus which is used to compile and synthesis VHDL code. To open the project,
launch the .QPF file.

- quartus_resource_usuage
This folder contains 3 .CSV files with resourse and power data.

- questasim_rtl_project
This folder contains the VHDL of the design and questasim project for simulation. A script is created for ease of use. Open .MPF file.
Run script by command "do run.tcl". The relevalant signals and simulation will run for the suitable amount of time.

- questasim_waveform
This folder contains a screenshot of the waveform generated from the questasim project.

- validation_data
This folder contains a spreadsheet of key/data pairs used to validate the VHDL code against the provided C code.

- c_code
This only applies to design 3 - hybrid solution. This contains a .C file which is to be compiled and run on linux on the top of the Cortex A9. This image can be obtained in https://ftp.intel.com/Public/Pub/fpgaup/pub/Teaching_Materials/current/SD_Images/DE1-SoC.zip 