//---------------------------------------------------------------------------
#include <vcl.h>
#pragma hdrstop
#include "PromptUnit1.h"
//---------------------------------------------------------------------------
#pragma package(smart_init)
#pragma resource "*.dfm"
TPromptForm1 *PromptForm1;
//---------------------------------------------------------------------------
__fastcall TPromptForm1::TPromptForm1(TComponent* Owner) : TForm(Owner)
{
}
//---------------------------------------------------------------------------
void __fastcall TPromptForm1::Button1Click(TObject *Sender)
{
    Close();
}
//---------------------------------------------------------------------------
void __fastcall TPromptForm1::Button2Click(TObject *Sender)
{
    Close();
}
//---------------------------------------------------------------------------
