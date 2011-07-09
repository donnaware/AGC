//---------------------------------------------------------------------------
//---------------------------------------------------------------------------
// console.cpp                                        Copyright (c) 2001
// This program allows you to fork the win32 console using redirected standard
// handles. I got this crap off the MS web page, I do not understand how half
// of it works, it is a miracle that it does. Good luck trying to understand it.
//---------------------------------------------------------------------------
//---------------------------------------------------------------------------
#include <windows.h>
#include <vcl\vcl.h>
#include <shellapi.h>
#include "PCDSKYUnit1.h"
#include "Watch.h"
//---------------------------------------------------------------------------
// Function prototypes:
// You will need to put these lines into you main program, this could be put
// into a header file, but it seems like a waste of time for 4 lines.
//---------------------------------------------------------------------------
bool open_con(char *cmdline);
bool close_con(void);
bool WriteConsole(char *write_buff, int size);
int  ReadConsole(char *str, int size);
//---------------------------------------------------------------------------

//---------------------------------------------------------------------------
// Function prototypes (these are not called outside of this module)
//---------------------------------------------------------------------------
static void DisplayError(char *pszAPI);
static void PrepAndLaunchRedirectedChild(char *cmdline,HANDLE hChildStdOut,HANDLE hChildStdIn,HANDLE hChildStdErr);
//---------------------------------------------------------------------------
static bool ErrorFlag = false;      // Error semaphore
static PROCESS_INFORMATION pi;      // persistent process information
static HANDLE  hOutputRead;         // Handle to send stuff to console
static HANDLE  hInputWrite;         // Handle to get stuff from fake console

//---------------------------------------------------------------------------
// Call this function to open the console window and execute the console
// type program (e.g. "cmd"), if it returns false then there was an error.
// Usually because it can not find the file, the either set the path ahead of
// time or give the full path name in cmdline.
//---------------------------------------------------------------------------
bool open_con(char *cmdline)
{
    HANDLE  hOutputWrite, hInputRead;
    HANDLE hOutputReadTmp, hInputWriteTmp, hErrorWrite;
    SECURITY_ATTRIBUTES sa;
    ErrorFlag = false;

    sa.nLength = sizeof(SECURITY_ATTRIBUTES);      // Set up the security attributes struct.
    sa.lpSecurityDescriptor = NULL;
    sa.bInheritHandle       = TRUE;

    if(!CreatePipe(&hOutputReadTmp,&hOutputWrite,&sa,0)) DisplayError("CreatePipe");  // Create the child output pipe.
    if(!CreatePipe(&hInputRead,&hInputWriteTmp,&sa,0))   DisplayError("CreatePipe");  // Create the child input pipe.

    if(!DuplicateHandle(GetCurrentProcess(), hOutputWrite, GetCurrentProcess(), &hErrorWrite, 0,
                           TRUE, DUPLICATE_SAME_ACCESS))   DisplayError("DuplicateHandle");

    if(!DuplicateHandle(GetCurrentProcess(),hOutputReadTmp, GetCurrentProcess(), &hOutputRead,
                           0,FALSE, DUPLICATE_SAME_ACCESS))   DisplayError("DupliateHandle");

    if(!DuplicateHandle(GetCurrentProcess(),hInputWriteTmp,GetCurrentProcess(),
                           &hInputWrite, 0,FALSE, DUPLICATE_SAME_ACCESS))   DisplayError("DupliateHandle");

    if(!CloseHandle(hOutputReadTmp)) DisplayError("CloseHandle Out"); // Close inheritable copies  of handles
    if(!CloseHandle(hInputWriteTmp)) DisplayError("CloseHandle int");

    PrepAndLaunchRedirectedChild(cmdline, hOutputWrite, hInputRead,hErrorWrite);

    if(!CloseHandle(hOutputWrite)) DisplayError("CloseHandle Out 1"); // Close un-needed pipes
    if(!CloseHandle(hInputRead ))  DisplayError("CloseHandle In 1");
    if(!CloseHandle(hErrorWrite))  DisplayError("CloseHandle Err 1");

    // -------------------------
    // Redirection is complete
    // -------------------------

    return(ErrorFlag);
}
//---------------------------------------------------------------------------
// Call this to close things out or to force it closed, can be called from
// your program (e.g. user clicks exit then call this)
//---------------------------------------------------------------------------
bool close_con(void)
{
    ErrorFlag = false;  // clear error semaphore
    if(!CloseHandle(hOutputRead)) DisplayError("CloseHandle Out 2");
    if(!CloseHandle(hInputWrite)) DisplayError("CloseHandle In 2");
    TerminateProcess(pi.hProcess,GetLastError());  // safety measure
    return(ErrorFlag);  // report any error occurances
}
//---------------------------------------------------------------------------
// PrepAndLaunchRedirectedChild
// Sets up STARTUPINFO structure, and launches redirected child, or something.
//---------------------------------------------------------------------------
static void PrepAndLaunchRedirectedChild(char *cmdline, HANDLE hChildStdOut,HANDLE hChildStdIn,HANDLE hChildStdErr)
{
    STARTUPINFO si;
    ZeroMemory(&si,sizeof(STARTUPINFO));                // Set up the start up info struct.
    si.cb          = sizeof(STARTUPINFO);
    si.dwFlags     = STARTF_USESTDHANDLES | STARTF_USESHOWWINDOW;  // Note that dwFlags must
    si.hStdOutput  = hChildStdOut;   // include STARTF_USESHOWWINDOW if you want to  use the wShowWindow flags.
    si.hStdInput   = hChildStdIn;
    si.hStdError   = hChildStdErr;
    si.wShowWindow = SW_HIDE;  // Use this if you want to hide the child:

    // Launch the process that you want to redirect (in this case, cmdline).
    // Make sure cmdline string is in the same directory as this program
    // launch redirect from a command line to prevent location confusion.
    if (!CreateProcess(NULL, cmdline, NULL, NULL, TRUE, CREATE_NEW_CONSOLE,
                            NULL,NULL,&si,&pi)) DisplayError("CreateProcess");

    if(!CloseHandle(pi.hThread)) DisplayError("CloseHandle Thread error");    // Close any unnecessary handles.
}

//---------------------------------------------------------------------------
// Reads up to size bytes from the console output pipe and return it into
// a buffer pointed to by lpBuffer. The number of bytes read is returned/
// If there was nothing to read then it returns 0. The peek a boo keeps it
// from bombing out when there is nothing to read.
//---------------------------------------------------------------------------
int ReadConsole(char *lpBuffer, int size)
{
    unsigned long nBytesRead;
    int bytesread;
    int ret;

    ret = PeekNamedPipe(hOutputRead,lpBuffer,size-1,&nBytesRead,NULL,NULL);
    if(ret == 0 || nBytesRead == 0) return(0); // if nothing there then skip it

    ret = ReadFile(hOutputRead,lpBuffer,size-1,&nBytesRead,NULL);
    if(ret == 0 || nBytesRead == 0) bytesread = 0;
    else                            bytesread = nBytesRead;
    return(bytesread);  // return the number of bytes read out 
}

//---------------------------------------------------------------------------
// Write to Consoles input pipe, call this function to send characters into
// the console (as if you typed them in. The characters you are sending
// are pointed to by write_buff and you need to tell it how many in there
// to send with the size parameter.
//---------------------------------------------------------------------------
bool WriteConsole(char *write_buff, int size)
{
    unsigned long nBytesToWrite, nBytesWrote;
    nBytesToWrite = (unsigned long) size;
    int ret = WriteFile(hInputWrite, write_buff, nBytesToWrite, &nBytesWrote, NULL);
    if(ret) ErrorFlag = false;  // Pipe was closed (normal exit path).
    else    DisplayError("WriteFile error");
    return(ErrorFlag);
}

//---------------------------------------------------------------------------
// DisplayError: Displays the error number and corresponding message.
//---------------------------------------------------------------------------
static void DisplayError(char *pszAPI)
{
    LPVOID lpvMessageBuffer;
    CHAR szPrintBuffer[512];
    DWORD nCharsWritten;

    FormatMessage(FORMAT_MESSAGE_ALLOCATE_BUFFER|FORMAT_MESSAGE_FROM_SYSTEM,
                NULL, GetLastError(),MAKELANGID(LANG_NEUTRAL, SUBLANG_DEFAULT),
                (LPTSTR)&lpvMessageBuffer, 0, NULL);

    wsprintf(szPrintBuffer,"ERROR: API    = %s.\n   error code = %d.\n   message    = %s.\n",
                pszAPI, GetLastError(), (char *)lpvMessageBuffer);

    Application->MessageBox(szPrintBuffer,"Error",MB_OK);
    LocalFree(lpvMessageBuffer);
    ErrorFlag = true;
}
//---------------------------------------------------------------------------

