Declare DelOldFiles(Folder.s, Filtre.s = "*.*", NbDay.l = 365)

Procedure DelOldFiles(Folder.s, Filtre.s = "*.*", NbDay.l = 365)
  Protected DateRef.i = AddDate(Date(), #PB_Date_Day, -NbDay)
  CompilerIf #PB_Compiler_OS = #PB_OS_Windows
    If Right(Folder,1) = "\" : Folder + "\" :EndIf
  CompilerElse
    If Right(Folder,1) = "/" : Folder + "/" :EndIf
  CompilerEndIf
  If FindString("/\", Right(Folder,1),1) = 0
    Folder + "/"
  EndIf
  If FileSize(Folder) <> -2 : ProcedureReturn : EndIf
  If ExamineDirectory(0, Folder, Filtre)
    While NextDirectoryEntry(0)
      If DirectoryEntryType(0) = #PB_DirectoryEntry_File
        If GetFileDate(Folder + DirectoryEntryName(0), #PB_Date_Modified) < DateRef
          DeleteFile(Folder + DirectoryEntryName(0), #PB_FileSystem_Force)
        EndIf
      EndIf
    Wend
    FinishDirectory(0)
  EndIf
EndProcedure

; IDE Options = PureBasic 5.71 LTS (Windows - x64)
; Folding = -
; EnableXP