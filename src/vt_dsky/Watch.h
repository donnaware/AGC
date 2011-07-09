//---------------------------------------------------------------------------
#ifndef WatchH
#define WatchH
//---------------------------------------------------------------------------
#include <Classes.hpp>
#include <Controls.hpp>
#include <StdCtrls.hpp>
#include <Forms.hpp>
#include <Menus.hpp>
#include <ComCtrls.hpp>
//---------------------------------------------------------------------------
class TWatchWin : public TForm
{
__published:	// IDE-managed Components
    TPopupMenu *PopupMenu1;
    TMenuItem *ClearWatch;
    TMenuItem *N1;
    TMenuItem *Copy1;
    TMenuItem *SelectAll1;
    TMemo *WatchMemo;
    void __fastcall FormClose(TObject *Sender, TCloseAction &Action);
    void __fastcall ClearWatchClick(TObject *Sender);
    void __fastcall Copy1Click(TObject *Sender);
    void __fastcall SelectAll1Click(TObject *Sender);

private:	// User declarations
    TStringList *WatchList;

public:		// User declarations

    void __fastcall WatchPrint(char *MsgStr, unsigned long nchars);
    void __fastcall WatchOut(AnsiString str);
    void __fastcall WatchAppend(AnsiString str);

    __fastcall TWatchWin(TComponent* Owner);

};
//---------------------------------------------------------------------------
extern PACKAGE TWatchWin *WatchWin;
//---------------------------------------------------------------------------
#endif
