Declare.s GetTempFilename(BaseName.s, NbRamdomLetter.l, ext.s)

Procedure.s GetTempFilename(BaseName.s, NbRamdomLetter.l, ext.s)
  Protected i, filename$ = GetTemporaryDirectory() + BaseName
  For i = 0 To NbRamdomLetter
    filename$ + Chr('a'+Random(25))
  Next
  filename$ + ext
  If FileSize(filename$) = -1   ; If file does not exist, return the generated filename
    ProcedureReturn filename$
  Else                          ; Else: generate a new name
    ProcedureReturn GetTempFilename(BaseName.s, NbRamdomLetter.l, ext)
  EndIf
EndProcedure
; IDE Options = PureBasic 5.60 (Windows - x64)
; CursorPosition = 2
; Folding = -
; EnableXP