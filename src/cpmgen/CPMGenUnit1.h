//---------------------------------------------------------------------------
#ifndef CPMGenUnit1H
#define CPMGenUnit1H
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
    TPanel *Panel1;
    TStatusBar *StatusBar1;
    TMemo *Memo1;
    TButton *GenEPROMSButton1;
    TButton *DumpEPROMSButton1;
    TButton *BinaryButton1;
    TButton *HexCPMButton1;
    TButton *ListButton1;
    void __fastcall GenEPROMSButton1Click(TObject *Sender);
    void __fastcall DumpEPROMSButton1Click(TObject *Sender);
    void __fastcall HexCPMButton1Click(TObject *Sender);
    void __fastcall BinaryButton1Click(TObject *Sender);
    void __fastcall ListButton1Click(TObject *Sender);

private:	// User declarations

    void __fastcall dumpEPROM(void);
    void __fastcall makeEPROMfiles(void);
    void __fastcall EPROMHexFile(char *filename, int lowBit);
    void __fastcall writeEPROMdata(FILE* fpObj, int lowBit);

public:		// User declarations

    __fastcall TForm1(TComponent* Owner);
};
//---------------------------------------------------------------------------
extern PACKAGE TForm1 *Form1;
//---------------------------------------------------------------------------
#endif
