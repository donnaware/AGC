//---------------------------------------------------------------------------
#include <vcl.h>
#pragma hdrstop
#include "AGCSimUnit1.h"
#include "MonitorUnit1.h"
//---------------------------------------------------------------------------
#pragma package(smart_init)
#pragma resource "*.dfm"
TMonitorForm1 *MonitorForm1;
//---------------------------------------------------------------------------
__fastcall TMonitorForm1::TMonitorForm1(TComponent* Owner) : TForm(Owner)
{
}
//---------------------------------------------------------------------------
void __fastcall TMonitorForm1::FormClose(TObject *Sender, TCloseAction &Action)
{
    Form1->ShowMonitorButton1->Caption = "Show Monitor";
}
//---------------------------------------------------------------------------

