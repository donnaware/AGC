//---------------------------------------------------------------------------

#ifndef PromptUnit1H
#define PromptUnit1H
//---------------------------------------------------------------------------
#include <Classes.hpp>
#include <Controls.hpp>
#include <StdCtrls.hpp>
#include <Forms.hpp>
//---------------------------------------------------------------------------
class TPromptForm1 : public TForm
{
__published:	// IDE-managed Components
    TEdit *Edit1;
    TButton *Button1;
    TButton *Button2;
    void __fastcall Button1Click(TObject *Sender);
    void __fastcall Button2Click(TObject *Sender);
private:	// User declarations
public:		// User declarations
    __fastcall TPromptForm1(TComponent* Owner);
};
//---------------------------------------------------------------------------
extern PACKAGE TPromptForm1 *PromptForm1;
//---------------------------------------------------------------------------
#endif
