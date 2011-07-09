//---------------------------------------------------------------------------

#ifndef TabStopsUnit1H
#define TabStopsUnit1H
//---------------------------------------------------------------------------
#include <Classes.hpp>
#include <Controls.hpp>
#include <StdCtrls.hpp>
#include <Forms.hpp>
#include <ComCtrls.hpp>
//---------------------------------------------------------------------------
class TTabStopsForm1 : public TForm
{
__published:	// IDE-managed Components
    TButton *OKButton1;
    TButton *CancelButton;
    TGroupBox *GroupBox1;
    TEdit *TabEdit1;
    TUpDown *TabUpDown1;
    TEdit *NumTabsEdit1;
    TUpDown *NumTabsUpDown1;
    TLabel *Label1;
    TLabel *Label2;
    TGroupBox *GroupBox2;
    TEdit *TabSpacesEdit1;
    TLabel *Label3;
    TUpDown *TabSpacesUpDown1;
    void __fastcall CancelButtonClick(TObject *Sender);
    void __fastcall OKButton1Click(TObject *Sender);
private:	// User declarations
public:		// User declarations
    __fastcall TTabStopsForm1(TComponent* Owner);
};
//---------------------------------------------------------------------------
extern PACKAGE TTabStopsForm1 *TabStopsForm1;
//---------------------------------------------------------------------------
#endif
