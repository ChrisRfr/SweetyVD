  Enumeration Font
    #FontWML
  EndEnumeration

  Declare.f AjustFontSize(Size.l)
  Declare LoadFontWML()

  Procedure.f AjustFontSize(lSize.l)   ;Windows DPI aware by using the font size based on the number of pixels per inch along the screen
    Define.i iimage
    Static.f fPpp
    CompilerIf #PB_Compiler_OS = #PB_OS_MacOS   ;How to with Mac retina display
      ProcedureReturn lSize
    CompilerElse
      If fPpp = 0
        iimage = CreateImage(#PB_Any,1,1)
        If IsImage(iimage)
          If StartVectorDrawing(ImageVectorOutput(iimage))
            fPpp = VectorResolutionX()
            StopVectorDrawing()
          EndIf
          FreeImage(iimage)
        EndIf
      EndIf
      ProcedureReturn (lSize * 96) / fPpp
    CompilerEndIf
  EndProcedure

  Procedure LoadFontWML()   ;Most common fonts on Windows, Mac, and linux/Unix OS with +- a similar size: Verdana, Arial, courrier New.
    If LoadFont(#FontWML, "Verdana", AjustFontSize(8))
      SetGadgetFont(#PB_Default, FontID(#FontWML))   ; Set the loaded Verdana 8 font as new default font for all Gadgets
    ElseIf LoadFont(#FontWML, "Arial", AjustFontSize(8))
      SetGadgetFont(#PB_Default, FontID(#FontWML))   ; Set the loaded Arial 8 font as new default font for all Gadgets
    EndIf                                            ;If not loaded: SetGadgetFont(#PB_Default, #PB_Default): set the font settings back to original standard font
  EndProcedure

; IDE Options = PureBasic 5.60 (Windows - x64)
; Folding = -
; EnableXP
