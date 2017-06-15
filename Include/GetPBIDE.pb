Declare.s GetPBIDE()

Global PBIDEpath.s

Procedure.s GetPBIDE()
  Protected IDEpath.s
  CompilerIf #PB_Compiler_Debugger
    If FileSize(#PB_Compiler_Home + #PB_IDE) > 0
      ProcedureReturn #PB_Compiler_Home + #PB_IDE
    EndIf
  CompilerEndIf

  IDEpath = GetEnvironmentVariable("PB_TOOL_IDE")   ;Runs as PB Customized tools
  If FileSize(IDEpath) > 0
    ProcedureReturn IDEpath
  EndIf

  IDEpath = GetEnvironmentVariable("PUREBASIC_HOME")   ;From PB Home directory variable Environment
  If IDEpath
    If FindString("/\", Right(IDEpath,1),1) = 0
      IDEpath + "/"
    EndIf
    If FileSize(IDEpath + #PB_IDE) > 0
      ProcedureReturn IDEpath + #PB_IDE
    EndIf
  EndIf

  CompilerIf #PB_Compiler_OS = #PB_OS_Windows
    Protected PBRegKey.s, hKey1.l = 0, Type.l = 0, Res.l = -1, cbData.l = 1024, lpbData.l = AllocateMemory(cbData)   ;1024: The PB entry is really quite long!
    If lpbData
      PBRegKey="Software\Classes\PureBasic.exe\shell\open\command"   ;XP to Win10
      Res=RegOpenKeyEx_(#HKEY_CURRENT_USER, PBRegKey, 0, #KEY_ALL_ACCESS , @hKey1)
      If Res = #ERROR_SUCCESS And hKey1
        If RegQueryValueEx_(hKey1, "", 0, @Type, lpbData, @cbData)=#ERROR_SUCCESS
          IDEpath = PeekS(lpbData)
          IDEpath = StringField(IDEpath,2,Chr(34))
        EndIf
        RegCloseKey_(hKey1)
      EndIf
      FreeMemory(lpbData)
      If FileSize(IDEpath) > 0
        ProcedureReturn IDEpath
      EndIf
    EndIf
  CompilerEndIf

  ProcedureReturn ""
EndProcedure

; IDE Options = PureBasic 5.60 (Windows - x64)
; Folding = -
; EnableXP