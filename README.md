# Olympus_demo
"Olympus: Reaching Memory-Optimality on DNN Processors" [under review]

This is the demo DNN processor system implemented on Xilinx Zynq-7100 to demonstrate the effectiveness of Olympus on the real DNN accelerators.

The system configurations are: the RFs is 64B/PE; the input/output global buffer size is 256KB; the weight buffer size is 256KB; the PE-array is 7x32; the dataflow is Wo|Co (map the output width and output channel to the row and column of PE-array respectively); and the arithmetic unit is 8-bit fixed-point. The system is able to operate at 90 MHz.

## Getting Started Guide ##
1. First, you need to prepare a SD card with a capacity of at least 2GB.
2. Run mksdboot.sh, which requires the sudo permission. In this script, we split the SD card into the *boot* and *rootfs* partitions and format them, and the corresponding images are loaded into these two partitions.
```
sudo ./mksdboot.sh
```
3. Now, you can boot your Xilinx Zynq-7100 using the SD card. The user name and password are:
```
stretch-armhf login: osrc
Password: root
```
4. Switch to root user.
```
sudo -s
Password: root
```
5. Run the models on the DNN processor by the instructions.
```
cd /home/osrc/demo
./main olympus/squeezenet/kyp.ini
```
If you have any questions, please contact us. 

Email: caixuyi20b@ict.ac.cn.
