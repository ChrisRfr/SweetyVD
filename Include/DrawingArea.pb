Declare DrawContainer(X, Y, Width, Height)
Declare DrawFrame(X, Y, Width, Height, Text.s)
Declare DrawPanel(X, Y, Width, Height, Text.s = "Tab1")
Declare DrawScrollArea(X, Y, Width, Height, InnerW, InnerH, ScrollX, ScrollY)
Declare DrawMenuToolStatusBar()
Declare DrawGrid()
;Declare DrawFullDrawingArea()   ;Already declared in SweetyVDmodule.pbi for using it in SweetyVD.pb

Procedure DrawContainer(X, Y, Width, Height)
  DrawingMode(#PB_2DDrawing_Default)
  Line(X, Y, 1, Height-1, $696969)
  Line(X+1, Y+1, 1, Height-3, $A0A0A0)
  Line(X, Y, Width-1, 1, $696969)
  Line(X+1, Y+1, Width-3, 1, $A0A0A0)
  Line(X+Width-1, Y, 1, Height, $FFFFFF)
  Line(X+Width-2, Y+1, 1, Height-2, $999999)
  Line(X, Y+Height-1, Width, 1, $FFFFFF)
  Line(X+1, Y+Height-2, Width-2, 1, $999999)
EndProcedure

Procedure DrawFrame(X, Y, Width, Height, Text.s)
  Protected TextW, TextH
  If Text <> ""
    TextW = TextWidth(Text) : TextH = TextHeight(Text)
    If Height < TextH : Text = "" :EndIf
    While TextW + 15 > Width And Text <> ""
      Text = Left(Text, Len(Text)-1)
      TextW = TextWidth(Text)
    Wend
  Else
    TextW = TextWidth("X") : TextH = TextHeight("X")
  EndIf
  DrawingMode(#PB_2DDrawing_Default)
  Line(X, Y+TextH/2, 1, Height-TextH/2-1, $696969)
  Line(X+1, Y+TextH/2+1, 1, Height-TextH/2-3, $A0A0A0)
  Line(X, Y+TextH/2, Width-1, 1, $696969)
  Line(X+1, Y+TextH/2+1, Width-3, 1, $A0A0A0)
  Line(X+Width-1, Y+TextH/2, 1, Height-TextH/2, $FFFFFF)
  Line(X+Width-2, Y+TextH/2+1, 1, Height-TextH/2-2, $999999)
  Line(X, Y+Height-1, Width, 1, $FFFFFF)
  Line(X+1, Y+Height-2, Width-2, 1, $999999)
  If Text <> ""
    Box(X+10, Y+TextH/2, TextW+10, 2, #GridBackground)
    DrawingMode(#PB_2DDrawing_Transparent)
    DrawText(X+15, Y, Text, $000000)
  EndIf
EndProcedure

Procedure DrawPanel(X, Y, Width, Height, Text.s = "Tab1")
  Protected TextW, TextH, TabW, TabH, I.i, TmpTabName.s, ActiveTab.i=-1
  TextW = TextWidth(Text) / (CountString(Text, "|") + 1) : TabW = TextW+20
  TextH = TextHeight(Text) : TabH = 20
  If Height > TabH
        
    DrawingMode(#PB_2DDrawing_Default)
    Line(X, Y+TabH, 1, Height-TabH, $FFFFFF)
    Line(X+1, Y+TabH+1, 1, Height-TabH-1, $999999)
    Line(X, Y+TabH, Width, 1, $FFFFFF)
    Line(X+1, Y+TabH+1, Width-2, 1, $999999)
    ;Bottom and Right Border 
    Line(X+Width-1, Y+TabH+1, 1, Height-TabH-1,$696969)
    Line(X+Width-2, Y+TabH+1, 1, Height-TabH-2, $A0A0A0)
    Line(X+1, Y+Height-1, Width-1, 1, $696969)
    Line(X+1, Y+Height-2, Width-2, 1, $A0A0A0)

    For I=0 To CountString(Text, "|")   ;Draw Tab + Text (eg: "Tab1|Tab2(x)|Tab3"
      TmpTabName = Trim(StringField(Text, I+1, "|"))
      If TmpTabName <> ""
        DrawingMode(#PB_2DDrawing_Default)
        If Right(TmpTabName, 3) = "(x)"
          TmpTabName = Left(TmpTabName, Len(TmpTabName)-3)
          ActiveTab = I
          If (I*TabW)+TabW+1 <= Width
            If I = 0 : Line(X, Y, 1, TabH, $FFFFFF) : EndIf
            Box(X+I*TabW+1, Y, TabW-1, TabH+2, $F0F0F0)
            Line(X+I*TabW+1, Y, TabW-1, 1, $FFFFFF)
            Line(X+I*TabW+1, Y+1, TabW-2, 1, $999999)
            Line(X+I*TabW+1, Y+1, 1, TabH+1, $999999)
            Line(X+I*TabW+TabW, Y+1, 1, TabH+1, $696969)
            Line(X+I*TabW+TabW-1, Y+1, 1, TabH+1, $A0A0A0)
            DrawingMode(#PB_2DDrawing_Transparent)
            DrawText(X+I*TabW+8, Y+(TabH-TextH)/2, TmpTabName, $000000)
          EndIf
        Else
          If (I*TabW)+TabW+1 <= Width
            If I = 0 : Line(X, Y+2, 1, TabH-2, $FFFFFF) : EndIf
            Box(X+I*TabW+1, Y+2, TabW-1, TabH-2, $F0F0F0)
            Line(X+I*TabW+1, Y+2, TabW-1, 1, $FFFFFF)
            Line(X+I*TabW+1, Y+3, TabW-2, 1, $999999)
            Line(X+I*TabW+1, Y+3, 1, TabH-2, $999999)
            Line(X+I*TabW+TabW, Y+4, 1, TabH-3, $696969)
            Line(X+I*TabW+TabW-1, Y+3, 1, TabH-2, $A0A0A0)
            DrawingMode(#PB_2DDrawing_Transparent)
            DrawText(X+I*TabW+8, Y+(TabH-TextH)/2+1, TmpTabName, $282828)
          EndIf
        EndIf
      EndIf
    Next
  EndIf
EndProcedure

Procedure DrawScrollArea(X, Y, Width, Height, InnerW, InnerH, ScrollX, ScrollY)
  Protected ScrollCursorX, ScrollCursorWidth, ScrollCursorY, ScrollCursorHeight
  DrawingMode(#PB_2DDrawing_Default)
  Line(X, Y, 1, Height-1, $696969)
  Line(X+1, Y+1, 1, Height-3, $A0A0A0)
  Line(X, Y, Width-1, 1, $696969)
  Line(X+1, Y+1, Width-3, 1, $A0A0A0)
  Line(X+Width-1, Y, 1, Height, $FFFFFF)
  Line(X, Y+Height-1, Width, 1, $FFFFFF)
  
  If Height > 18
    Box(X+1, Y+Height-18, Width-2, 17, $F0F0F0)   ;ScrollBarX Background
    Line(X+1, Y+Height-18, Width-18, 1, $FFFFFF)
    ;Line(X+1, Y+Height-19, Width-19, 1, $999999)
  EndIf
  If Width > 18
    Box(X+Width-18, Y+1, 17, Height-2, $F0F0F0)   ;ScrollBarY Background
    Line(X+Width-18, Y+1, 1, Height-18, $FFFFFF)
    ;Line(X+Width-19, Y+1, 1, Height-19, $999999)
  EndIf
  ;Cursor length 100% (18 *2 for Arrow + 18 for the bottom left corner)
  If Height > 54 And Width > 54   
    ;Arrow ScrollX Bottom Left
    LineXY(X+6, Y+Height-9, X+11, Y+Height-12, $000000) : LineXY(X+6, Y+Height-9, X+11, Y+Height-6, $000000)
    ;Arrow ScrollY Top Right
    LineXY(X+Width-9, Y+6, X+Width-12, Y+11, $000000) : LineXY(X+Width-9, Y+6, X+Width-6, Y+11, $000000)
    ;Arrow ScrollX Bottom Right
    LineXY(X+Width-26, Y+Height-9, X+Width-31, Y+Height-12, $000000) : LineXY(X+Width-26, Y+Height-9, X+Width-31, Y+Height-6, $000000)
    ;Arrow ScrollY Bottom Right
    LineXY(X+Width-9, Y+Height-26, X+Width-12, Y+Height-31, $000000) : LineXY(X+Width-9, Y+Height-26, X+Width-6, Y+Height-31, $000000)
  EndIf
  
  ScrollCursorWidth = Width-54   ;Cursor length 100% (18 *2 for Arrow + 18 for the bottom right corner)
  If InnerW > Width-18
    ScrollCursorWidth = (ScrollCursorWidth*(Width-18))/InnerW
    If ScrollX > Width-54 - ScrollCursorWidth : ScrollX = Width-54 - ScrollCursorWidth : EndIf
  Else
    ScrollX = 0
  EndIf
  ;Debug "ScrollStepX = 1 => " +StrF(InnerW/(Width-54), 2)
  Box(X+18+ScrollX, Y+Height-17, ScrollCursorWidth, 16, $CDCDCD)   ;ScrollX Cursor
  
  ScrollCursorHeight = Height-54   ;Cursor length 100% (18 *2 for Arrow + 18 for the bottom right corner)
  If InnerH > Height-18
    ScrollCursorHeight = (ScrollCursorHeight*(Height-18))/InnerH
    If ScrollY > Height-54 - ScrollCursorHeight : ScrollY = Height-54 - ScrollCursorHeight : EndIf
  Else
    ScrollY = 0
  EndIf
  ;Debug "ScrollStepY = 1 => " +StrF(InnerH/(Height-54), 2)
  Box(X+Width-17, Y+18+ScrollY, 16, ScrollCursorHeight, $CDCDCD)   ;ScrollY Cursor
EndProcedure

Procedure DrawMenuToolStatusBar()
  Protected TextH.i, X.i, Y.i
  TextH = TextHeight("Text")
  ;AddMenu According to AddMenuHeight obtained in SweetyVD:Init()
  If AddMenu = #True
    DrawingMode(#PB_2DDrawing_Default)
    Box(0, Y, UserScreen_Width, AddMenuHeight, $FFFFFF)
    DrawingMode(#PB_2DDrawing_Transparent)
    If AddMenuHeight >= TextH
      DrawText(10, (AddMenuHeight-TextH)/2, "Menu", #MenuToolsStatusTextColor)
    Else
      DrawText(10, 0, "Menu", #MenuToolsStatusTextColor)
    EndIf
    Y + AddMenuHeight
    Line(0, Y, UserScreen_Width, 1, #MenuToolsStatusTextColor)
  EndIf
  ;AddToolBar According to AddToolBarHeight obtained in SweetyVD:Init()
  If AddToolBar = #True
    DrawingMode(#PB_2DDrawing_Default)
    If Y = 0
      Box(0, Y, UserScreen_Width, AddToolBarHeight, #DftBackColor)
    Else
      Box(0, Y+1, UserScreen_Width, AddToolBarHeight-1, #DftBackColor)
    EndIf
    DrawingMode(#PB_2DDrawing_Transparent)
    If AddToolBarHeight >= TextH
      DrawText(10, Y+(AddToolBarHeight-TextH)/2, "ToolBar", #MenuToolsStatusTextColor)
    Else
      DrawText(10, Y, "ToolBar", #MenuToolsStatusTextColor)
    EndIf
    Y + AddToolBarHeight
    Line(0, Y, UserScreen_Width, 1, #MenuToolsStatusTextColor)
  EndIf
  ;AddStatusBar According to AddStatusBarHeight obtained in SweetyVD:Init()
  If AddStatusBar = #True
    DrawingMode(#PB_2DDrawing_Default)
    Box(0, UserScreen_Height-AddStatusBarHeight, UserScreen_Width, AddStatusBarHeight, #DftBackColor)
    Line(0, UserScreen_Height-AddStatusBarHeight, UserScreen_Width, 1, #MenuToolsStatusTextColor)
    DrawingMode(#PB_2DDrawing_Transparent)
    DrawText(10, UserScreen_Height-AddStatusBarHeight+(AddStatusBarHeight-TextH)/2, "StatusBar", #MenuToolsStatusTextColor)
  EndIf
EndProcedure

Procedure DrawGrid()
  Protected X.i, Y.i, Spacing.i = GridSize
  If ShowGrid = #True 
    For X = 0 To UserScreen_Width
      For Y = 0 To UserScreen_Height
        Line(0,Y,UserScreen_Width,1, #GridColor)
        Y+Spacing-1
      Next
      Line(X,0,1,UserScreen_Height, #GridColor)
      X+Spacing-1
    Next
  EndIf
EndProcedure

Procedure DrawFullDrawingArea()
  If StartDrawing(CanvasOutput(#DrawArea))   ;Draw Grid Background and grid
    DrawingFont(GetGadgetFont(#PB_Default))
    DrawingMode(#PB_2DDrawing_Default)
    Box(0, 0, OutputWidth(), OutputHeight(), #ScrollAreaColor)
    Box(0, 0, UserScreen_Width, UserScreen_Height, #GridBackground)
    
    DrawGrid()
    DrawMenuToolStatusBar()
    
    Line(0, UserScreen_Height, UserScreen_Width+1, 1, #WinHandleColor)
    Line(UserScreen_Width, 0, 1, UserScreen_Height+1, #WinHandleColor)
    
    ;Draw Gadget and DragHandle above the grid
    If IsGadget(GadgetHandle(0)) : ResizeGadget(GadgetHandle(0), #PB_Ignore, #PB_Ignore, #PB_Ignore, #PB_Ignore) : EndIf
    PushMapPosition(SVDListGadget())
    With SVDListGadget()
      ForEach SVDListGadget()
        If \ModelType <> 0 And \DrawGadget = #True And \Hide = #False
          Select \Model
            Case "ContainerGadget" : DrawContainer(\X, \Y, \Width, \Height)
            Case "FrameGadget" : DrawFrame(\X, \Y, \Width, \Height, Mid(\Caption,7))
            Case "PanelGadget" : DrawPanel(\X, \Y, \Width, \Height, Mid(\Caption,7))
            Case "ScrollAreaGadget" : DrawScrollArea(\X, \Y, \Width, \Height, Val(Mid(\Option1,7)), Val(Mid(\Option2,7)), 0, 0)
          EndSelect
        EndIf
      Next
      StopDrawing()
      PopMapPosition(SVDListGadget())
    EndWith
  EndIf
EndProcedure
; IDE Options = PureBasic 5.71 LTS (Windows - x64)
; CursorPosition = 9
; FirstLine = 9
; Folding = --
; EnableXP