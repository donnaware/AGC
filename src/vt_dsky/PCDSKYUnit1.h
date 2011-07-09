//---------------------------------------------------------------------------
#ifndef PCDSKYUnit1H
#define PCDSKYUnit1H
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
//----------------------------------------------------------------------------
#define     VersionNum      "1.1"           // Software version number
#define     ReportSize      64
//----------------------------------------------------------------------------
enum keyInType {
	// DSKY keyboard input codes: Taken from E-1574, Appendix 1
	// These codes enter the computer through bits 1-5 of IN0.
	// The MSB is in bit 5; LSB in bit 1. Key entry generates KEYRUPT.
	KEYIN_NONE			= 0,		// no key depressed**
	KEYIN_0				= 020,
	KEYIN_1				= 001,
	KEYIN_2				= 002,
	KEYIN_3				= 003,
	KEYIN_4				= 004,
	KEYIN_5				= 005,
	KEYIN_6				= 006,
	KEYIN_7				= 007,
	KEYIN_8				= 010,
	KEYIN_9				= 011,
	KEYIN_VERB			= 021,
	KEYIN_ERROR_RESET	= 022,
	KEYIN_KEY_RELEASE	= 031,
	KEYIN_PLUS			= 032,
	KEYIN_MINUS			= 033,
	KEYIN_ENTER			= 034,
	KEYIN_CLEAR			= 036,
	KEYIN_NOUN			= 037,
};
//---------------------------------------------------------------------------
class TForm1 : public TForm
{
__published:	// IDE-managed Components
    TPanel *Panel1;
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
    TButton *ExitButton1;
    TButton *ShowMonitorButton1;
    TPanel *LAMP_BLANK1;
    TLabel *Label10;
    TPanel *LAMP_ALT;
    TLabel *Label11;
    TPanel *LAMP_BLANK2;
    TLabel *Label12;
    TPanel *LAMP_VEL;
    TLabel *Label13;
    TButton *RefreshDisplayButton1;
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
    TLabel *Label15;
    TLabel *Label16;
    TButton *OpenConButton1;
    TStatusBar *StatusBar1;
    TButton *CloseConButton1;
    TButton *FPGALEDButton1;
    TTimer *Timer1;
    TCheckBox *CheckBox1;
    TButton *LoadConfigurationButton1;
    void __fastcall ExitButton1Click(TObject *Sender);
    void __fastcall ShowMonitorButton1Click(TObject *Sender);
    void __fastcall DSKY_Button_0Click(TObject *Sender);
    void __fastcall RefreshDisplayButton1Click(TObject *Sender);
    void __fastcall FormShow(TObject *Sender);
    void __fastcall PaintBox1Paint(TObject *Sender);
    void __fastcall FPGALEDButton1Click(TObject *Sender);
    void __fastcall OpenConButton1Click(TObject *Sender);
    void __fastcall FormClose(TObject *Sender, TCloseAction &Action);
    void __fastcall CloseConButton1Click(TObject *Sender);
    void __fastcall LoadConfigurationButton1Click(TObject *Sender);

private:	// User declarations
    char dskey;

    byte Keypad;
    byte InputSelect;
    byte OutputSelect;
    byte Outputdata;
    byte Inputdata;

    AnsiString ResultString;
    AnsiString binary_string;
    bool process_running;

    void __fastcall SetSelect(void);
    void __fastcall binarystringToInt(void);
    int  __fastcall GetResultString(void);
    void __fastcall SendCommandString(AnsiString Command);
    void __fastcall SendAndGet(AnsiString Command);
    void __fastcall getbinary(int val);

    void __fastcall GetDSKYReg(int reg);
    void __fastcall UpdateDSKY(void);

    void __fastcall LampTest(TColor lampstate);

    int  __fastcall GetSegIndex(char value);
    void __fastcall PaintSegment(TPaintBox *pb, int segno, TColor segcol);
    void __fastcall keypress(keyInType keypad);

public:		// User declarations

    char display[32];
    void __fastcall UpdateAll(void);
    void __fastcall CloseMonitor(void);

    __fastcall TForm1(TComponent* Owner);

};
//---------------------------------------------------------------------------
extern PACKAGE TForm1 *Form1;
//---------------------------------------------------------------------------
#endif
