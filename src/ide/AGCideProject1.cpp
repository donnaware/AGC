//---------------------------------------------------------------------------
#include <vcl.h>
#pragma hdrstop
//---------------------------------------------------------------------------
USEFORM("AGCSimUnit1.cpp", Form1);
USEFORM("MonitorUnit1.cpp", MonitorForm1);
USEFORM("PromptUnit1.cpp", PromptForm1);
USEFORM("ShowSourceUnit1.cpp", SourceCodeForm1);
USEFORM("About.cpp", AboutBox);
USEFORM("TabStopsUnit1.cpp", TabStopsForm1);
//---------------------------------------------------------------------------
WINAPI WinMain(HINSTANCE, HINSTANCE, LPSTR, int)
{
    try
    {
         Application->Initialize();
         Application->Title = "Apollo Automatic Guidance Computer Simulator";
         Application->HelpFile = "ngAGC.hlp";
         Application->CreateForm(__classid(TForm1), &Form1);
         Application->CreateForm(__classid(TMonitorForm1), &MonitorForm1);
         Application->CreateForm(__classid(TPromptForm1), &PromptForm1);
         Application->CreateForm(__classid(TSourceCodeForm1), &SourceCodeForm1);
         Application->CreateForm(__classid(TAboutBox), &AboutBox);
         Application->CreateForm(__classid(TTabStopsForm1), &TabStopsForm1);
         Application->Run();
    }
    catch (Exception &exception)
    {
         Application->ShowException(&exception);
    }
    catch (...)
    {
         try
         {
             throw Exception("");
         }
         catch (Exception &exception)
         {
             Application->ShowException(&exception);
         }
    }
    return 0;
}
//---------------------------------------------------------------------------
