//---------------------------------------------------------------------------
#include <vcl.h>
#pragma hdrstop
#include "AGCSimUnit1.h"
#include "MonitorUnit1.h"
#include "PromptUnit1.h"
#include "ShowSourceUnit1.h"
#include "About.h"
//---------------------------------------------------------------------------
#include "reg.h"
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
#pragma package(smart_init)
#pragma resource "*.dfm"
extern bool dskyChanged;
TForm1 *Form1;
//---------------------------------------------------------------------------
__fastcall TForm1::TForm1(TComponent* Owner) : TForm(Owner)
{
    breakpointEnab = false;
    breakpoint = 0;
    watchEnab = false;
    watchAddr = 0;
    oldWatchValue = 0;
}
//---------------------------------------------------------------------------
void __fastcall TForm1::FormCreate(TObject *Sender)
{
	singleClock = false;
    Application->OnIdle = IdleEventHandler;
}
//---------------------------------------------------------------------------
void __fastcall TForm1::FormShow(TObject *Sender)
{
	genAGCStates();
	MON::displayAGC();

    DisplayPanel->Color = clBlack;

    MonitorForm1->Show();
    Show();
}
//---------------------------------------------------------------------------
void __fastcall TForm1::ExitButton1Click(TObject *Sender)
{
    Close();
}
//---------------------------------------------------------------------------
void __fastcall TForm1::HelpButton1Click(TObject *Sender)
{
    Application->HelpFile = ExtractFilePath(Application->ExeName) + "ngAGC.hlp";
    Application->HelpCommand(HELP_CONTENTS, 0);
}
//---------------------------------------------------------------------------
void __fastcall TForm1::AboutButton1Click(TObject *Sender)
{
    AboutBox->ShowModal();
}
//---------------------------------------------------------------------------
//  Segments:
//    1
//    -
//  2|7|6
//    -
//  3| |5
//    -         Panel5
//    4
//---------------------------------------------------------------------------
TColor segtable[11][7] = {
//   Segment1  Segment2  Segment3  Segment4  Segment5  Segment6  Segment7
    {COLOR_ON, COLOR_ON, COLOR_ON, COLOR_ON, COLOR_ON, COLOR_ON, COLOR_OFF}, // 0
    {COLOR_OFF,COLOR_OFF,COLOR_OFF,COLOR_OFF,COLOR_ON, COLOR_ON, COLOR_OFF}, // 1
    {COLOR_ON, COLOR_OFF,COLOR_ON ,COLOR_ON, COLOR_OFF,COLOR_ON, COLOR_ON }, // 2
    {COLOR_ON, COLOR_OFF,COLOR_OFF,COLOR_ON, COLOR_ON ,COLOR_ON, COLOR_ON }, // 3
    {COLOR_OFF,COLOR_ON, COLOR_OFF,COLOR_OFF,COLOR_ON, COLOR_ON, COLOR_ON }, // 4
    {COLOR_ON, COLOR_ON, COLOR_OFF,COLOR_ON, COLOR_ON, COLOR_OFF,COLOR_ON }, // 5
    {COLOR_ON, COLOR_ON, COLOR_ON, COLOR_ON, COLOR_ON, COLOR_OFF,COLOR_ON }, // 6
    {COLOR_ON, COLOR_OFF,COLOR_OFF,COLOR_OFF,COLOR_ON, COLOR_ON, COLOR_OFF}, // 7
    {COLOR_ON, COLOR_ON, COLOR_ON, COLOR_ON, COLOR_ON, COLOR_ON, COLOR_ON }, // 8
    {COLOR_ON, COLOR_ON, COLOR_OFF,COLOR_OFF,COLOR_ON, COLOR_ON, COLOR_ON }, // 9
    {COLOR_OFF,COLOR_OFF,COLOR_OFF,COLOR_OFF,COLOR_OFF,COLOR_OFF,COLOR_OFF}  // Blank
};
//---------------------------------------------------------------------------
TPoint seg[11][9] ={
 {Point( 8, 3),Point( 8, 5),Point(11, 8),Point(28, 8),Point(31, 5),Point(31, 3),Point(29, 1),Point(10, 1),Point( 9, 3)},
 {Point( 5, 6),Point( 2, 9),Point( 2,21),Point( 5,24),Point( 7,24),Point(10,21),Point(10, 9),Point( 7, 6),Point( 6, 7)},
 {Point( 5,26),Point( 2,29),Point( 2,40),Point( 5,43),Point( 8,43),Point(10,41),Point(10,29),Point( 7,26),Point( 6,27)},
 {Point( 9,46),Point(11,48),Point(28,48),Point(30,46),Point(30,44),Point(27,41),Point(12,41),Point( 9,44),Point(10,46)},
 {Point(31,43),Point(34,43),Point(37,40),Point(37,29),Point(34,26),Point(32,26),Point(29,29),Point(29,41),Point(33,42)},
 {Point(32,24),Point(34,24),Point(37,21),Point(37, 9),Point(34, 6),Point(32, 6),Point(29, 9),Point(29,21),Point(33,23)},
 {Point( 9,26),Point(11,28),Point(28,28),Point(30,26),Point(30,24),Point(27,21),Point(12,21),Point( 9,24),Point(10,25)},
 {Point( 3,22),Point( 1,24),Point( 1,25),Point( 3,27),Point(16,27),Point(18,25),Point(18,24),Point(16,22),Point( 3,25)},
 {Point( 9,13),Point( 7,15),Point( 7,20),Point(12,20),Point(12,15),Point(10,13),Point( 9,13),Point( 7,15),Point( 9,15)},
 {Point( 9,36),Point(10,36),Point(12,34),Point(12,29),Point( 7,29),Point( 7,34),Point( 9,36),Point(10,36),Point( 9,33)}
};
//---------------------------------------------------------------------------
int __fastcall TForm1::GetSegIndex(char value)
{
    int inx;
    if(value >= '0' && value <= '9') inx = value - '0'; // convert to index
    else                             inx = 10;         // show all segments blank
    return(inx);
}
//---------------------------------------------------------------------------
void __fastcall TForm1::PaintSegment(TPaintBox *pb, int segno, TColor segcol)
{
    pb->Canvas->Pen->Width   = 1;
    pb->Canvas->Pen->Style   = psSolid;
    pb->Canvas->Pen->Color   = segcol;
    pb->Canvas->Brush->Color = segcol;
    pb->Canvas->Polygon(seg[segno],7); pb->Canvas->FloodFill(seg[segno][8].x,seg[segno][8].y,segcol,fsBorder);
}
//---------------------------------------------------------------------------
void __fastcall TForm1::PaintBox1Paint(TObject *Sender)
{
    TPaintBox *pb = (TPaintBox *)Sender;
    pb->Canvas->Brush->Style = bsSolid;
    pb->Canvas->Brush->Color = clBlack;
    pb->Canvas->FillRect(Rect(0,0,pb->Width,pb->Height));

    if(pb->Tag < 22) {
        int si = GetSegIndex(display[pb->Tag]);
        for(int i = 0; i < 7; i++) {
            PaintSegment(pb, i, segtable[si][i]);
        }
    }
    else {
        int si;
        if(display[pb->Tag] == '+') {
            PaintSegment(pb, 7, COLOR_ON);
            PaintSegment(pb, 8, COLOR_ON);
            PaintSegment(pb, 9, COLOR_ON);
        }
        else
        if(display[pb->Tag] == '-') {
            PaintSegment(pb, 7, COLOR_ON );
            PaintSegment(pb, 8, COLOR_OFF);
            PaintSegment(pb, 9, COLOR_OFF);
        }
        else {
            PaintSegment(pb, 7, COLOR_OFF);
            PaintSegment(pb, 8, COLOR_OFF);
            PaintSegment(pb, 9, COLOR_OFF);
        }
    }
}
//---------------------------------------------------------------------------
void __fastcall TForm1::UpdateAll(void)
{
    for(int i = 0; i < DisplayPanel->ControlCount; i++) {
        DisplayPanel->Controls[i]->Repaint();
    }
}
//---------------------------------------------------------------------------
void __fastcall TForm1::LampTest(TColor lampstate)
{
    LAMP_UPLINKACTY->Color = lampstate;
    LAMP_TEMP      ->Color = lampstate;
    LAMP_NOATT     ->Color = lampstate;
    LAMP_GIMBALLOCK->Color = lampstate;
    LAMP_KEYREL    ->Color = lampstate;
    LAMP_RESTART   ->Color = lampstate;
    LAMP_OPPERR    ->Color = lampstate;
    LAMP_TRACKER   ->Color = lampstate;
    LAMP_ALT       ->Color = lampstate;
    LAMP_VEL       ->Color = lampstate;
    LAMP_BLANK1    ->Color = lampstate;
    LAMP_BLANK2    ->Color = lampstate;
    LAMP_COMPACTY  ->Color = lampstate;
}
//---------------------------------------------------------------------------
void __fastcall TForm1::LampTestButton1MouseDown(TObject *Sender, TMouseButton Button, TShiftState Shift, int X, int Y)
{
    LampTest(clRed);
}
//---------------------------------------------------------------------------
void __fastcall TForm1::LampTestButton1MouseUp(TObject *Sender, TMouseButton Button, TShiftState Shift, int X, int Y)
{
    LampTest(clGray);
}
//---------------------------------------------------------------------------
void __fastcall TForm1::ShowMonitorButton1Click(TObject *Sender)
{
    if(MonitorForm1->Visible) {
        ShowMonitorButton1->Caption = "Show Monitor";
        MonitorForm1->Hide();
    }
    else {
        ShowMonitorButton1->Caption = "Hide Monitor";
        MonitorForm1->Show();
    }
}
//---------------------------------------------------------------------------
void __fastcall TForm1::ShowDebuggerButton1Click(TObject *Sender)
{
    if(DebuggerPanel1->Visible) {
        ShowDebuggerButton1->Caption = "Show Debugger";
        DebuggerPanel1->Hide();
        Width = DebuggerPanel1->Left + 8;
    }
    else {
        ShowDebuggerButton1->Caption = "Hide Debugger";
        DebuggerPanel1->Show();
        Width = DebuggerPanel1->Left + DebuggerPanel1->Width + 10;
    }

}
//---------------------------------------------------------------------------
void __fastcall TForm1::DSKY_Button_0Click(TObject *Sender)
{
    dskey = (char)((TButton *)Sender)->Tag;
    switch(dskey) {
		case '0': KBD::keypress(KEYIN_0);           break;
		case '1': KBD::keypress(KEYIN_1);           break;
		case '2': KBD::keypress(KEYIN_2);           break;
		case '3': KBD::keypress(KEYIN_3);           break;
		case '4': KBD::keypress(KEYIN_4);           break;
		case '5': KBD::keypress(KEYIN_5);           break;
		case '6': KBD::keypress(KEYIN_6);           break;
		case '7': KBD::keypress(KEYIN_7);           break;
		case '8': KBD::keypress(KEYIN_8);           break;
		case '9': KBD::keypress(KEYIN_9);           break;
		case '+': KBD::keypress(KEYIN_PLUS);        break;
		case '-': KBD::keypress(KEYIN_MINUS);       break;
		case '.': KBD::keypress(KEYIN_CLEAR);       break;
		case '/': KBD::keypress(KEYIN_VERB);        break;
		case '*': KBD::keypress(KEYIN_NOUN);        break;
		case 'g': KBD::keypress(KEYIN_KEY_RELEASE); break;
		case 'h': KBD::keypress(KEYIN_ERROR_RESET); break;
		case 'j': KBD::keypress(KEYIN_ENTER);       break;
    }
}
//---------------------------------------------------------------------------
// CONTROL LOGIC
//---------------------------------------------------------------------------
void __fastcall TForm1::genAGCStates(void)
{
	// 1) Decode the current instruction subsequence (glbl_subseq).
	// 2) Build a list of control pulses for this state.
	CPM::controlPulseMatrix();

	// 3) Execute the control pulses for this state. In the real AGC, these occur
	// simultaneously. Since we can't achieve that here, we break it down into the
	// following steps:
	// Most operations involve data transfers--usually reading data from
	// a register onto a bus and then writing that data into another register. To
	// approximate this, we first iterate through all registers to perform
	// the 'read' operation--this transfers data from register to bus.
	// Then we again iterate through the registers to do 'write' operations,
	// which move data from the bus back into the register.
	BUS::glbl_READ_BUS	= 0;	// clear bus; necessary because words are logical OR'ed onto the bus.
    MEM::MEM_DATA_BUS   = 0;	// clear data lines: memory bits 15-1
    MEM::MEM_PARITY_BUS = 0;	// parity line: memory bit 16

	// Now start executing the pulses:
	// First, read register outputs onto the bus or anywhere else.
	int i;
	for(i=0; i<MAXPULSES && SEQ::glbl_cp[i] != NO_PULSE; i++) {
		CLK::doexecR(SEQ::glbl_cp[i]);
	}

	// Next, execute ALU read pulses. See comments in ALU .C file
	ALU::glbl_BUS = 0;
	for(i=0; i<MAXPULSES && SEQ::glbl_cp[i] != NO_PULSE; i++) {
		CLK::doexecR_ALU(SEQ::glbl_cp[i]);
	}

	BUS::glbl_WRITE_BUS = BUS::glbl_READ_BUS; // in case nothing is logically OR'ed below;
	for(i=0; i<MAXPULSES && SEQ::glbl_cp[i] != NO_PULSE; i++) {
		CLK::doexecR_ALU_OR(SEQ::glbl_cp[i]);
	}

	// Now, write the bus and any other signals into the register inputs.
	for(i=0; i<MAXPULSES && SEQ::glbl_cp[i] != NO_PULSE; i++) {
		CLK::doexecW(SEQ::glbl_cp[i]);
	}

	// Always execute these pulses.
	SCL::doexecWP_SCL();
	SCL::doexecWP_F17();
	SCL::doexecWP_F13();
	SCL::doexecWP_F10();
	TPG::doexecWP_TPG();
}
//---------------------------------------------------------------------------
// contains prefix for source filename; i.e.: the portion
// of the filename before .obj or .lst
//---------------------------------------------------------------------------
char* __fastcall TForm1::getCommand(char* prompt)
{
    PromptForm1->Caption = " " + AnsiString(prompt);
	PromptForm1->ShowModal();
    strcpy(cmdprompt, PromptForm1->Edit1->Text.c_str());
    return(cmdprompt);
}
//---------------------------------------------------------------------------
void __fastcall TForm1::toggleBreakpoint(void)
{
	if(!breakpointEnab) {
		char b[80];
		strcpy(b, getCommand("Set breakpoint: -- enter 14-bit CADR (octal): "));
		breakpoint = strtol(b,0,8);
		breakpointEnab = true;
	}
	else {
        MonitorForm1->Memo2->Lines->Add("Clearing breakpoint.");
		breakpointEnab = false;
	}
}
//---------------------------------------------------------------------------
void __fastcall TForm1::toggleWatch(void)
{
	if(!watchEnab) {
		char b[80];
		strcpy(b, getCommand("Set watch: -- enter 14-bit CADR (octal): "));
		watchAddr = strtol(b,0,8);
		watchEnab = true;
		oldWatchValue = MEM::readMemory(watchAddr);
		char buf[100];
		sprintf(buf, "%06o:  %06o", watchAddr, oldWatchValue);
        MonitorForm1->Memo2->Lines->Add(buf);
	}
	else {
		MonitorForm1->Memo2->Lines->Add("Clearing watch.");
		watchEnab = false;
	}
}
//---------------------------------------------------------------------------
void __fastcall TForm1::incrCntr(void)
{
	char cntrname[80];
	strcpy(cntrname, getCommand("Increment counter: -- enter pcell (0-19): "));
	int pc = atoi(cntrname);
	CTR::pcUp[pc] = 1;
}
//---------------------------------------------------------------------------
void __fastcall TForm1::decrCntr(void)
{
	char cntrname[80];
	strcpy(cntrname, getCommand("Decrement counter: -- enter pcell (0-19): "));
	int pc = atoi(cntrname);
	CTR::pcDn[pc] = 1;
}
//---------------------------------------------------------------------------
void __fastcall TForm1::interrupt(void)
{
	char iname[80];
	strcpy(iname, getCommand("Interrupt: -- enter priority (1-5): "));
	int i = atoi(iname) - 1;
	INTR::rupt[i] = 1;
}
//---------------------------------------------------------------------------
// Write the entire contents of fixed and
// eraseable memory to the specified file.
// Does not write the registers
//---------------------------------------------------------------------------
void __fastcall TForm1::saveMemory(char* filename)
{
	FILE* fp = fopen(filename, "w");
	if(!fp) {
		ShowMessage("*** ERROR: fopen failed:");
		return;
	}
	char buf[100];
	for(unsigned addr=020; addr<=031777; addr++) {
		sprintf(buf, "%06o %06o\n", addr, MEM::readMemory(addr));
		fputs(buf, fp);
	}
	fclose(fp);
}
//---------------------------------------------------------------------------
void __fastcall TForm1::examineMemory(void)
{
	char theAddress[20];
	strcpy(theAddress, getCommand("Examine Memory -- enter address (octal): "));

	unsigned address = strtol(theAddress, 0, 8);
	char buf[100];
	for(unsigned i=address; i<address+23; i++) {
		sprintf(buf, "%06o:  %06o", i, MEM::readMemory(i));
		MonitorForm1->Memo2->Lines->Add(AnsiString(buf));
	}
}
//---------------------------------------------------------------------------
// Returns true if time (s) elapsed since last time it returned true; does not block
// search for "Time Management"
//---------------------------------------------------------------------------
bool __fastcall TForm1::checkElapsedTime(time_t s)
{
	if(!s) return true;

	static clock_t start = clock();
	clock_t finish = clock();

	double duration = (double)(finish - start) / CLOCKS_PER_SEC;
	if(duration >= s) {
	    start = finish;
		return true;
	}
	return false;
}
//---------------------------------------------------------------------------
// Blocks until time (s) has elapsed.
//---------------------------------------------------------------------------
void __fastcall TForm1::delay(time_t s)
{
	if(!s) return;

	clock_t start = clock();
	clock_t finish = 0;
	double duration = 0;

	do {
		finish = clock();
	}
	while((duration = (double)(finish - start) / CLOCKS_PER_SEC) < s);
}
//---------------------------------------------------------------------------
void __fastcall TForm1::updateAGCDisplay(void)
{
	static bool displayTimeout = false;
	static int clockCounter = 0;

	if(checkElapsedTime(2)) {
        displayTimeout = true;
        if(LAMP_COMPACTY->Color == COLOR_ON) LAMP_COMPACTY->Color = COLOR_OFF;
        else                                 LAMP_COMPACTY->Color = COLOR_ON;
    }
	if(MON::FCLK) {
		if(MON::RUN) {
            // update every 2 seconds at the start of a new instruction
			if(displayTimeout || dskyChanged) {
				clockCounter++;
				if( (TPG::register_SG.read() == TP12 && SEQ::register_SNI.read() == 1) ||
					(TPG::register_SG.read() == STBY) ||
					clockCounter > 500 ||
					dskyChanged)
				{
					MON::displayAGC();
					displayTimeout = false;
					clockCounter = 0;
					dskyChanged = false;
				}
			}
		}
		else {
			static bool displayOnce = false;
			if(TPG::register_SG.read() == WAIT) {
				if(displayOnce == false) {
					MON::displayAGC();
					displayOnce = true;
					clockCounter = 0;
				}
			}
			else {
				displayOnce = false;
			}
		}
	}
	else MON::displayAGC(); // When the clock is manual or slow, always update.
}
//---------------------------------------------------------------------------
// This is the OnIdle event handler. It is set in the Form’s OnCreate event
// handler, so you need only add it as a private method of the form.
// perform some background processing for the application.
//---------------------------------------------------------------------------
void __fastcall TForm1::IdleEventHandler(TObject *Sender, bool &Done)
{
    if(MON::FCLK || singleClock) {
	    // This is a performance enhancement. If the AGC is running,
		// don't check the keyboard or simulator display every simulation
		// cycle, because that slows the simulator down too much.
		int genStateCntr = 100;
		do {
		    CLK::clkAGC();
			singleClock = false;
			genAGCStates();
			genStateCntr--;
			// This needs more work. It doesn't always stop at the
			// right location and sometimes stops at the instruction
			// afterwards, too.
			if(breakpointEnab && breakpoint == ADR::getEffectiveAddress()) {
			    MON::RUN = 0;
			}
			// Halt right after the instruction that changes a
            // watched memory location.
			if(watchEnab) {
			    unsigned newWatchValue = MEM::readMemory(watchAddr);
				if(newWatchValue != oldWatchValue) {
				    MON::RUN = 0;
				}
				oldWatchValue = newWatchValue;
			}
		} while (MON::FCLK && MON::RUN && genStateCntr > 0);
		updateAGCDisplay();
	}
	// for convenience, clear the single step switch on TP1; in the
	// hardware AGC, this happens when the switch is released
	if(MON::STEP && TPG::register_SG.read() == TP1) MON::STEP = 0;
    Done = false;
}
//---------------------------------------------------------------------------
void __fastcall TForm1::RefreshDisplayButton1Click(TObject *Sender)
{
    genAGCStates();
	MON::displayAGC();
}
//---------------------------------------------------------------------------
// Load AGC memory from the Object file created by compile of source.
//---------------------------------------------------------------------------
void __fastcall TForm1::LoadProgramButton1Click(TObject *Sender)
{
    ObjectFile = ChangeFileExt(SourceFile,".obj");
    if(FileExists(ObjectFile)) {
       	strcpy(filename, ObjectFile.c_str());
    	FILE* fp = fopen(filename, "r");
    	if(!fp) {
	    	ShowMessage("fopen failed");
		    MonitorForm1->Memo2->Lines->Add("*** ERROR: Can't load memory for file: " + AnsiString(filename));
    		return;
	    }
    	unsigned addr;
	    unsigned data;
    	while(fscanf(fp, "%o %o", &addr, &data) != EOF) {
	    	MEM::writeMemory(addr, data);
    	}
	    fclose(fp);
    	MonitorForm1->Memo2->Lines->Add("Object file loaded.");
    }
}
//---------------------------------------------------------------------------
// Load AGC memory from the specified file.
//---------------------------------------------------------------------------
void __fastcall TForm1::loadMemory(void)
{
    if(OpenDialog1->Execute()) {
    	strcpy(filename, OpenDialog1->FileName.c_str());
    	FILE* fp = fopen(filename, "r");
    	if(!fp) {
	    	ShowMessage("fopen failed");
		    MonitorForm1->Memo2->Lines->Add("*** ERROR: Can't load memory for file: " + AnsiString(filename));
    		return;
	    }
    	unsigned addr;
	    unsigned data;
    	while(fscanf(fp, "%o %o", &addr, &data) != EOF) {
	    	MEM::writeMemory(addr, data);
    	}
	    fclose(fp);
    	MonitorForm1->Memo2->Lines->Add("Object file loaded.");
    }
}
//---------------------------------------------------------------------------
void __fastcall TForm1::LoadMemoryButton1Click(TObject *Sender)
{
    loadMemory();
}
//---------------------------------------------------------------------------
void __fastcall TForm1::PowerUpResetButton1Click(TObject *Sender)
{
    MON::PURST = (MON::PURST + 1) % 2;
	genAGCStates();
	MON::displayAGC();
}
//---------------------------------------------------------------------------
void __fastcall TForm1::RunButton1Click(TObject *Sender)
{
	MON::RUN = (MON::RUN + 1) % 2;
	genAGCStates();
	if(!MON::FCLK) MON::displayAGC();
}
//---------------------------------------------------------------------------
void __fastcall TForm1::FastClockButton1Click(TObject *Sender)
{
    if(FastClockButton1->Caption == "Fast Clock") {
        FastClockButton1->Caption = "Manual Clock";
        MON::FCLK = 1;
    }
    else {
        FastClockButton1->Caption = "Fast Clock";
        MON::FCLK = 0;
    }
    genAGCStates();
    MON::displayAGC();
}
//---------------------------------------------------------------------------
void __fastcall TForm1::SingleClockButton1Click(TObject *Sender)
{
    singleClock = true;
}
//---------------------------------------------------------------------------
void __fastcall TForm1::StepButton1Click(TObject *Sender)
{
	MON::STEP = (MON::STEP + 1) % 2;
	genAGCStates();
	if(!MON::FCLK) MON::displayAGC();
}
//---------------------------------------------------------------------------
void __fastcall TForm1::InstructionButton1Click(TObject *Sender)
{
	MON::INST = (MON::INST + 1) % 2; 
	genAGCStates();
	MON::displayAGC();
}
//---------------------------------------------------------------------------
void __fastcall TForm1::ClearAlarmsButton1Click(TObject *Sender)
{
	PAR::CLR_PALM();	// Asynchronously clear PARITY FAIL
	MON::displayAGC();
}
//---------------------------------------------------------------------------
void __fastcall TForm1::ToggleWatchButton1Click(TObject *Sender)
{
    toggleWatch();
}
//---------------------------------------------------------------------------
void __fastcall TForm1::ToggleBreakpointButton1Click(TObject *Sender)
{
    toggleBreakpoint();
}
//---------------------------------------------------------------------------
void __fastcall TForm1::StandbyAllowedButton1Click(TObject *Sender)
{
	MON::SA = (MON::SA + 1) % 2;
	genAGCStates();
	MON::displayAGC();
}
//---------------------------------------------------------------------------
void __fastcall TForm1::ExamineMemoryButton1Click(TObject *Sender)
{
    examineMemory();
}
//---------------------------------------------------------------------------
void __fastcall TForm1::LoadSourceButton1Click(TObject *Sender)
{
    if(OpenDialog2->Execute()) {
        SourceFile = OpenDialog2->FileName;
        ProgName = ExtractFileName(SourceFile);
        Form1->Caption = " Apollo Automatic Guidance Computer Simulator - " + ProgName;
        SourceCodeForm1->RichEdit1->Lines->LoadFromFile(SourceFile);
        SourceCodeForm1->FileName = SourceFile;
        ShowSourceButton1->Caption = "Hide Source";
        if(!FileExists(SourceFile)) SourceCodeForm1->RichEdit1->Lines->Clear();
        SourceCodeForm1->Show();
    }
}
//---------------------------------------------------------------------------
void __fastcall TForm1::ShowSourceButton1Click(TObject *Sender)
{
    if(SourceCodeForm1->Visible) {
        ShowSourceButton1->Caption = "Show Source";
        SourceCodeForm1->Hide();
    }
    else {
        ShowSourceButton1->Caption = "Hide Source";
        if(!FileExists(SourceFile)) SourceCodeForm1->RichEdit1->Lines->Clear();
        SourceCodeForm1->Show();
    }
}
//---------------------------------------------------------------------------
// Compile the assembly code
//---------------------------------------------------------------------------
void __fastcall TForm1::CompileButton1Click(TObject *Sender)
{
    if(FileExists(SourceFile)) {
        asm_main(SourceFile.c_str());
    }
    else {
        MonitorForm1->Memo2->Lines->Add("Valid source file not specified");
    }
}
//---------------------------------------------------------------------------
void __fastcall TForm1::InterruptButton1Click(TObject *Sender)
{
    interrupt();
}
//---------------------------------------------------------------------------
void __fastcall TForm1::ToggleScalerButton1Click(TObject *Sender)
{
	MON::SCL_ENAB = (MON::SCL_ENAB + 1) % 2;
	genAGCStates();
    MON::displayAGC();
}
//---------------------------------------------------------------------------
void __fastcall TForm1::IncrCntrButton1Click(TObject *Sender)
{
    incrCntr();
}
//---------------------------------------------------------------------------
void __fastcall TForm1::DecCntrButton1Click(TObject *Sender)
{
    decrCntr();
}
//---------------------------------------------------------------------------


