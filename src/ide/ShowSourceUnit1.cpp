//---------------------------------------------------------------------------
//  Text Editor (C) 2000 Donnaware International LLP.
//---------------------------------------------------------------------------
#include <vcl.h>
#include <clipbrd.hpp>
#pragma hdrstop
#include "ShowSourceUnit1.h"
#include "TabStopsUnit1.h"
#include "About.h"
#include "AGCSimUnit1.h"
//---------------------------------------------------------------------------
#pragma package(smart_init)
#pragma resource "*.dfm"
TSourceCodeForm1 *SourceCodeForm1;
//---------------------------------------------------------------------------
__fastcall TSourceCodeForm1::TSourceCodeForm1 (TComponent* Owner): TForm(Owner)
{
}
//---------------------------------------------------------------------------
int CALLBACK EnumProc(LOGFONT *logfont, TEXTMETRIC  *textmetric, DWORD  type, LPARAM  data)
{
    TComboBox *cb = (TComboBox *)data;
    cb->Items->Add(String (logfont->lfFaceName));
    return(1);
}
//---------------------------------------------------------------------------
void __fastcall TSourceCodeForm1::FormCreate(TObject *Sender)
{
    FileName = "Untitled.asm";
    EnumFonts(Canvas->Handle, NULL, (FONTENUMPROC) EnumProc, (LPARAM)FontSelectComboBox1) ;
    FontSelectComboBox1->ItemIndex = FontSelectComboBox1->Items->IndexOf(RichEdit1->Font->Name) ;
    RichEdit1->SelAttributes->Name = FontSelectComboBox1->Text;

    StatusBar1->Panels->Items[1]->Text = "0 Lines";
    StatusBar1->Panels->Items[2]->Text = FileName;
    RichEdit1->Clear();
}
//---------------------------------------------------------------------------
void __fastcall TSourceCodeForm1::FormShow(TObject *Sender)
{
    StatusBar1->Panels->Items[2]->Text = FileName;
}
//---------------------------------------------------------------------------
void __fastcall TSourceCodeForm1::FormClose(TObject *Sender, TCloseAction &Action)
{
    Form1->ShowSourceButton1->Caption = "Show Source";
}
//---------------------------------------------------------------------------
void __fastcall TSourceCodeForm1 ::RichEdit1Change(TObject *Sender)
{
    StatusBar1->Panels->Items[1]->Text = AnsiString(RichEdit1->Lines->Count) + " Lines";
}
//---------------------------------------------------------------------------
void __fastcall TSourceCodeForm1::FileNewExecute(TObject *Sender)
{
    RichEdit1->Clear();
    FileName = "Untitled.txt";
	StatusBar1->Panels->Items[2]->Text = FileName;
}
//---------------------------------------------------------------------------
void __fastcall TSourceCodeForm1::FileOpenExecute(TObject *Sender)
{
    if(OpenDialog1->Execute()) {
        RichEdit1->Lines->LoadFromFile(OpenDialog1->FileName);
        FileName = OpenDialog1->FileName;
        StatusBar1->Panels->Items[2]->Text = FileName;
    }
}
//---------------------------------------------------------------------------
void __fastcall TSourceCodeForm1::FileSaveExecute(TObject *Sender)
{
    RichEdit1->PlainText = true;
    if(FileName == "Untitled.asm")  FileSaveAsExecute(Sender);
    else                            RichEdit1->Lines->SaveToFile(FileName);
}
//---------------------------------------------------------------------------
void __fastcall TSourceCodeForm1::FileSaveAsExecute(TObject *Sender)
{
    RichEdit1->PlainText = true;
    SaveDialog1->FileName = FileName;
    SaveDialog1->InitialDir = ExtractFilePath(FileName);
    if(SaveDialog1->Execute())  {
        RichEdit1->Lines->SaveToFile(SaveDialog1->FileName);
        FileName = SaveDialog1->FileName;
        StatusBar1->Panels->Items[2]->Text = FileName;
    }
}
//---------------------------------------------------------------------------
void __fastcall TSourceCodeForm1::PageSetupAction1Execute(TObject *Sender)
{
    PrinterSetupDialog1->Execute();
}
//---------------------------------------------------------------------------
void __fastcall TSourceCodeForm1::PrintDoc1Execute(TObject *Sender)
{
    if(PrintDialog1->Execute()) {  // The parameter string shows in the print queue under "Document   // name".
        RichEdit1->Print(FileName);
    }
}
//---------------------------------------------------------------------------
void __fastcall TSourceCodeForm1::FileExitExecute(TObject *Sender)
{
    if(RichEdit1->Modified) {
        if(Application->MessageBox("Save changes before exiting ?", "File Changed...", MB_YESNO) == IDYES) {
            FileSaveExecute(Sender);
        }
    }
    Close();
}
//---------------------------------------------------------------------------
void __fastcall TSourceCodeForm1::HelpAboutExecute(TObject *Sender)
{
    AboutBox->ShowModal();
}
//---------------------------------------------------------------------------
void __fastcall TSourceCodeForm1::HelpContentsExecute(TObject *Sender)
{
    Application->HelpFile = ExtractFilePath(Application->ExeName) + "TextEditor.hlp";
    Application->HelpCommand(HELP_CONTENTS, 0);
}
//---------------------------------------------------------------------------
void __fastcall TSourceCodeForm1::HelpIndexExecute(TObject *Sender)
{
    Application->HelpFile = ExtractFilePath(Application->ExeName) + "TextEditor.hlp";
    const static int HELP_TAB = 15;
    const static int INDEX_ACTIVE = -2;
    Application->HelpCommand(HELP_TAB, INDEX_ACTIVE);
}
//---------------------------------------------------------------------------
void __fastcall TSourceCodeForm1::UndoEditsExecute(TObject *Sender)
{
    if(RichEdit1->CanUndo) RichEdit1->Undo();
}
//---------------------------------------------------------------------------
void __fastcall TSourceCodeForm1::EditCut1Execute(TObject *Sender)
{
    RichEdit1->CutToClipboard();
}
//---------------------------------------------------------------------------
void __fastcall TSourceCodeForm1::EditCopy1Execute(TObject *Sender)
{
    RichEdit1->CopyToClipboard();
}
//---------------------------------------------------------------------------
void __fastcall TSourceCodeForm1::EditPaste1Execute(TObject *Sender)
{
    RichEdit1->PasteFromClipboard();
}
//---------------------------------------------------------------------------
void __fastcall TSourceCodeForm1::EditSelectAll1Execute(TObject *Sender)
{
    RichEdit1->SelectAll();
}
//---------------------------------------------------------------------------
void __fastcall TSourceCodeForm1::ClearAction1Execute(TObject *Sender)
{
    RichEdit1->ClearSelection();
}
//---------------------------------------------------------------------------
void __fastcall TSourceCodeForm1::Find1Click(TObject *Sender)
{
    FindDialog1->Execute();
}
//---------------------------------------------------------------------------
void __fastcall TSourceCodeForm1::FindDialog1Find(TObject *Sender)
{
    // begin the search after the current selection if there is one
    // otherwise, begin at the start of the text
    int FoundAt, StartPos, ToEnd;
    if(RichEdit1->SelLength) StartPos = RichEdit1->SelStart + RichEdit1->SelLength;
    else                     StartPos = 0;

    // ToEnd is the length from StartPos to the end of the text in the rich edit control
    ToEnd = RichEdit1->Text.Length() - StartPos;
    FoundAt = RichEdit1->FindText(FindDialog1->FindText, StartPos, ToEnd, TSearchTypes()<< stMatchCase);
    if(FoundAt != -1) {
        RichEdit1->SetFocus();
        RichEdit1->SelStart = FoundAt;
        RichEdit1->SelLength = FindDialog1->FindText.Length();
    }
}
//---------------------------------------------------------------------------
void __fastcall TSourceCodeForm1::SearchReplaceExecute(TObject *Sender)
{
    ReplaceDialog1->Execute();
}
//---------------------------------------------------------------------------
void __fastcall TSourceCodeForm1::ReplaceDialog1Find(TObject *Sender)
{
    int FoundAt, StartPos, ToEnd;
    if(RichEdit1->SelLength) StartPos = RichEdit1->SelStart + RichEdit1->SelLength;
    else                     StartPos = 0;
    ToEnd = RichEdit1->Text.Length() - StartPos;
    FoundAt = RichEdit1->FindText(ReplaceDialog1->FindText, StartPos, ToEnd, TSearchTypes()<< stMatchCase);
    if(FoundAt != -1) {
        RichEdit1->SetFocus();
        RichEdit1->SelStart = FoundAt;
        RichEdit1->SelLength = ReplaceDialog1->FindText.Length();
    }
}
//---------------------------------------------------------------------------
void __fastcall TSourceCodeForm1::ReplaceDialog1Replace(TObject *Sender)
{
    RichEdit1->SelText = ReplaceDialog1->ReplaceTextA;
}
//---------------------------------------------------------------------------
void __fastcall TSourceCodeForm1::WordWrap1Click(TObject *Sender)
{
    WordWrap1->Checked  = !WordWrap1->Checked;
    RichEdit1->WordWrap = WordWrap1->Checked;
}
//-----------------------------------------------------------------------------//
void __fastcall TSourceCodeForm1::FontChangeAction1Execute(TObject *Sender)
{
    FontDialog1->Font->Charset = RichEdit1->SelAttributes->Charset;
    FontDialog1->Font->Name    = RichEdit1->SelAttributes->Name;
    FontDialog1->Font->Color   = RichEdit1->SelAttributes->Color;
    FontDialog1->Font->Pitch   = RichEdit1->SelAttributes->Pitch;
    FontDialog1->Font->Size    = RichEdit1->SelAttributes->Size;
    FontDialog1->Font->Style   = RichEdit1->SelAttributes->Style;
    if(FontDialog1->Execute()) {
         if(RichEdit1->SelLength) {
            RichEdit1->SelAttributes->Charset = FontDialog1->Font->Charset;
            RichEdit1->SelAttributes->Name    = FontDialog1->Font->Name;
            RichEdit1->SelAttributes->Color   = FontDialog1->Font->Color;
            RichEdit1->SelAttributes->Pitch   = FontDialog1->Font->Pitch;
            RichEdit1->SelAttributes->Size    = FontDialog1->Font->Size;
            RichEdit1->SelAttributes->Style   = FontDialog1->Font->Style;
         }
         else {
            RichEdit1->Font = FontDialog1->Font;
         }
    }
}
//---------------------------------------------------------------------------
void __fastcall TSourceCodeForm1::BoldAction1Execute(TObject *Sender)
{
    TFontStyles Tmp = RichEdit1->SelAttributes->Style;
    if(Tmp.Contains(fsBold)) Tmp >> fsBold;
    else                     Tmp << fsBold;
    RichEdit1->SelAttributes->Style  = Tmp;
    return;
}
//---------------------------------------------------------------------------
void __fastcall TSourceCodeForm1::ItalicsAction1Execute(TObject *Sender)
{
    TFontStyles Tmp = RichEdit1->SelAttributes->Style;
    if(Tmp.Contains(fsItalic)) Tmp >> fsItalic;
    else                       Tmp << fsItalic;
    RichEdit1->SelAttributes->Style  = Tmp;
    return;
}
//---------------------------------------------------------------------------
void __fastcall TSourceCodeForm1::UnderlineAction1Execute(TObject *Sender)
{
    TFontStyles Tmp = RichEdit1->SelAttributes->Style;
    if(Tmp.Contains(fsUnderline)) Tmp >> fsUnderline;
    else                          Tmp << fsUnderline;
    RichEdit1->SelAttributes->Style  = Tmp;
    return;
}
//---------------------------------------------------------------------------
void __fastcall TSourceCodeForm1::TextColorAction1Execute(TObject *Sender)
{
    if(ColorDialog1->Execute()) {
        RichEdit1->SelAttributes->Color = ColorDialog1->Color;
    }
    return;
}
//---------------------------------------------------------------------------
void __fastcall TSourceCodeForm1::TabStopsAction1Execute(TObject *Sender)
{
    TabStopsForm1->ShowModal();
}
//---------------------------------------------------------------------------
void __fastcall TSourceCodeForm1::FontSelectComboBox1Click(TObject *Sender)
{
    RichEdit1->SelAttributes->Name = FontSelectComboBox1->Text;
}
//---------------------------------------------------------------------------
void __fastcall TSourceCodeForm1::FontSizeComboBox1Click(TObject *Sender)
{
    RichEdit1->SelAttributes->Size = FontSizeComboBox1->Text.ToInt();
}
//---------------------------------------------------------------------------
void __fastcall TSourceCodeForm1::TabstoSpaces1Click(TObject *Sender)
{
//    TabStopsForm1->ShowModal();
    int tabsize = TabStopsForm1->TabSpacesUpDown1->Position;
    int n = RichEdit1->Lines->Count;

    AnsiString tmp;
	for(int i = 0; i < n; i++) {
        tmp = RichEdit1->Lines->Strings[i];
        for(int j=1; j <= RichEdit1->Lines->Strings[i].Length(); j++) {
            if(RichEdit1->Lines->Strings[i][j] == '\t') {
                RichEdit1->Lines->Strings[i] = RichEdit1->Lines->Strings[i].Delete(j,1);
                int n =  ((j-1)/tabsize + 1)*tabsize -  (j-1);
                tmp = tmp.StringOfChar(' ',n);
                RichEdit1->Lines->Strings[i] = RichEdit1->Lines->Strings[i].Insert(tmp,j);
            }
        }
    }
}
//---------------------------------------------------------------------------





