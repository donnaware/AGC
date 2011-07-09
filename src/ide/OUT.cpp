//---------------------------------------------------------------------------
/****************************************************************************
 *  OUT - OUTPUT REGISTER subsystem
 *
 *  AUTHOR:     John Pultorak
 *  DATE:       9/22/01
 *  FILE:       OUT.cpp
 *
 *  NOTES: see header file.
 *
 ***************************************************************************/
//---------------------------------------------------------------------------
#include <vcl.h>
#include <stdlib.h>
#pragma hdrstop

#include "OUT.h"
#include "SEQ.h"
#include "BUS.h"
#include "DSP.h"
#include "ADR.h"
#include "PAR.h"

regOut1 OUTP::register_OUT1;	// output register 1
regOut2 OUTP::register_OUT2;	// output register 2
regOut3 OUTP::register_OUT3;	// output register 3
regOut4 OUTP::register_OUT4;	// output register 4

// Writing to OUT0 loads the selected DSKY display register.

void OUTP::execWP_GENRST()
{
	DSP::clearOut0();

	register_OUT1.write(0);
	register_OUT2.write(0);
}

void OUTP::execWP_WA10()
{
	DSP::decodeRelayWord(BUS::glbl_WRITE_BUS); 
}

void OUTP::execRP_RA11()
{
	BUS::glbl_READ_BUS = register_OUT1.read();
}

void OUTP::execWP_WA11()
{
	register_OUT1.write(BUS::glbl_WRITE_BUS);
}

void OUTP::execRP_RA12()
{
	BUS::glbl_READ_BUS = register_OUT2.read();
}

void OUTP::execWP_WA12()
{
	register_OUT2.write(BUS::glbl_WRITE_BUS);
}

void OUTP::execRP_RA13()
{
	BUS::glbl_READ_BUS = register_OUT3.read();
}

void OUTP::execWP_WA13()
{
	register_OUT3.write(BUS::glbl_WRITE_BUS);	
}

void OUTP::execRP_RA14()
{
	BUS::glbl_READ_BUS = register_OUT4.read();
}

void OUTP::execWP_WA14()
{
	register_OUT4.write(BUS::glbl_WRITE_BUS);
}
//---------------------------------------------------------------------------



