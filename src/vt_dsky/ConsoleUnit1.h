//---------------------------------------------------------------------------
#ifndef ConsoleUnit1H
#define ConsoleUnit1H
//---------------------------------------------------------------------------
#include <Classes.hpp>
#include <Controls.hpp>
#include <StdCtrls.hpp>
#include <Forms.hpp>
#include <ComCtrls.hpp>
#include <ExtCtrls.hpp>
//---------------------------------------------------------------------------
class TForm1 : public TForm
{
__published:	// IDE-managed Components
    TCheckBox *ConWinCheckBox1;
    TGroupBox *GroupBox1;
    TLabel *Label2;
    TLabel *Label3;
    TLabel *Label4;
    TLabel *Label5;
    TComboBox *DIG_0;
    TComboBox *DIG_1;
    TComboBox *DIG_2;
    TComboBox *DIG_3;
    TShape *LED7;
    TShape *LED6;
    TShape *LED5;
    TShape *LED4;
    TShape *LED3;
    TShape *LED2;
    TShape *LED1;
    TShape *LED0;
    TStatusBar *StatusBar1;
    TLabel *Label1;
    TPanel *Panel1;
    TButton *SetValuesButton1;
    TButton *ExitButton2;
    TButton *OpenButton1;
    TButton *CloseButton1;
    TPanel *TestPanel1;
    TLabel *Label6;
    TButton *SendStringButton1;
    TEdit *SendEdit1;
    TStaticText *ReadText1;
    TButton *GetStringButton1;
    TCheckBox *TestPanelCheckBox1;
    void __fastcall ConWinCheckBox1Click(TObject *Sender);
    void __fastcall SetValuesButton1Click(TObject *Sender);
    void __fastcall ExitButton2Click(TObject *Sender);
    void __fastcall OpenButton1Click(TObject *Sender);
    void __fastcall CloseButton1Click(TObject *Sender);
    void __fastcall SendStringButton1Click(TObject *Sender);
    void __fastcall GetStringButton1Click(TObject *Sender);
    void __fastcall FormClose(TObject *Sender, TCloseAction &Action);
    void __fastcall TestPanelCheckBox1Click(TObject *Sender);
    void __fastcall FormCreate(TObject *Sender);

private:	// User declarations
    int TestHeight;

    bool process_running;       // process semaphore
    AnsiString ResultString;    // Returned string from a command

    void __fastcall SendCommandString(AnsiString Command);
    int  __fastcall GetResultString(void);
    void __fastcall SendAndGet(AnsiString Command);

public:		// User declarations

    AnsiString __fastcall getbinary(int val);
    void __fastcall UpdateValues(void);

    __fastcall TForm1(TComponent* Owner);

};
//---------------------------------------------------------------------------
extern PACKAGE TForm1 *Form1;
//---------------------------------------------------------------------------
#endif
