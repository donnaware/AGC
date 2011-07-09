ng_AGC FPGA Version of Apollo Guidance Computer:
---------------------------------------------------------------------
The AGC (Apollo Guidance Computer) was a very early computer, designed
in 1964, it was the first to use Integrated Circuits and the first 
modern embedded processor. When I was growing up, about 11 years old, 
I remember the Apollo program was fascinating to me and I had my eyes
glued to the TV for days on end. The Moon landing made such a lasting
impression on me that it is why I decided to go to engineering school
and get a degree in Electrical Engineering.

Recently I saw a link to John Pultorak’s replica computer he built in 
tribute to the AGC. I was incredibly impressed with his accomplishment.
It is built completely out of discrete TTL IC’s, all in wire wrap, more
advanced than what was available in the ‘60’s but old by today’s 
standards. I think it was a fantastic achievement on his part and I 
applaud what he did. I also think I understand the retro-tech thinking 
on his part of using the oldest technology possible. But another 
retro-tech perspective is to adapt the latest technology to the old 
(or vice versa). I know that there are a number of efforts around 
Virtual AGC’s, that is emulators that run on PC’s. These are also very 
cool. I think a few people have messed around with an FPGA version, but
I did not see a lot of work on that front. Also, I just thought it 
would be a fun and interesting project that would also be a learning 
experience. 

This Git hub repository contains a number of documents which are listed 
below. There is a project description file under doc.


Directory tree:
---------------------------------------------------------------------
doc			Documents
design			Design and diagram files
rtl			verilog code
rtl\de0\agc		The Terasic DE0 version
rtl\de0\modules		The DE0 version modules
rtl\ng\agc		ng_AGC Dedicated PCB version
rtl\ng\modules		ng_AGC Dedicated PCB version modules
rtl\ng\dsky		ng_DSKY Dedicated PCB with LCD
src			source code files
src\ide			Complete IDE for the Block I (Borland C++)
src\vt_dsky		Virtual DSKY for testing 
src\asm\agc		Colussus code
src\asm\teco		Test and Check out code
pcb			Printed circuit board and schematic files
pcb\agc			PCB and schematics for ng_AGC
pcd\dsky                DSKY PCB and schematics

Verilog module list:


File		Module Description
---------------------------------------------------------------------
agc.bdf		AGC Top Level Module, BDF
ng_MON.v        Monitor Module,       Verilog
ng_CLG.v        Clock Generation,     Verilog
ng_INP.v        Input Module,         Verilog
ng_DSP.v        Display Module,       Verilog
ng_OUT.v        Output Module,        Verilog
ng_SEQ.v        Sequencer Module,     Verilog
ng_SUB.v        Sub-sequence decoder, Verilog
ng_CPM.v        Code Pulse Matrix,    Verilog
ng_ADR.v        Address decoder,      Verilog
ng_MEB.v        Memory and Buffer,    Verilog
ng_CTR.v        Counter Module,       Verilog
ng_INT.v        Interrupt handler,    Verilog
ng_CRG.v        Central Registers,    Verilog
ng_ALU.v        Arithmetic Logic Unit,Verilog
ng_PRM.v        Priority Mux Bus,     Verilog

