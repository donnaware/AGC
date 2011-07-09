//---------------------------------------------------------------------------
#ifndef AGCSimUnit1H
#define AGCSimUnit1H
//---------------------------------------------------------------------------
#include <time.h>
#include <Classes.hpp>
#include <Controls.hpp>
#include <StdCtrls.hpp>
#include <Forms.hpp>
#include <ExtCtrls.hpp>
#include <jpeg.hpp>
#include <ImgList.hpp>
#include <ComCtrls.hpp>
#include <Graphics.hpp>
#include <Buttons.hpp>
#include <Dialogs.hpp>
#include <ActnCtrls.hpp>
#include <ActnMan.hpp>
#include <ToolWin.hpp>
//---------------------------------------------------------------------------
#define COLOR_OFF  TColor(0x00003300)
#define COLOR_ON   TColor(0x0000FF00) //clLime
//---------------------------------------------------------------------------
class TForm1 : public TForm
{
__published:	// IDE-managed Components
    TPanel *Panel2;
    TButton *DSKY_Button_VERB;
    TButton *DSKY_Button_NOUN;
    TButton *DSKY_Button_Plus;
    TButton *DSKY_Button_Minus;
    TButton *DSKY_Button_0;
    TButton *DSKY_Button_7;
    TButton *DSKY_Button_4;
    TButton *DSKY_Button_1;
    TButton *DSKY_Button_8;
    TButton *DSKY_Button_5;
    TButton *DSKY_Button_2;
    TButton *DSKY_Button_9;
    TButton *DSKY_Button_6;
    TButton *DSKY_Button_3;
    TButton *DSKY_Button_CLR;
    TButton *DSKY_Button_PRO;
    TButton *DSKY_Button_KREL;
    TButton *DSKY_Button_ENTR;
    TButton *DSKY_Button_RSET;
    TPanel *Panel3;
    TPanel *DisplayPanel;
    TShape *Shape15;
    TShape *Shape71;
    TStaticText *StaticText1;
    TShape *Shape124;
    TStaticText *StaticText2;
    TPanel *LAMP_COMPACTY;
    TLabel *Label1;
    TStaticText *StaticText4;
    TPanel *LAMP_UPLINKACTY;
    TLabel *Label2;
    TPanel *LAMP_TEMP;
    TLabel *Label3;
    TPanel *LAMP_NOATT;
    TLabel *Label4;
    TPanel *LAMP_GIMBALLOCK;
    TLabel *Label5;
    TPanel *LAMP_KEYREL;
    TLabel *Label6;
    TPanel *LAMP_RESTART;
    TLabel *Label7;
    TPanel *LAMP_OPPERR;
    TLabel *Label8;
    TPanel *LAMP_TRACKER;
    TLabel *Label9;
    TPanel *LAMP_BLANK1;
    TLabel *Label10;
    TPanel *LAMP_ALT;
    TLabel *Label11;
    TPanel *LAMP_BLANK2;
    TLabel *Label12;
    TPanel *LAMP_VEL;
    TLabel *Label13;
    TOpenDialog *OpenDialog1;
    TPaintBox *PaintBox2;
    TPaintBox *PaintBox3;
    TPaintBox *PaintBox4;
    TPaintBox *PaintBox5;
    TPaintBox *PaintBox6;
    TPaintBox *PaintBox7;
    TPaintBox *PaintBox8;
    TPaintBox *PaintBox9;
    TPaintBox *PaintBox10;
    TPaintBox *PaintBox11;
    TPaintBox *PaintBox12;
    TPaintBox *PaintBox13;
    TPaintBox *PaintBox14;
    TPaintBox *PaintBox15;
    TPaintBox *PaintBox16;
    TPaintBox *PaintBox17;
    TPaintBox *PaintBox18;
    TPaintBox *PaintBox19;
    TPaintBox *PaintBox20;
    TPaintBox *PaintBox21;
    TPaintBox *PaintBox22;
    TPaintBox *PaintBox1;
    TPaintBox *PaintBox23;
    TPaintBox *PaintBox24;
    TSpeedButton *SpeedButton1;
    TPanel *Panel1;
    TButton *ExitButton1;
    TButton *ShowMonitorButton1;
    TButton *RefreshDisplayButton1;
    TButton *LoadMemoryButton1;
    TButton *ShowSourceButton1;
    TButton *RunButton1;
    TButton *PowerUpResetButton1;
    TButton *FastClockButton1;
    TPanel *DebuggerPanel1;
    TButton *DecCntrButton1;
    TButton *IncrCntrButton1;
    TButton *ToggleScalerButton1;
    TButton *InterruptButton1;
    TButton *ExamineMemoryButton1;
    TButton *StandbyAllowedButton1;
    TButton *ClearAlarmsButton1;
    TButton *ToggleWatchButton1;
    TButton *ToggleBreakpointButton1;
    TButton *InstructionButton1;
    TSpeedButton *LampTestButton1;
    TLabel *Label14;
    TLabel *Label15;
    TButton *LoadSourceButton1;
    TButton *StepButton1;
    TButton *SingleClockButton1;
    TButton *ShowDebuggerButton1;
    TButton *CompileButton1;
    TButton *AboutButton1;
    TButton *HelpButton1;
    TOpenDialog *OpenDialog2;
    TButton *LoadProgramButton1;
    void __fastcall ExitButton1Click(TObject *Sender);
    void __fastcall ShowMonitorButton1Click(TObject *Sender);
    void __fastcall DSKY_Button_0Click(TObject *Sender);
    void __fastcall LampTestButton1MouseDown(TObject *Sender,TMouseButton Button, TShiftState Shift, int X, int Y);
    void __fastcall LampTestButton1MouseUp(TObject *Sender,TMouseButton Button, TShiftState Shift, int X, int Y);
    void __fastcall FormCreate(TObject *Sender);
    void __fastcall RefreshDisplayButton1Click(TObject *Sender);
    void __fastcall LoadMemoryButton1Click(TObject *Sender);
    void __fastcall PowerUpResetButton1Click(TObject *Sender);
    void __fastcall RunButton1Click(TObject *Sender);
    void __fastcall FastClockButton1Click(TObject *Sender);
    void __fastcall SingleClockButton1Click(TObject *Sender);
    void __fastcall StepButton1Click(TObject *Sender);
    void __fastcall InstructionButton1Click(TObject *Sender);
    void __fastcall ClearAlarmsButton1Click(TObject *Sender);
    void __fastcall ToggleWatchButton1Click(TObject *Sender);
    void __fastcall ToggleBreakpointButton1Click(TObject *Sender);
    void __fastcall StandbyAllowedButton1Click(TObject *Sender);
    void __fastcall ExamineMemoryButton1Click(TObject *Sender);
    void __fastcall ShowSourceButton1Click(TObject *Sender);
    void __fastcall InterruptButton1Click(TObject *Sender);
    void __fastcall ToggleScalerButton1Click(TObject *Sender);
    void __fastcall IncrCntrButton1Click(TObject *Sender);
    void __fastcall DecCntrButton1Click(TObject *Sender);
    void __fastcall FormShow(TObject *Sender);
    void __fastcall PaintBox1Paint(TObject *Sender);
    void __fastcall ShowDebuggerButton1Click(TObject *Sender);
    void __fastcall AboutButton1Click(TObject *Sender);
    void __fastcall LoadSourceButton1Click(TObject *Sender);
    void __fastcall HelpButton1Click(TObject *Sender);
    void __fastcall CompileButton1Click(TObject *Sender);
    void __fastcall LoadProgramButton1Click(TObject *Sender);

private:	// User declarations
    char dskey;
    char filename[80];
    char cmdprompt[80];

    void __fastcall LampTest(TColor lampstate);

    void __fastcall genAGCStates(void);
    char*  __fastcall getCommand(char* prompt);


    bool breakpointEnab;
    unsigned breakpoint;
    void __fastcall toggleBreakpoint(void);

    bool watchEnab;
    unsigned watchAddr;
    unsigned oldWatchValue;
    void __fastcall toggleWatch(void);

    void __fastcall incrCntr(void);
    void __fastcall decrCntr(void);
    void __fastcall interrupt(void);
    void __fastcall loadMemory(void);
    void __fastcall saveMemory(char* filename);
    void __fastcall examineMemory(void);
    bool __fastcall checkElapsedTime(time_t s);
    void __fastcall delay(time_t s);
    void __fastcall updateAGCDisplay(void);

    int  __fastcall GetSegIndex(char value);
    void __fastcall PaintSegment(TPaintBox *pb, int segno, TColor segcol);

	bool singleClock;
    void __fastcall IdleEventHandler(TObject *Sender, bool &Done);

public:		// User declarations

    AnsiString SourceFile;
    AnsiString ObjectFile;
    AnsiString ProgName;

    char display[32];
    void __fastcall UpdateAll(void);

    __fastcall TForm1(TComponent* Owner);

};
//---------------------------------------------------------------------------
extern PACKAGE TForm1 *Form1;
extern void asm_main(char* inputfile);
//---------------------------------------------------------------------------
#endif
