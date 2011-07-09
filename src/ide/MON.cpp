//---------------------------------------------------------------------------
/****************************************************************************
 *  MON - AGC MONITOR subsystem
 *
 *  AUTHOR:     John Pultorak
 *  DATE:       9/22/01
 *  FILE:       MON.cpp
 *
 *  NOTES: see header file.
 *
 ****************************************************************************/
//---------------------------------------------------------------------------
#include <vcl.h>
#include <stdlib.h>
#pragma hdrstop

#include "AGCSimUnit1.h"
#include "MonitorUnit1.h"

#include "MON.h"

#include "TPG.h"
#include "MON.h"
#include "SCL.h"
#include "SEQ.h"
#include "INP.h"
#include "OUT.h"
#include "BUS.h"
#include "DSP.h"
#include "ADR.h"
#include "PAR.h"
#include "MBF.h"
#include "MEM.h"
#include "CTR.h"
#include "INT.h"
#include "KBD.h"
#include "CRG.h"
#include "ALU.h"
#include "CPM.h"
#include "ISD.h"
#include "CLK.h"

//---------------------------------------------------------------------------
unsigned MON::PURST=1;	// power up reset; initially high at startup
unsigned MON::RUN=0;	// run/halt switch
unsigned MON::STEP=0;	// single step switch
unsigned MON::INST=1;	// instruction/sequence step select switch
unsigned MON::FCLK=0;	// clock mode

unsigned MON::SA=0;		// "standby allowed" SW; 0=NO (full power), 1=YES (low power)

unsigned MON::SCL_ENAB=1;		// "scaler enabled" SW; 0=NO (scaler halted), 1=YES (scaler running)

//---------------------------------------------------------------------------
void MON::MonitorUpdate(void)
{
	char buf[100];

    MonitorForm1->Memo1->Lines->Clear();
    MonitorForm1->Memo1->Lines->Add("AGC4 SIMULATOR 1.15 -------------------------------");

	sprintf(buf," TP: %-5s  F17:%1d   F13:%1d   F10:%1d   SCL:%06o",
		TPG::tpTypestring[TPG::register_SG.read()], 
		SCL::register_F17.read(), SCL::register_F13.read(), SCL::register_F10.read(),
		SCL::register_SCL.read());
    MonitorForm1->Memo1->Lines->Add(AnsiString(buf));

	sprintf(buf, "    STA:%01o   STB:%01o   BR1:%01o   BR2:%01o   SNI:%01o   CI:%01o   LOOPCTR:%01o",
		SEQ::register_STA.read(), SEQ::register_STB.read(),
		SEQ::register_BR1.read(), SEQ::register_BR2.read(),
		SEQ::register_SNI.read(), ALU::register_CI.read(), SEQ::register_LOOPCTR.read());
    MonitorForm1->Memo1->Lines->Add(AnsiString(buf));

	sprintf(buf, " RPCELL:%05o  INH1:%01o  INH:%01o  UpCELL:%03o  DnCELL:%03o  SQ:%02o  %-6s  %-6s",
		INTR::register_RPCELL.read(), INTR::register_INHINT1.read(), INTR::register_INHINT.read(),
		CTR::register_UpCELL.read(), CTR::register_DnCELL.read(),
		SEQ::register_SQ.read(), SEQ::instructionString[SEQ::register_SQ.read()],
		CPM::subseqString[SEQ::glbl_subseq]);
    MonitorForm1->Memo1->Lines->Add(AnsiString(buf));

	sprintf(buf, "     CP:%s", SEQ::getControlPulses());
    MonitorForm1->Memo1->Lines->Add(AnsiString(buf));

	// For the G register, bit 15 comes from register G15; the other bits (16, 14-1) come
	// from register G.
	sprintf(buf, "      S:  %04o   G:%06o   P:%06o   (r)RUN :%1d  (p)PURST:%1d (F2,F4)FCLK:%1d",
		ADR::register_S.read(),
		(MBF::register_G.read() & 0137777) | (PAR::register_G15.read() << 14),
		PAR::register_P.read(),
		MON::RUN, MON::PURST, MON::FCLK);
    MonitorForm1->Memo1->Lines->Add(AnsiString(buf));

	sprintf(buf, "    RBU:%06o WBU:%06o  P2:%01o        (s)STEP:%1d",
		BUS::glbl_READ_BUS & 0177777, BUS::glbl_WRITE_BUS & 0177777, PAR::register_P2.read(), MON::STEP);
    MonitorForm1->Memo1->Lines->Add(AnsiString(buf));

	char parityAlm = ' ';
	if(PAR::register_PALM.read()) parityAlm = '*';

	sprintf(buf, "      B:%06o           CADR:%06o   (n)INST:%1d      PALM:[%c]",
		ALU::register_B.read(), ADR::getEffectiveAddress(), MON::INST, parityAlm);
    MonitorForm1->Memo1->Lines->Add(AnsiString(buf));

	sprintf(buf, "      X:%06o   Y:%06o   U:%06o   (a)SA  :%1d",
		ALU::register_X.read(), ALU::register_Y.read(), ALU::register_U.read(), MON::SA);
    MonitorForm1->Memo1->Lines->Add(AnsiString(buf));

    MonitorForm1->Memo1->Lines->Add("");
	sprintf(buf, "00    A:%06o   15   BANK:%02o       36  TIME1:%06o   53   OPT Y:%06o",
		CRG::register_A.read(), ADR::register_BNK.read(), MEM::readMemory(036), MEM::readMemory(053));
    MonitorForm1->Memo1->Lines->Add(AnsiString(buf));

	sprintf(buf, "01    Q:%06o   16 RELINT:%6s   37  TIME3:%06o   54  TRKR X:%06o",
		CRG::register_Q.read(),"", MEM::readMemory(037), MEM::readMemory(054));
    MonitorForm1->Memo1->Lines->Add(AnsiString(buf));

	sprintf(buf, "02    Z:%06o   17 INHINT:%6s   40  TIME4:%06o   55  TRKR Y:%06o",
		CRG::register_Z.read(),"", MEM::readMemory(040), MEM::readMemory(055));
    MonitorForm1->Memo1->Lines->Add(AnsiString(buf));

	sprintf(buf, "03   LP:%06o   20    CYR:%06o   41 UPLINK:%06o   56  TRKR Z:%06o",
		CRG::register_LP.read(), MEM::readMemory(020), MEM::readMemory(041), MEM::readMemory(056));
    MonitorForm1->Memo1->Lines->Add(AnsiString(buf));

	sprintf(buf, "04  IN0:%06o   21     SR:%06o   42 OUTCR1:%06o",
		INP::register_IN0.read(), MEM::readMemory(021), MEM::readMemory(042));
    MonitorForm1->Memo1->Lines->Add(AnsiString(buf));

	char progAlm = ' ';
	if(OUTP::register_OUT1.read() & 0400) progAlm = '*';

	char compFail = ' '; // also called 'check fail' and 'oper err'
	if(OUTP::register_OUT1.read() & 0100) compFail = '*';

	char keyRels = ' ';
	if(OUTP::register_OUT1.read() & 020) keyRels = '*';

	char upTl = ' ';
	if(OUTP::register_OUT1.read() & 004) upTl = '*';

	char comp = ' '; // also called comp acty
	if(OUTP::register_OUT1.read() & 001) comp = '*';

	sprintf(buf, "05  IN1:%06o   22    CYL:%06o   43 OUTCR2:%06o    CF:[%c%c]:KR  [%c]:PA",
		INP::register_IN1.read(), MEM::readMemory(022), MEM::readMemory(043),
		compFail, keyRels, progAlm);
    MonitorForm1->Memo1->Lines->Add(AnsiString(buf));

	sprintf(buf, "06  IN2:%06o   23     SL:%06o   44 PIPA X:%06o",
		INP::register_IN2.read(), MEM::readMemory(023), MEM::readMemory(044));
    MonitorForm1->Memo1->Lines->Add(AnsiString(buf));

	sprintf(buf, "07  IN3:%06o   24  ZRUPT:%06o   45 PIPA Y:%06o     A:[%c%c] M:[%c%c]",
		INP::register_IN3.read(), MEM::readMemory(024), MEM::readMemory(045),
		upTl, comp, DSP::MD1, DSP::MD2);
    MonitorForm1->Memo1->Lines->Add(AnsiString(buf));

	char fc = ' '; if(DSP::flash) fc = '*';
	sprintf(buf, "10 OUT0:         25  BRUPT:%06o   46 PIPA Z:%06o     V:[%c%c] N:[%c%c] %c",
		MEM::readMemory(025), MEM::readMemory(046),
		DSP::VD1, DSP::VD2, DSP::ND1, DSP::ND2, fc);
    MonitorForm1->Memo1->Lines->Add(AnsiString(buf));

	sprintf(buf, "11 OUT1:%06o   26  ARUPT:%06o   47  CDU X:%06o    R1:[  %c%c%c%c%c%c ]",
		OUTP::register_OUT1.read(), MEM::readMemory(026), MEM::readMemory(047),
		DSP::R1S, DSP::R1D1, DSP::R1D2, DSP::R1D3, DSP::R1D4, DSP::R1D5);
    MonitorForm1->Memo1->Lines->Add(AnsiString(buf));

	sprintf(buf, "12 OUT2:%06o   27  QRUPT:%06o   50  CDU Y:%06o    R2:[  %c%c%c%c%c%c ]",
		OUTP::register_OUT2.read(), MEM::readMemory(027), MEM::readMemory(050),
		DSP::R2S, DSP::R2D1, DSP::R2D2, DSP::R2D3, DSP::R2D4, DSP::R2D5);
    MonitorForm1->Memo1->Lines->Add(AnsiString(buf));

	sprintf(buf, "13 OUT3:%06o   34  OVCTR:%06o   51  CDU Z:%06o    R3:[  %c%c%c%c%c%c ]",
		OUTP::register_OUT3.read(), MEM::readMemory(034), MEM::readMemory(051),
		DSP::R3S, DSP::R3D1, DSP::R3D2, DSP::R3D3, DSP::R3D4, DSP::R3D5);
    MonitorForm1->Memo1->Lines->Add(AnsiString(buf));

	sprintf(buf, "14 OUT4:%06o   35  TIME2:%06o   52  OPT X:%06o",
		OUTP::register_OUT4.read(), MEM::readMemory(035), MEM::readMemory(052));
    MonitorForm1->Memo1->Lines->Add(AnsiString(buf));
}

//---------------------------------------------------------------------------
void MON::DSKYUpdate(void)
{
    Form1->display[ 0] = ' ';  // Blank
    Form1->display[ 1] = DSP::MD1;
    Form1->display[ 2] = DSP::MD2;
    Form1->display[ 3] = DSP::VD1;
    Form1->display[ 4] = DSP::VD2;
    Form1->display[ 5] = DSP::ND1;
    Form1->display[ 6] = DSP::ND2;
    Form1->display[ 7] = DSP::R1D1;
    Form1->display[ 8] = DSP::R1D2;
    Form1->display[ 9] = DSP::R1D3;
    Form1->display[10] = DSP::R1D4;
    Form1->display[11] = DSP::R1D5;
    Form1->display[12] = DSP::R2D1;
    Form1->display[13] = DSP::R2D2;
    Form1->display[14] = DSP::R2D3;
    Form1->display[15] = DSP::R2D4;
    Form1->display[16] = DSP::R2D5;
    Form1->display[17] = DSP::R3D1;
    Form1->display[18] = DSP::R3D2;
    Form1->display[19] = DSP::R3D3;
    Form1->display[20] = DSP::R3D4;
    Form1->display[21] = DSP::R3D5;

    Form1->display[22] = DSP::R1S;
    Form1->display[23] = DSP::R2S;
    Form1->display[24] = DSP::R3S;
    Form1->UpdateAll();
}

//---------------------------------------------------------------------------
void MON::displayAGC(void)
{
    MonitorUpdate();
    DSKYUpdate();
}

//---------------------------------------------------------------------------

