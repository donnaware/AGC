//-----------------------------------------------------------------------------//
#include <vcl.h>
#pragma hdrstop
#include "ShowSourceUnit1.h"
#include "TabStopsUnit1.h"
//-----------------------------------------------------------------------------//
#pragma package(smart_init)
#pragma resource "*.dfm"
TTabStopsForm1 *TabStopsForm1;
//-----------------------------------------------------------------------------//
__fastcall TTabStopsForm1::TTabStopsForm1(TComponent* Owner) : TForm(Owner)
{
}
//-----------------------------------------------------------------------------//
void __fastcall TTabStopsForm1::CancelButtonClick(TObject *Sender)
{
    Close();
}
//-----------------------------------------------------------------------------//
void __fastcall TTabStopsForm1::OKButton1Click(TObject *Sender)
{
    SourceCodeForm1->RichEdit1->WantTabs = true;
    int Numtabs = NumTabsUpDown1->Position;
    int Tabs = TabUpDown1->Position;
    for(byte i =0; i<Numtabs; i++) {
        SourceCodeForm1->RichEdit1->Paragraph->Tab[i] = i*Tabs;
    }
    Close();
}
//---------------------------------------------------------------------------

