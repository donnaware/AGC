//---------------------------------------------------------------------------
#include <vcl.h>
#pragma hdrstop
#include "ConsoleUnit1.h"
#include "Watch.h"
//---------------------------------------------------------------------------
#pragma package(smart_init)
#pragma resource "*.dfm"
//---------------------------------------------------------------------------
TForm1 *Form1;
//---------------------------------------------------------------------------
//    Function prototypes:
//    Located in module RunProg.cpp
//---------------------------------------------------------------------------
bool open_con(char *cmdline);
bool close_con(void);
bool WriteConsole(char *write_buff, int size);
int  ReadConsole(char *str, int size);

//---------------------------------------------------------------------------
// Command Codes:
// parameter  SEL   	= 3'b001;		// single write transaction
// parameter  POP   	= 3'b010;		// single read  transaction
// parameter  KEY   	= 3'b011;		// select output
// parameter  NOP		= 3'b111;		// not used
//
// Command Strings:
//---------------------------------------------------------------------------
AnsiString Set_USB = "set usb [lindex [get_hardware_names] 0]";
AnsiString Set_DEV = "set device_name [lindex [get_device_names -hardware_name $usb] 0]";
AnsiString OpenDev = "open_device -device_name $device_name -hardware_name $usb";
AnsiString LockDev = "device_lock -timeout 10000";
AnsiString SendIR1 = "device_virtual_ir_shift -instance_index 0 -ir_value 1 -no_captured_ir_value";
AnsiString SendDR1 = "device_virtual_dr_shift -instance_index 0 -length 8 -no_captured_dr_value -dr_value ";
AnsiString SendIR2 = "device_virtual_ir_shift -instance_index 0 -ir_value 2 -no_captured_ir_value";
AnsiString Get_DRI = "device_virtual_dr_shift -instance_index 0 -length 8";
AnsiString UnLockD = "device_unlock";
AnsiString CloseDv = "close_device";

//---------------------------------------------------------------------------
// Constants:
//---------------------------------------------------------------------------
#define INITDELAY   1000    // Initial delay on start
#define SENDDELAY    100    // Send delay

//---------------------------------------------------------------------------
__fastcall TForm1::TForm1(TComponent* Owner) : TForm(Owner)
{
    process_running = false;   // process is not running to start things off
}
//---------------------------------------------------------------------------
void __fastcall TForm1::FormCreate(TObject *Sender)
{
    TestHeight = Height;
    Height = TestHeight - TestPanel1->Height;
}
//---------------------------------------------------------------------------
void __fastcall TForm1::FormClose(TObject *Sender, TCloseAction &Action)
{
    CloseButton1->Click();  // in case the user forgot to close it, do it for them
}
//---------------------------------------------------------------------------
void __fastcall TForm1::ExitButton2Click(TObject *Sender)
{
    Close();    // user wants to be a quiter
}
//---------------------------------------------------------------------------
void __fastcall TForm1::ConWinCheckBox1Click(TObject *Sender)
{
    WatchWin->Visible = ConWinCheckBox1->Checked; // do you want to watch stuff ?
}
//---------------------------------------------------------------------------
void __fastcall TForm1::TestPanelCheckBox1Click(TObject *Sender)
{
    TestPanel1->Visible = TestPanelCheckBox1->Checked;
    if(TestPanel1->Visible) Height = TestHeight;
    else                    Height = TestHeight - TestPanel1->Height;

}
//---------------------------------------------------------------------------
void __fastcall TForm1::OpenButton1Click(TObject *Sender)
{
    StatusBar1->SimpleText = "Openning virtual console...";
    AnsiString Program;     // this is the program we want to run under the covers
    Program = "quartus_stp -s";
    if(WatchWin->Visible) WatchWin->WatchMemo->Clear(); // Clear the Watch Window
    if(open_con(Program.c_str())) { // Open the fake console up running the program
        StatusBar1->SimpleText = "An error occurred trying to connect";
        return;
    }
    StatusBar1->SimpleText = "Connected to stp.../";
    process_running = true;     // set the semaphore
    Sleep(INITDELAY);             // wait a couple of seconds to get going
    for(int i = 0; i < 10; i++) {
        if(GetResultString() == 0) break;   // get all the crap out of the way
        Sleep(SENDDELAY);
    }
    StatusBar1->SimpleText = "Opening virtual jtag line...";
    Sleep(SENDDELAY);
    SendAndGet(Set_USB);    // Set the USB variable
    SendAndGet(Set_DEV);    // Set the Device variable
    SendAndGet(OpenDev);    // now open that device
    Sleep(SENDDELAY);
    StatusBar1->SimpleText = "Connected!";
}
//---------------------------------------------------------------------------
void __fastcall TForm1::CloseButton1Click(TObject *Sender)
{
    if(process_running) {           // Only do this junk if console is opened
        SendAndGet(UnLockD);        // Unlock the device just in case it is locked
        SendAndGet(CloseDv);        // Close the device down
        close_con();                // Close down the virtual console
        process_running = false;    // Set process semaphore to off
    }
    ConWinCheckBox1->Checked = false;  // if the winder is open, shut it too
    StatusBar1->SimpleText = "Not Connected.";
}
//---------------------------------------------------------------------------
// Send a command string to our fake console
//---------------------------------------------------------------------------
void __fastcall TForm1::SendCommandString(AnsiString Command)
{
    StatusBar1->SimpleText = "Sending string to console";
    char write_buff[256];   // a buffer for this command string
    strncpy(write_buff, Command.c_str(), 256); // make a copy of it
    int len = Command.Length();   // what is the lenght of this string ?
    write_buff[len++] = 0x0D;
    write_buff[len++] = 0x0A;       // ya have to pretend like ya hit enter
    WriteConsole(write_buff, len);  // then send it to the console
    StatusBar1->SimpleText = "Idle.";
}
//---------------------------------------------------------------------------
// Get any response the program made and return it in AnsiString holder
//---------------------------------------------------------------------------
int __fastcall TForm1::GetResultString(void)
{
    StatusBar1->SimpleText = "Reading console output...";
    char read_buff[256];
    int bytesread = ReadConsole(read_buff, sizeof(read_buff));
    if(bytesread) {
        read_buff[bytesread-1] = '\0';          // lop off the LF
        ResultString = AnsiString(read_buff);   // Get the resulting output
        WatchWin->WatchOut(ResultString);       // Show it on the console monitor
        StatusBar1->SimpleText = "Idle.";
    }
    else {
        StatusBar1->SimpleText = "No console output.";
    }
    return(bytesread);
}
//---------------------------------------------------------------------------
// Send a command then wait for stuff to come back
//---------------------------------------------------------------------------
void __fastcall TForm1::SendAndGet(AnsiString Command)
{
    SendCommandString(Command);     // Send the command string
    for(int i = 0; i < 10; i++) {
        Sleep(SENDDELAY);                  // Delay a little bit of time
        if(GetResultString() == 0) break;  // wait for stuff to come back
    }
}
//---------------------------------------------------------------------------
void __fastcall TForm1::SendStringButton1Click(TObject *Sender)
{
    SendCommandString(SendEdit1->Text);     // Send the test string
}
//---------------------------------------------------------------------------
void __fastcall TForm1::GetStringButton1Click(TObject *Sender)
{
    if(GetResultString()) ReadText1->Caption = ResultString;
}
//---------------------------------------------------------------------------
// Converts an integer into a binary string
//---------------------------------------------------------------------------
AnsiString __fastcall TForm1::getbinary(int val)
{
    AnsiString binary = "1111";
    for(int i = 0; i < 4; i++) {
        binary[4-i] = '0' + val%2;  // a stupid algorithm
        val /= 2;
    }
    return(binary);     // return binary string
}
//---------------------------------------------------------------------------
//  Update the values
//---------------------------------------------------------------------------
void __fastcall TForm1::UpdateValues(void)
{
    AnsiString Value, dig1, dig2;
    dig1 = getbinary(DIG_0->ItemIndex);
    dig2 = getbinary(DIG_1->ItemIndex);
    Value = dig2 + dig1;

    SendAndGet(LockDev);            // Lock the device
    SendAndGet(SendIR1);            // Send the instruction code
    SendAndGet(SendDR1 + Value);    // Send the data
    SendAndGet(SendIR2);            // Send the instruction code to get the result
    SendAndGet(Get_DRI);            // now get the result

    AnsiString binout = ResultString;             // Parse for output string
    StatusBar1->SimpleText = "Output =" + binout;

    if(binout[8] == '1') LED0->Brush->Color = clLime; else LED0->Brush->Color = TColor(0x00004000);
    if(binout[7] == '1') LED1->Brush->Color = clLime; else LED1->Brush->Color = TColor(0x00004000);
    if(binout[6] == '1') LED2->Brush->Color = clLime; else LED2->Brush->Color = TColor(0x00004000);
    if(binout[5] == '1') LED3->Brush->Color = clLime; else LED3->Brush->Color = TColor(0x00004000);
    if(binout[4] == '1') LED4->Brush->Color = clLime; else LED4->Brush->Color = TColor(0x00004000);
    if(binout[3] == '1') LED5->Brush->Color = clLime; else LED5->Brush->Color = TColor(0x00004000);
    if(binout[2] == '1') LED6->Brush->Color = clLime; else LED6->Brush->Color = TColor(0x00004000);
    if(binout[1] == '1') LED7->Brush->Color = clLime; else LED7->Brush->Color = TColor(0x00004000);
}
//---------------------------------------------------------------------------
void __fastcall TForm1::SetValuesButton1Click(TObject *Sender)
{
    if(process_running) {           // Only do this junk if console is opened
        StatusBar1->SimpleText = "Updating values...";
        UpdateValues();
    }
    else StatusBar1->SimpleText = "Virtual console not open.";
}
//---------------------------------------------------------------------------




