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

![alt text](https://github.com/BrianKoDev/VHDL-Implementation-of-SIMON-128-Block-Cipher/blob/main/diagrams/1.PNG)
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
![alt text](https://github.com/BrianKoDev/VHDL-Implementation-of-SIMON-128-Block-Cipher/blob/main/diagrams/2.PNG)


## Encryption / Decryption (Round Function)
The round function is used for both encryption and decryption. The decryption process is essentially the
reverse of the encryption process, where the keys are reversed, and the left/right word is swapped. Figure 4
- SIMON round function VHDL code shows the bitwise operations performed with the block. The input block
is first split into two words, shift and AND operations are performed on the left word. [9] This result is XORed
with the right word and key. The left and right word is then swapped for the new block. This process is
repeated iteratively for the required rounds.
![alt text](https://github.com/BrianKoDev/VHDL-Implementation-of-SIMON-128-Block-Cipher/blob/main/diagrams/3.PNG)

## Potential real-world applications
As mentioned in the introduction, encryption methods like AES works well in conventional computer systems
but perform poorly in embedded systems. An example of such systems would be a car where wireless sensors
must communicate with the ECU for essential information such as tyre pressure, parking sensors and others.
See Figure 6 - Communication between car sensors and ECU. It would be dangerous to transmit such data
without any encryption due to security reasons.
Another recent advancement is the popularity of IoT devices. IoT devices interact with each other on the
same network, if even one device is compromised, the network may be infected. [10] IoT devices usually
have cheaper processors and are battery powered, making energy consumption and area required important
properties of lightweight cryptography.
The security of an IoT network is key to its success. When implementing security, we must find a balance
between the level of security against power drain and area requirements. We must also consider the area
required for RAM and ROM in non-FPGA implementations.
![alt text](https://github.com/BrianKoDev/VHDL-Implementation-of-SIMON-128-Block-Cipher/blob/main/diagrams/4.PNG)

## Design 1 – Optimized for low area usage
In this design we aim to reduce area usage. This is achieved by only instantiating one subkey generate
component and encryption/decryption component. The component is used iteratively to generate the
required number of subkeys and number of rounds for encryption/decryption see Figure 7 - . Due to the
modular and portable approach of the design see Figure 8 - Hierarchy of VHDL files in design 1,
encryption/decryption uses the same piece of code. The subkey component and encryption/decryption
component is also the same across other designs.
This design supports both 128-bit and 192-bit key length and is configurable at run time. To improve this
design we can perform encryption just a few clock cycles behind subkey generation instead of waiting until
all keys are generated. 
![alt text](https://github.com/BrianKoDev/VHDL-Implementation-of-SIMON-128-Block-Cipher/blob/main/diagrams/5.PNG)

![alt text](https://github.com/BrianKoDev/VHDL-Implementation-of-SIMON-128-Block-Cipher/blob/main/diagrams/6.PNG)
1. Key and Data values are loaded from test bench to registers in hardware in 32-bit segments sequentially. Notice that reset_n is “1” and encryption is “1” to indicate encryption is in progress.
2. Subkeys are generated from the master key. This process uses the subkey generate component iteratively.
3. The data is encrypted using the encryption component iteratively until the required number of rounds are completed.
4. The result of encryption is exported to the test bench via data_word_out in 32-bit segments sequentially.
5. Key and cipher text are loaded from test bench to registers in hardware in 32-bit segments sequentially. Notice that reset_n is “1” and encryption is “0” to indicate decryption is in progress.
6. Subkeys are generated from the master key. This process uses the subkey generate component iteratively.
7. The data is decrypted using the decryption component iteratively until the required number of rounds are completed.
8. The result of decryption is exported to the test bench via data_word_out in 32-bit segments sequentially.
![alt text](https://github.com/BrianKoDev/VHDL-Implementation-of-SIMON-128-Block-Cipher/blob/main/diagrams/7.PNG)
![alt text](https://github.com/BrianKoDev/VHDL-Implementation-of-SIMON-128-Block-Cipher/blob/main/diagrams/8.PNG)

## Design 2 – Optimized for high performance
This design is purely combinational logic based, apart from loading and exporting data due to 32-bit bus width
limitations. All components are generated and data flows through it, making it possible for both subkey
generation and encryption be completed in 1 clock cycle. This design sacrifices area over performance but it
is still sufficient to fit on the FPGA provided by De1-SoC. Due to the large amount of logic data must flow
through, there will be a significant propagation delay. We must choose the clock frequency to prevent
“glitches” from happening. Another issue is that much of the logic is not performing any operations in the
majority of flow time, this can be improved by adding register block in between each component, therefor
multiple data sets can be encrypted/decrypted in a pipeline fashion. 
![alt text](https://github.com/BrianKoDev/VHDL-Implementation-of-SIMON-128-Block-Cipher/blob/main/diagrams/9.PNG)
![alt text](https://github.com/BrianKoDev/VHDL-Implementation-of-SIMON-128-Block-Cipher/blob/main/diagrams/10.PNG)
1. Key is loaded from test bench in 32-bit segments. Note that key_valid is “1” during this period.
2. Once key is loaded into hardware, all sub-keys are generated in the next clock cycle.
3. Data is loaded from test bench in 32-bit segments. Note that data_valid is “1” during this period.
4. Once data is loaded into hardware, all data is encrypted in the next clock cycle.
5. Cipher text is exported to test bench in 32-bit segments.
6. Key is loaded from test bench in 32-bit segments. Note that key_valid is “1” during this period.
7. Once key is loaded into hardware, all sub-keys are generated in the next clock cycle.
8. Cipher text is loaded from test bench in 32-bit segments. Note that data_valid is “1” during this period.
9. Once cipher text is loaded into hardware, all data is decrypted in the next clock cycle.
10. Decrypted data is exported to test bench in 32-bit segments.

## Design 3 – Optimized for hybrid operation (encrypt in software, decrypt in hardware)
This design is optimized for hybrid operation where encryption is performed in software and decryption is
performed in hardware. Note that the components for subkey generation and decryption are different
from design 1 and 2.
![alt text](https://github.com/BrianKoDev/VHDL-Implementation-of-SIMON-128-Block-Cipher/blob/main/diagrams/11.PNG)

## Applications
To demonstrate the capability and validity of the SIMON cipher, 3 applications are created. The C code is
compiled in Linux and running in Cortex-A9 on the De1-SoC board. Figure 17 - C program layout shows the
general flow of the program. Users can choose between different applications ( Figure 18 -
Application (Encrypting String) Figure 19 - Application (Random Number)); the data
is encrypted in software using C. The encrypted data is then sent to the FPGA via the light-weight AXI bus
where it is decrypted.
![alt text](https://github.com/BrianKoDev/VHDL-Implementation-of-SIMON-128-Block-Cipher/blob/main/diagrams/12.PNG)
![alt text](https://github.com/BrianKoDev/VHDL-Implementation-of-SIMON-128-Block-Cipher/blob/main/diagrams/13.PNG)

1. Key is loaded into hardware via LW AXI Bus in 32-bit segments. The values are then stored in registers. Note that when all registers are populated with the
keys, the subkeys are generated in the same clock cycle due to the combinational logic design.
2. Cipher text is loaded into hardware via LW AXI Bus in 32-bit segments. The values are then stored in registers.
3. Note that when all registers are populated with the cipher text, it is decrypted in the same clock cycle. The decrypted data are stored in registers.
4. The test bench can now read the registers populated with the decrypted data.

## Performance
Table 3 - Performance of designs shows the simulation time of the different designs. For design 2 and 3 due
to the combinational logic design all times are 0 ns. It was not possible to measure the time for importing +
exporting from the C programming running on the top of the A9 as the designs operates magnitudes faster
than the C program could measure. Note that in 192-bit for design 1 it takes additional time to
encrypt/decrypt than for 129-bit, this is due to the additional rounds required.
![alt text](https://github.com/BrianKoDev/VHDL-Implementation-of-SIMON-128-Block-Cipher/blob/main/diagrams/14.PNG)

## Area
- ALMs are used for LUT logic, registers and memory
- Combinational ALUT is the design being synthesized into combinational adaptive look-up table. [11]
- Dedicated logic registers are the number of registers used to be implemented with core logic
As expected, design 1 has the lowest area usage due to the iterative design (Figure 21 - Area comparison of
designs). Although similar, design 3 has a slightly smaller area usage due to the removal of encryption
component, but not by much due to the addition of the HPS component.
![alt text](https://github.com/BrianKoDev/VHDL-Implementation-of-SIMON-128-Block-Cipher/blob/main/diagrams/15.PNG)

## Conclusion & Further work
In conclusion, a successful implementation of SIMON cipher has been implemented. We have explored the
various designs to optimize for area or performance. A hybrid solution is presented to encrypt in software
and decrypt in hardware.
There are certain aspects in design 2 that can be used to further reduce the area. Although the
encryption/decryption module is generated from the same code base, it is perhaps possible to create a more
generic module that can be used for both. Effectively reducing 66 components to 33. Further modifications
could be made to allow user to choose between 128-bit key length and 192-bit key length rather than having
two designs.
Design 1 could be improved by performing encryption not after all keys are generated but just a few cycles
after in order to save on time. More research is required but it may be possible to mathematically create a
reverse of key generation algorithm, reducing the decryption time significantly.
In the hybrid solution, it is possible to increase efficiency by encoding multiple numbers in the Fibonacci
sequence in 64 bits rather than padding with zeros. Further work will also be required to encode larger
strings.
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