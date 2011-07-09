//---------------------------------------------------------------------------
#include <vcl.h>
#pragma hdrstop
#include "Watch.h"
#include "PCDSKYUnit1.h"
//---------------------------------------------------------------------------
#pragma package(smart_init)
#pragma resource "*.dfm"
//---------------------------------------------------------------------------
TWatchWin *WatchWin;
//---------------------------------------------------------------------------
__fastcall TWatchWin::TWatchWin(TComponent* Owner) : TForm(Owner)
{
}
//---------------------------------------------------------------------------
void __fastcall TWatchWin::FormClose(TObject *Sender, TCloseAction &Action)
{
    Form1->CloseMonitor();  // close this window
}
//---------------------------------------------------------------------------
void __fastcall TWatchWin::WatchOut(AnsiString str)
{
    WatchMemo->Lines->Add(str);   // put the users output onto the little window
}
//---------------------------------------------------------------------------
void __fastcall TWatchWin::WatchAppend(AnsiString str)
{
    int n = WatchMemo->Lines->Count;
    AnsiString tmp = WatchMemo->Lines->Strings[n-1];
    WatchMemo->Lines->Strings[n-1] = tmp + str;  // Append users output onto the little window
}
//---------------------------------------------------------------------------
void __fastcall TWatchWin::ClearWatchClick(TObject *Sender)
{
    WatchMemo->Clear();    // Clear the Watch Window
}
//---------------------------------------------------------------------------
void __fastcall TWatchWin::Copy1Click(TObject *Sender)
{
    WatchMemo->CopyToClipboard();    // Copy Selection to Clip board
}
//---------------------------------------------------------------------------
void __fastcall TWatchWin::SelectAll1Click(TObject *Sender)
{
    WatchMemo->SelectAll();    // Select all text
}
//---------------------------------------------------------------------------

