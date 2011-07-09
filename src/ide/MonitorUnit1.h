//---------------------------------------------------------------------------

#ifndef MonitorUnit1H
#define MonitorUnit1H
//---------------------------------------------------------------------------
#include <Classes.hpp>
#include <Controls.hpp>
#include <StdCtrls.hpp>
#include <Forms.hpp>
//---------------------------------------------------------------------------
class TMonitorForm1 : public TForm
{
__published:	// IDE-managed Components
    TMemo *Memo1;
    TMemo *Memo2;
    TLabel *Label1;
    void __fastcall FormClose(TObject *Sender, TCloseAction &Action);
private:	// User declarations
public:		// User declarations
    __fastcall TMonitorForm1(TComponent* Owner);
};
//---------------------------------------------------------------------------
extern PACKAGE TMonitorForm1 *MonitorForm1;
//---------------------------------------------------------------------------
#endif
