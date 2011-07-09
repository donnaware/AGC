//---------------------------------------------------------------------------
#include <vcl.h>
#include <stdio.h>
#pragma hdrstop
#include "PCDSKYUnit1.h"
#include "Watch.h"
//---------------------------------------------------------------------------
#pragma package(smart_init)
#pragma resource "*.dfm"
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
AnsiString LockDev = "device_lock -timeout 100";
AnsiString SendIR1 = "device_virtual_ir_shift -instance_index 0 -ir_value 1 -no_captured_ir_value";
AnsiString SendIR2 = "device_virtual_ir_shift -instance_index 0 -ir_value 2 -no_captured_ir_value";
AnsiString SendIR3 = "device_virtual_ir_shift -instance_index 0 -ir_value 3 -no_captured_ir_value";
AnsiString SendDR1 = "device_virtual_dr_shift -instance_index 0 -length 8 -no_captured_dr_value -dr_value ";
AnsiString Get_DRI = "device_virtual_dr_shift -instance_index 0 -length 8";
AnsiString UnLockD = "device_unlock";
AnsiString CloseDv = "close_device";

//---------------------------------------------------------------------------
// Constants:
//---------------------------------------------------------------------------
#define INITDELAY   1000    // Initial delay on start
#define SENDDELAY      5    // Send delay

//---------------------------------------------------------------------------
__fastcall TForm1::TForm1(TComponent* Owner) : TForm(Owner)
{
    process_running = false;   // process is not running to start things off

    Keypad       = 0x00;
    OutputSelect = 0x00;
    Outputdata   = 0x00;
}
//---------------------------------------------------------------------------
void __fastcall TForm1::FormShow(TObject *Sender)
{
    DisplayPanel->Color = clBlack;
}
//---------------------------------------------------------------------------
void __fastcall TForm1::ExitButton1Click(TObject *Sender)
{
    Close();
}
//---------------------------------------------------------------------------
void __fastcall TForm1::FormClose(TObject *Sender, TCloseAction &Action)
{
    CloseConButton1->Click();  // in case the user forgot to close it, do it for them
}
//---------------------------------------------------------------------------
void __fastcall TForm1::ShowMonitorButton1Click(TObject *Sender)
{
    if(WatchWin->Visible) {
        ShowMonitorButton1->Caption = "Show Monitor";
        WatchWin->Hide();
    }
    else {
        ShowMonitorButton1->Caption = "Hide Monitor";
        WatchWin->Show();
    }
}
//---------------------------------------------------------------------------
void __fastcall TForm1::CloseMonitor(void)
{
    WatchWin->Hide();
    ShowMonitorButton1->Caption = "Show Monitor";
}
//---------------------------------------------------------------------------
void __fastcall TForm1::LoadConfigurationButton1Click(TObject *Sender)
{
    ShellExecute(NULL,NULL,"quartus_pgm","-cUSB-Blaster -mJTAG --o=P;agc.sof",NULL,SW_SHOWNORMAL);
    StatusBar1->Panels->Items[1]->Text = "Launched DE0 Board Configurator";
}
//---------------------------------------------------------------------------

//---------------------------------------------------------------------------
//
//  Virtual JTAG Console Secion
//
//---------------------------------------------------------------------------
void __fastcall TForm1::OpenConButton1Click(TObject *Sender)
{
    StatusBar1->Panels->Items[0]->Text = "Openning virtual console...";
    AnsiString Program;     // this is the program we want to run under the covers
    Program = "quartus_stp -s";
    if(WatchWin->Visible) WatchWin->WatchMemo->Clear(); // Clear the Watch Window
    if(open_con(Program.c_str())) { // Open the fake console up running the program
        StatusBar1->Panels->Items[0]->Text = "An error occurred trying to connect";
        return;
    }
    StatusBar1->Panels->Items[0]->Text = "Connected to stp.../";
    process_running = true;     // set the semaphore
    Sleep(INITDELAY);             // wait a couple of seconds to get going
    for(int i = 0; i < 10; i++) {
        if(GetResultString() == 0) break;   // get all the crap out of the way
        Sleep(SENDDELAY);
    }
    StatusBar1->Panels->Items[0]->Text = "Opening virtual jtag line...";
    Sleep(SENDDELAY);
    SendAndGet(Set_USB);    // Set the USB variable
    SendAndGet(Set_DEV);    // Set the Device variable
    SendAndGet(OpenDev);    // now open that device
    Sleep(SENDDELAY);
    StatusBar1->Panels->Items[0]->Text = "Connected!";
}
//---------------------------------------------------------------------------
void __fastcall TForm1::CloseConButton1Click(TObject *Sender)
{
    if(process_running) {           // Only do this junk if console is opened
//        SendAndGet(UnLockD);        // Unlock the device just in case it is locked
        SendAndGet(CloseDv);        // Close the device down
        close_con();                // Close down the virtual console
        process_running = false;    // Set process semaphore to off
    }
//    CloseMonitor();       // if the winder is open, shut it too
    StatusBar1->Panels->Items[0]->Text = "Not Connected.";
}
//---------------------------------------------------------------------------
// Send a command string to our fake console
//---------------------------------------------------------------------------
void __fastcall TForm1::SendCommandString(AnsiString Command)
{
    StatusBar1->Panels->Items[0]->Text = "Sending string to console";
    WatchWin->WatchAppend(Command);
//    WatchWin->WatchOut(Command);

    char write_buff[256];   // a buffer for this command string
    strncpy(write_buff, Command.c_str(), 256); // make a copy of it
    int len = Command.Length();   // what is the lenght of this string ?
    write_buff[len++] = 0x0D;
    write_buff[len++] = 0x0A;       // ya have to pretend like ya hit enter
    WriteConsole(write_buff, len);  // then send it to the console
    StatusBar1->Panels->Items[0]->Text = "Idle.";
}
//---------------------------------------------------------------------------
// Get any response the program made and return it in AnsiString holder
//---------------------------------------------------------------------------
int __fastcall TForm1::GetResultString(void)
{
    StatusBar1->Panels->Items[0]->Text = "Reading console output...";
    char read_buff[256];
    int bytesread = ReadConsole(read_buff, sizeof(read_buff));
    if(bytesread) {
        read_buff[bytesread-1] = '\0';          // lop off the LF
        ResultString = AnsiString(read_buff);   // Get the resulting output
        WatchWin->WatchOut(ResultString);       // Show it on the console monitor
        StatusBar1->Panels->Items[0]->Text = "Idle.";
    }
    else {
        StatusBar1->Panels->Items[0]->Text = "No console output.";
    }
    return(bytesread);
}
//---------------------------------------------------------------------------
// Send a command then wait for stuff to come back
//---------------------------------------------------------------------------
void __fastcall TForm1::SendAndGet(AnsiString Command)
{
    SendCommandString(Command);     // Send the command string
    for(int i = 0; i < 100; i++) {
        Sleep(1);                  // Delay a little bit of time
        if(GetResultString() != 0) break;  // wait for stuff to come back
    }
}
//---------------------------------------------------------------------------
// Converts an integer into a binary string
//---------------------------------------------------------------------------
void __fastcall TForm1::getbinary(int val)
{
    binary_string = "11111111";
    for(int i = 0; i < 8; i++) {
        binary_string[8-i] = '0' + val%2;  // a stupid algorithm
        val /= 2;
    }
}
//---------------------------------------------------------------------------
void __fastcall TForm1::binarystringToInt(void)
{
    Inputdata = 0x00;
    if(ResultString[8] == '1') Inputdata |= 0x01;
    if(ResultString[7] == '1') Inputdata |= 0x02;
    if(ResultString[6] == '1') Inputdata |= 0x04;
    if(ResultString[5] == '1') Inputdata |= 0x08;
    if(ResultString[4] == '1') Inputdata |= 0x10;
    if(ResultString[3] == '1') Inputdata |= 0x20;
    if(ResultString[2] == '1') Inputdata |= 0x40;
    if(ResultString[1] == '1') Inputdata |= 0x80;
}
//---------------------------------------------------------------------------
void __fastcall TForm1::SetSelect(void)
{
    getbinary(OutputSelect);
    AnsiString Value = binary_string;
    SendAndGet(LockDev);            // Lock the device
    SendAndGet(SendIR1);            // Send the instruction code
    SendAndGet(SendDR1 + Value);    // Send the data
    SendAndGet(SendIR2);            // Send the instruction code to get the result
    SendAndGet(Get_DRI);            // now get the result
    binarystringToInt();            // And convert it to a number
    SendAndGet(UnLockD);        // Unlock the device just in case it is locked
}
//---------------------------------------------------------------------------

//---------------------------------------------------------------------------
// Send command to turn on the MCU test lamp
//---------------------------------------------------------------------------
void __fastcall TForm1::FPGALEDButton1Click(TObject *Sender)
{
    if(FPGALEDButton1->Caption == "FPGA Test On") {
        FPGALEDButton1->Caption = "FPGA Test Off";
        OutputSelect = 0x80;
        SetSelect();
    }
    else {
        FPGALEDButton1->Caption = "FPGA Test On";
        OutputSelect = 0x00;
        SetSelect();
    }
}

//---------------------------------------------------------------------------
// Get 1 data register from AGC
//---------------------------------------------------------------------------
void __fastcall TForm1::GetDSKYReg(int reg)
{
    OutputSelect = reg;
    getbinary(OutputSelect);
    AnsiString Select  = binary_string;
    SendAndGet(LockDev);                // Lock the device
    SendAndGet(SendIR1);                // Send the instruction code
    SendAndGet(SendDR1 + Select);       // Send the data
    SendAndGet(SendIR2);                // Send the instruction code to get the result
    SendAndGet(Get_DRI);                // now get the result
    binarystringToInt();                // And convert it to a number
    SendAndGet(UnLockD);                // Unlock the device just in case it is locked

}
//---------------------------------------------------------------------------
// Get display data from AGC
//---------------------------------------------------------------------------
void __fastcall TForm1::UpdateDSKY(void)
{
    AnsiString Testdata =  "Test: ";

    GetDSKYReg(0x00);   // Test register, always reads 0x55
    Testdata = Testdata + IntToHex(Inputdata,2) + " ";

    GetDSKYReg(0x0D);   // Test register, always reads 0x55
    Testdata = Testdata + IntToHex(Inputdata,2) + " ";

    GetDSKYReg(0x0F);   // Test register, always reads 0x55
    Testdata = Testdata + IntToHex(Inputdata,2) + " ";

    StatusBar1->Panels->Items[1]->Text = Testdata;

    GetDSKYReg(0x0B);                       // Mode Register
    display[1] = (Inputdata >>   4) + '0';
    display[2] = (Inputdata & 0x0F) + '0';

    GetDSKYReg(0x0A);                       // Verb Register
    display[3] = (Inputdata >>   4) + '0';  // V2
    display[4] = (Inputdata & 0x0F) + '0';  // V1

    GetDSKYReg(0x09);                       // Noun Register
    display[5] = (Inputdata >>   4) + '0';  // N2
    display[6] = (Inputdata & 0x0F) + '0';  // N1

    GetDSKYReg(0x08);                       // R1D1 Register
//  display[7] = (Inputdata >>   4) + '0';  // R1D1
    display[7] = (Inputdata & 0x0F) + '0';  // Not used

    GetDSKYReg(0x07);                       // R1D2D3 Register
    display[8] = (Inputdata >>   4) + '0';  // R1D2
    display[9] = (Inputdata & 0x0F) + '0';  // R1D3

    GetDSKYReg(0x06);                       // R1D4D5 Register
    display[10] = (Inputdata >>   4) + '0'; // R1D4
    display[11] = (Inputdata & 0x0F) + '0'; // R1D5

    GetDSKYReg(0x05);                       // R2D1D2 Register
    display[12] = (Inputdata >>   4) + '0'; // R2D1
    display[13] = (Inputdata & 0x0F) + '0'; // R2D2

    GetDSKYReg(0x04);                       // R2D3D4 Register
    display[14] = (Inputdata >>   4) + '0'; // R2D3
    display[15] = (Inputdata & 0x0F) + '0'; // R2D4

    GetDSKYReg(0x03);                       // R2D5R3D1 Register
    display[16] = (Inputdata >>   4) + '0'; // R2D5
    display[17] = (Inputdata & 0x0F) + '0'; // R3D1

    GetDSKYReg(0x02);                       // R3D2D3 Register
    display[18] = (Inputdata >>   4) + '0'; // R3D2
    display[19] = (Inputdata & 0x0F) + '0'; // R3D3

    GetDSKYReg(0x01);                       // R3D4D5 Register
    display[20] = (Inputdata >>   4) + '0'; // R3D4
    display[21] = (Inputdata & 0x0F) + '0'; // R3D5

    GetDSKYReg(0x0C);                       // DSCP Register
    if(Inputdata & 0x01) display[24] = '-'; // -R3S
    if(Inputdata & 0x02) display[24] = '+'; // -R3S
    if(Inputdata & 0x04) display[23] = '-'; // -R3S
    if(Inputdata & 0x08) display[23] = '+'; // -R3S
    if(Inputdata & 0x10) display[22] = '-'; // -R3S
    if(Inputdata & 0x20) display[22] = '+'; // -R3S

    if(Inputdata & 0x80) LAMP_UPLINKACTY->Color = clLime;
    else                 LAMP_UPLINKACTY->Color = clGray;

    UpdateAll();
}
//---------------------------------------------------------------------------
void __fastcall TForm1::RefreshDisplayButton1Click(TObject *Sender)
{
    StatusBar1->Panels->Items[0]->Text = "Refreshing..."; Update();
    UpdateDSKY();
    StatusBar1->Panels->Items[0]->Text = "Idle.";
}
//---------------------------------------------------------------------------

//---------------------------------------------------------------------------
//  Segments:
//    1
//    -
//  2|7|6
//    -
//  3| |5
//    -         Panel5
//    4
//---------------------------------------------------------------------------
TColor segtable[11][7] = {
//   Segment1  Segment2  Segment3  Segment4  Segment5  Segment6  Segment7
    {COLOR_ON, COLOR_ON, COLOR_ON, COLOR_ON, COLOR_ON, COLOR_ON, COLOR_OFF}, // 0
    {COLOR_OFF,COLOR_OFF,COLOR_OFF,COLOR_OFF,COLOR_ON, COLOR_ON, COLOR_OFF}, // 1
    {COLOR_ON, COLOR_OFF,COLOR_ON ,COLOR_ON, COLOR_OFF,COLOR_ON, COLOR_ON }, // 2
    {COLOR_ON, COLOR_OFF,COLOR_OFF,COLOR_ON, COLOR_ON ,COLOR_ON, COLOR_ON }, // 3
    {COLOR_OFF,COLOR_ON, COLOR_OFF,COLOR_OFF,COLOR_ON, COLOR_ON, COLOR_ON }, // 4
    {COLOR_ON, COLOR_ON, COLOR_OFF,COLOR_ON, COLOR_ON, COLOR_OFF,COLOR_ON }, // 5
    {COLOR_ON, COLOR_ON, COLOR_ON, COLOR_ON, COLOR_ON, COLOR_OFF,COLOR_ON }, // 6
    {COLOR_ON, COLOR_OFF,COLOR_OFF,COLOR_OFF,COLOR_ON, COLOR_ON, COLOR_OFF}, // 7
    {COLOR_ON, COLOR_ON, COLOR_ON, COLOR_ON, COLOR_ON, COLOR_ON, COLOR_ON }, // 8
    {COLOR_ON, COLOR_ON, COLOR_OFF,COLOR_OFF,COLOR_ON, COLOR_ON, COLOR_ON }, // 9
    {COLOR_OFF,COLOR_OFF,COLOR_OFF,COLOR_OFF,COLOR_OFF,COLOR_OFF,COLOR_OFF}  // Blank
};
//---------------------------------------------------------------------------
TPoint seg[11][9] ={
 {Point( 8, 3),Point( 8, 5),Point(11, 8),Point(28, 8),Point(31, 5),Point(31, 3),Point(29, 1),Point(10, 1),Point( 9, 3)},
 {Point( 5, 6),Point( 2, 9),Point( 2,21),Point( 5,24),Point( 7,24),Point(10,21),Point(10, 9),Point( 7, 6),Point( 6, 7)},
 {Point( 5,26),Point( 2,29),Point( 2,40),Point( 5,43),Point( 8,43),Point(10,41),Point(10,29),Point( 7,26),Point( 6,27)},
 {Point( 9,46),Point(11,48),Point(28,48),Point(30,46),Point(30,44),Point(27,41),Point(12,41),Point( 9,44),Point(10,46)},
 {Point(31,43),Point(34,43),Point(37,40),Point(37,29),Point(34,26),Point(32,26),Point(29,29),Point(29,41),Point(33,42)},
 {Point(32,24),Point(34,24),Point(37,21),Point(37, 9),Point(34, 6),Point(32, 6),Point(29, 9),Point(29,21),Point(33,23)},
 {Point( 9,26),Point(11,28),Point(28,28),Point(30,26),Point(30,24),Point(27,21),Point(12,21),Point( 9,24),Point(10,25)},
 {Point( 3,22),Point( 1,24),Point( 1,25),Point( 3,27),Point(16,27),Point(18,25),Point(18,24),Point(16,22),Point( 3,25)},
 {Point( 9,13),Point( 7,15),Point( 7,20),Point(12,20),Point(12,15),Point(10,13),Point( 9,13),Point( 7,15),Point( 9,15)},
 {Point( 9,36),Point(10,36),Point(12,34),Point(12,29),Point( 7,29),Point( 7,34),Point( 9,36),Point(10,36),Point( 9,33)}
};
//---------------------------------------------------------------------------
int __fastcall TForm1::GetSegIndex(char value)
{
    int inx;
    if(value >= '0' && value <= '9') inx = value - '0'; // convert to index
    else                             inx = 10;         // show all segments blank
    return(inx);
}
//---------------------------------------------------------------------------
void __fastcall TForm1::PaintSegment(TPaintBox *pb, int segno, TColor segcol)
{
    pb->Canvas->Pen->Width   = 1;
    pb->Canvas->Pen->Style   = psSolid;
    pb->Canvas->Pen->Color   = segcol;
    pb->Canvas->Brush->Color = segcol;
    pb->Canvas->Polygon(seg[segno],7); pb->Canvas->FloodFill(seg[segno][8].x,seg[segno][8].y,segcol,fsBorder);
}
//---------------------------------------------------------------------------
void __fastcall TForm1::PaintBox1Paint(TObject *Sender)
{
    TPaintBox *pb = (TPaintBox *)Sender;
    pb->Canvas->Brush->Style = bsSolid;
    pb->Canvas->Brush->Color = clBlack;
    pb->Canvas->FillRect(Rect(0,0,pb->Width,pb->Height));

    if(pb->Tag < 22) {
        int si = GetSegIndex(display[pb->Tag]);
        for(int i = 0; i < 7; i++) {
            PaintSegment(pb, i, segtable[si][i]);
        }
    }
    else {
        int si;
        if(display[pb->Tag] == '+') {
            PaintSegment(pb, 7, COLOR_ON);
            PaintSegment(pb, 8, COLOR_ON);
            PaintSegment(pb, 9, COLOR_ON);
        }
        else
        if(display[pb->Tag] == '-') {
            PaintSegment(pb, 7, COLOR_ON );
            PaintSegment(pb, 8, COLOR_OFF);
            PaintSegment(pb, 9, COLOR_OFF);
        }
        else {
            PaintSegment(pb, 7, COLOR_OFF);
            PaintSegment(pb, 8, COLOR_OFF);
            PaintSegment(pb, 9, COLOR_OFF);
        }
    }
}
//---------------------------------------------------------------------------
void __fastcall TForm1::UpdateAll(void)
{
    for(int i = 0; i < DisplayPanel->ControlCount; i++) {
        DisplayPanel->Controls[i]->Repaint();
    }
}
//---------------------------------------------------------------------------
void __fastcall TForm1::LampTest(TColor lampstate)
{
    LAMP_UPLINKACTY->Color = lampstate;
    LAMP_TEMP      ->Color = lampstate;
    LAMP_NOATT     ->Color = lampstate;
    LAMP_GIMBALLOCK->Color = lampstate;
    LAMP_KEYREL    ->Color = lampstate;
    LAMP_RESTART   ->Color = lampstate;
    LAMP_OPPERR    ->Color = lampstate;
    LAMP_TRACKER   ->Color = lampstate;
    LAMP_ALT       ->Color = lampstate;
    LAMP_VEL       ->Color = lampstate;
    LAMP_BLANK1    ->Color = lampstate;
    LAMP_BLANK2    ->Color = lampstate;
    LAMP_COMPACTY  ->Color = lampstate;
}
//---------------------------------------------------------------------------
void __fastcall TForm1::keypress(keyInType keypad)
{
    Keypad = (byte)keypad;

    getbinary(Keypad);
    AnsiString Keydata  = binary_string;
    SendAndGet(LockDev);            // Lock the device
    SendAndGet(SendIR3);            // Send the instruction code
    SendAndGet(SendDR1 + Keydata);  // Send the data
    SendAndGet(SendIR2);            // Send the instruction code to get the result
    SendAndGet(Get_DRI);            // now get the result
    SendAndGet(UnLockD);        // Unlock the device just in case it is locked
}
//---------------------------------------------------------------------------
void __fastcall TForm1::DSKY_Button_0Click(TObject *Sender)
{
    dskey = (char)((TButton *)Sender)->Tag;
    switch(dskey) {
		case '0': keypress(KEYIN_0);           break;
		case '1': keypress(KEYIN_1);           break;
		case '2': keypress(KEYIN_2);           break;
		case '3': keypress(KEYIN_3);           break;
		case '4': keypress(KEYIN_4);           break;
		case '5': keypress(KEYIN_5);           break;
		case '6': keypress(KEYIN_6);           break;
		case '7': keypress(KEYIN_7);           break;
		case '8': keypress(KEYIN_8);           break;
		case '9': keypress(KEYIN_9);           break;
		case '+': keypress(KEYIN_PLUS);        break;
		case '-': keypress(KEYIN_MINUS);       break;
		case '.': keypress(KEYIN_CLEAR);       break;
		case '/': keypress(KEYIN_VERB);        break;
		case '*': keypress(KEYIN_NOUN);        break;
		case 'g': keypress(KEYIN_KEY_RELEASE); break;
		case 'h': keypress(KEYIN_ERROR_RESET); break;
		case 'j': keypress(KEYIN_ENTER);       break;
    }
}

//---------------------------------------------------------------------------




