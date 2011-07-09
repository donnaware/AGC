//---------------------------------------------------------------------------
#ifndef ShowSourceUnit1H
#define ShowSourceUnit1H
//---------------------------------------------------------------------------
#include <Classes.hpp>
#include <Controls.hpp>
#include <StdCtrls.hpp>
#include <Forms.hpp>
#include <ActnList.hpp>
#include <ComCtrls.hpp>
#include <ImgList.hpp>
#include <Menus.hpp>
#include <StdActns.hpp>
#include <ToolWin.hpp>
#include <Dialogs.hpp>
//---------------------------------------------------------------------------
class TSourceCodeForm1 : public TForm
{
__published:	// IDE-managed Components
        TStatusBar *StatusBar1;
        TActionList *ActionList1;
        TAction *FileNew;
        TAction *FileOpen;
        TAction *FileSave;
        TAction *FileSaveAs;
        TAction *FileExit;
        TAction *HelpContents;
        TAction *HelpIndex;
        TEditCut *EditCut1;
        TEditCopy *EditCopy1;
        TEditPaste *EditPaste1;
        TMainMenu *MainMenu1;
        TMenuItem *File1;
        TMenuItem *Edit1;
        TMenuItem *Help1;
        TMenuItem *New1;
        TMenuItem *Open1;
        TMenuItem *Save1;
        TMenuItem *SaveAs1;
        TMenuItem *Exit1;
        TMenuItem *Copy1;
        TMenuItem *Copy2;
        TMenuItem *Paste1;
        TMenuItem *Contents1;
        TMenuItem *Contents2;
        TToolBar *ToolBar1;
        TToolButton *ToolButton1;
        TToolButton *ToolButton2;
        TToolButton *ToolButton3;
        TToolButton *ToolButton5;
        TToolButton *ToolButton6;
        TToolButton *ToolButton7;
        TToolButton *ToolButton8;
        TToolButton *ToolButton9;
        TToolButton *ToolButton10;
        TOpenDialog *OpenDialog1;
        TSaveDialog *SaveDialog1;
        TMenuItem *N1;
        TMenuItem *About1;
        TAction *HelpAbout;
    TImageList *ImageList2;
    TMenuItem *N2;
    TFontDialog *FontDialog1;
    TColorDialog *ColorDialog1;
    TPrintDialog *PrintDialog1;
    TPrinterSetupDialog *PrinterSetupDialog1;
    TFindDialog *FindDialog1;
    TReplaceDialog *ReplaceDialog1;
    TMenuItem *N3;
    TMenuItem *Clear1;
    TMenuItem *Search1;
    TMenuItem *Find1;
    TMenuItem *Replace1;
    TToolButton *ToolButton11;
    TToolButton *ToolButton12;
    TToolButton *ToolButton13;
    TEditSelectAll *EditSelectAll1;
    TAction *SearchFind;
    TAction *SearchReplace;
    TMenuItem *SelectAll1;
    TMenuItem *Undo1;
    TMenuItem *N4;
    TAction *UndoEdits;
    TToolButton *ToolButton14;
    TMenuItem *Font1;
    TMenuItem *Font2;
    TMenuItem *WordWrap1;
    TMenuItem *N5;
    TMenuItem *PageSetup1;
    TMenuItem *Print1;
    TToolButton *ToolButton15;
    TAction *PrintDoc1;
    TAction *PageSetupAction1;
    TAction *FontChangeAction1;
    TAction *ClearAction1;
    TToolButton *ToolButton16;
    TToolButton *ToolButton4;
    TToolButton *ToolButton17;
    TToolButton *ToolButton18;
    TAction *BoldAction1;
    TAction *ItalicsAction1;
    TAction *UnderlineAction1;
    TAction *TextColorAction1;
    TMenuItem *N6;
    TToolButton *ToolButton19;
    TToolButton *ToolButton20;
    TMenuItem *Bold1;
    TMenuItem *ItalicsAction2;
    TMenuItem *UnderlineAction2;
    TToolButton *ToolButton26;
    TMenuItem *N7;
    TMenuItem *TabStops1;
    TAction *TabStopsAction1;
    TPopupMenu *PopupMenu1;
    TMenuItem *Copy3;
    TMenuItem *Cut1;
    TMenuItem *Undo2;
    TMenuItem *Paste2;
    TMenuItem *SelectAll2;
    TMenuItem *Clear2;
    TMenuItem *N8;
    TMenuItem *Bold2;
    TMenuItem *Italics1;
    TMenuItem *Underline1;
    TMenuItem *TextColor1;
    TMenuItem *N9;
    TMenuItem *Font3;
    TMenuItem *AlignLeft1;
    TMenuItem *AlignRight1;
    TMenuItem *AlignCenter1;
    TMenuItem *Bullets1;
    TRichEdit *RichEdit1;
    TComboBox *FontSelectComboBox1;
    TComboBox *FontSizeComboBox1;
    TMenuItem *TabstoSpaces1;
    void __fastcall FileNewExecute(TObject *Sender);
    void __fastcall FileOpenExecute(TObject *Sender);
    void __fastcall FileSaveExecute(TObject *Sender);
    void __fastcall FileSaveAsExecute(TObject *Sender);
    void __fastcall FileExitExecute(TObject *Sender);
    void __fastcall HelpAboutExecute(TObject *Sender);
    void __fastcall FormCreate(TObject *Sender);
    void __fastcall HelpContentsExecute(TObject *Sender);
    void __fastcall HelpIndexExecute(TObject *Sender);
    void __fastcall Find1Click(TObject *Sender);
    void __fastcall FindDialog1Find(TObject *Sender);
    void __fastcall EditCut1Execute(TObject *Sender);
    void __fastcall EditCopy1Execute(TObject *Sender);
    void __fastcall EditPaste1Execute(TObject *Sender);
    void __fastcall EditSelectAll1Execute(TObject *Sender);
    void __fastcall UndoEditsExecute(TObject *Sender);
    void __fastcall SearchReplaceExecute(TObject *Sender);
    void __fastcall PrintDoc1Execute(TObject *Sender);
    void __fastcall PageSetupAction1Execute(TObject *Sender);
    void __fastcall FontChangeAction1Execute(TObject *Sender);
    void __fastcall ClearAction1Execute(TObject *Sender);
    void __fastcall WordWrap1Click(TObject *Sender);
    void __fastcall ReplaceDialog1Replace(TObject *Sender);
    void __fastcall ReplaceDialog1Find(TObject *Sender);
    void __fastcall RichEdit1Change(TObject *Sender);
    void __fastcall BoldAction1Execute(TObject *Sender);
    void __fastcall ItalicsAction1Execute(TObject *Sender);
    void __fastcall UnderlineAction1Execute(TObject *Sender);
    void __fastcall TextColorAction1Execute(TObject *Sender);
    void __fastcall TabStopsAction1Execute(TObject *Sender);
    void __fastcall FontSelectComboBox1Click(TObject *Sender);
    void __fastcall FontSizeComboBox1Click(TObject *Sender);
    void __fastcall TabstoSpaces1Click(TObject *Sender);
    void __fastcall FormClose(TObject *Sender, TCloseAction &Action);
    void __fastcall FormShow(TObject *Sender);

private:	// User declarations

public:		// User declarations
    AnsiString FileName;

    __fastcall TSourceCodeForm1(TComponent* Owner);

};
//---------------------------------------------------------------------------
extern PACKAGE TSourceCodeForm1 *SourceCodeForm1;
//---------------------------------------------------------------------------
#endif
