The IDE is a complete IDE for the Apollo Guidance computer based on the 
Pultorak simulator and assembler. I have integrated them with a nice gui.

The ASM contains agc assembler source code mostly from the Virtual AGC web site. 
I made some corrections.

The vt_DSKY is the virtual keyboard display for the DE0 AGC and uses the Altera
Vitrual JTAG to interface to the board via the USB connection.

The CPMGEN program generates the CPM matrix file that is used in the ng_CPM.v module. 
It is the control matrix for the comptuer.