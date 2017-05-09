; ---------------------------------------------------------------------------------------
;           Name: SweetyVDmodule
;    Description: Sweety Visual Designer Module
;         Author: ChrisR
;           Date: 2017-05-09
;        Version: 1.9.25
;     PB-Version: 5.60 (x86/x64)
;             OS: Windows, Linux, Mac
;         Credit: Stargâte - Transformation of gadgets at runtime
;         Credit: Falsam - Tiny Visual Designer (TVD)
;  English-Forum: http://www.purebasic.fr/english/viewtopic.php?f=27&t=68187
;   French-Forum: http://www.purebasic.fr/french/viewtopic.php?f=3&t=16527
; ---------------------------------------------------------------------------------------

DeclareModule SVDesigner
  
  Enumeration #PB_EventType_FirstCustomValue
    #SVD_Gadget_Focus
    #SVD_Gadget_LostFocus
    #SVD_Gadget_Resize
    #SVD_Window_Focus
    #SVD_Window_ReSize
    #SVD_DrawArea_RightClick
    #SVD_DrawArea_Focus
  EndEnumeration
  
  Enumeration 1000
    #ScrollDrawArea
    #DrawArea
    #Shortcut_Delete
  EndEnumeration
  
  Structure PosDim
    X.i
    Y.i
    Width.i
    Height.i
  EndStructure
  
  Global WinBackColor.i = 0
  Global UserScreen_Width.i, UserScreen_Height.i, SavPosDim.PosDim
  Global DragSpace.i, ShowGrid.b, GridSize.i, SelectedDrawGadget.i, LastGadgetFocus.i, LastDragHandleFocus.i
  
  Declare DrawContainer(X, Y, Width, Height)
  Declare DrawFrame(X, Y, Width, Height, Text.s, BackColor.i = $F0F0F0)
  Declare DrawPanel(X, Y, Width, Height, Text.s = "Tab1", BackColor.i = $F0F0F0)
  Declare DrawScrollArea(X, Y, Width, Height, InnerW, InnerH, ScrollX, ScrollY) 
  Declare DrawGrid()
  Declare DrawAreaHandleBorder(Gadget.i, BorderColor.i)
  Declare DrawHandleBorder(DragHandle.i, BorderColor.i)
  Declare ReDrawGadgetHandleBorder()
  Declare ReDrawHandle()
  Declare MouseOverDrawArea()
  Declare.i GridMatch(Value.i, Grid.i=1, Min.i=0, Max.i=$7FFFFFFF)  
  Declare ResizeSVDGadget(Gadget.i, X.i, Y.i, Width.i, Height.i)  
  Declare ResizeHandle(Gadget)
  Declare SVD_Callback()
  Declare SVD_DrawCallback()
  Declare SVD_WinCallback()
  Declare SetActiveDrawAera()
  Declare SetActiveDrawGadget(Gadget.i)
  Declare SetDrawGadgetAttribute(Gadget.i, Caption.s, Option1.s, Option2.s)
  Declare SelectSVDGadget(Gadget.i)
  Declare DeleteSVDGadget(Gadget.i)
  Declare AddSVDDrawGadget(Gadget.i, Model.s, X.i, Y.i, Width.i, Height.i, Caption.s, Option1.s, Option2.s)
  Declare AddSVDGadget(Gadget.i, Model.s)
  Declare DisableSVD()
  Declare EnableSVD()
  Declare DrawAreaSize(Width.i, Height.i)
  Declare InitSVD(CountGadget.i = 144)
  
EndDeclareModule

Module SVDesigner
  
  EnableExplicit
  
  ;Import internal function
  CompilerIf #PB_Compiler_OS = #PB_OS_Windows
    Import ""
    CompilerElse
      ImportC ""
      CompilerEndIf
      PB_Object_EnumerateStart( PB_Objects )
      PB_Object_EnumerateNext( PB_Objects, *ID.Integer )
      PB_Object_EnumerateAbort( PB_Objects )
      PB_Object_GetObject( PB_Object , DynamicOrArrayID)
      PB_Window_Objects.i
      PB_Gadget_Objects.i
    EndImport
    
    #MinSize = 6
    #HandelColor = $640000      ;BlueDark
    #WinHandleColor= $000064    ;RedDark
    #FreeHandelColor = $FF8080  ;White=$FFFFFF, grey=$C6C6C6
    CompilerIf #PB_Compiler_OS = #PB_OS_MacOS
      #HandelSize = 8
      #OutSideBorder = 3
    CompilerElse
      #HandelSize = 7
      #OutSideBorder = 1
    CompilerEndIf
    
    Structure SVDGadget
      Gadget.i
      Model.s
      DragHandle.i
      Handle.i[9]
      X.i
      Y.i
      Width.i
      Height.i
      DrawGadget.b
      ParentGadget.i
      Caption.s
      Option1.s
      Option2.s
    EndStructure
    
    Structure DataBuffer
      Handle.i[9]
    EndStructure
    
    Global NewList SVDListGadget.SVDGadget()
    
    Structure GadgetDragHandle
      DragHandle.i
      Gadget.i
    EndStructure
    Global Dim GadgetDragHandleArray.GadgetDragHandle(0)
    Global Dim GadgetHandle(8)
    
    Procedure DrawContainer(X, Y, Width, Height)
      DrawingMode(#PB_2DDrawing_Outlined)
      Box(X, Y, Width, Height, RGB(0, 0, 0))
    EndProcedure
    
    Procedure DrawFrame(X, Y, Width, Height, Text.s, BackColor.i = $F0F0F0)
      Protected TextW, TextH
      If Text <> ""
        TextW = TextWidth(Text) : TextH = TextHeight(Text)
      Else
        TextW = TextWidth("X") : TextH = TextHeight("X")
      EndIf
      DrawingMode(#PB_2DDrawing_Outlined)
      Box(X, Y+TextH/2, Width, Height-TextH/2, RGB(127, 127, 127))
      ;RoundBox(X, Y+TextH/2, Width, Height-TextH/2, 4, 4, RGB(127, 127, 127))
      If Text <> ""
        DrawingMode(#PB_2DDrawing_Transparent)
        Box(X+10, Y+TextH/2, TextW+10, 1, BackColor)
        DrawingMode(#PB_2DDrawing_Transparent)
        DrawText(X+15, Y, Text, RGB(0, 0, 0))
      EndIf
    EndProcedure
    
    Procedure DrawPanel(X, Y, Width, Height, Text.s = "Tab1", BackColor.i = $F0F0F0)
      Protected TextW, TextH, TabW, TabH, I.i, TmpTabName.s, ActiveTab.i=-1
      TextW = TextWidth(Text) / (CountString(Text, "|") + 1) : TabW = TextW+20
      TextH = TextHeight(Text) : TabH = 20
      For I=0 To CountString(Text, "|")   ;Draw Tab + Text (eg: "Tab1|Tab2(x)|Tab3"
        TmpTabName = Trim(StringField(Text, I+1, "|"))
        If TmpTabName <> ""
          DrawingMode(#PB_2DDrawing_Default)
          If Right(TmpTabName, 3) = "(x)"
            TmpTabName = Left(TmpTabName, Len(TmpTabName)-3)
            ActiveTab = I
            Box(X+I*TabW, Y, TabW+1, TabH, RGB(255, 255, 255))
            DrawingMode(#PB_2DDrawing_Outlined)
            Box(X+I*TabW, Y, TabW+1, TabH, RGB(0, 0, 0))
            DrawingMode(#PB_2DDrawing_Transparent)
            DrawText(X+I*TabW+10, Y+(TabH-TextH)/2, TmpTabName, RGB(0, 0, 0))
          Else
            Box(X+I*TabW, Y+2, TabW+1, TabH-2, RGB(240, 240, 240))
            DrawingMode(#PB_2DDrawing_Outlined)
            Box(X+I*TabW, Y+2, TabW+1, TabH-2, RGB(95, 95, 95))
            DrawingMode(#PB_2DDrawing_Transparent)
            DrawText(X+I*TabW+10, Y+(TabH-TextH)/2+1, TmpTabName, RGB(66, 66, 66))
          EndIf
        EndIf
      Next
      
      DrawingMode(#PB_2DDrawing_Outlined)
      Box(X, Y+(TabH-1), Width, Height-(TabH-1), RGB(0, 0, 0))   ;Inner Panel
      If ActiveTab = -1 : ActiveTab = 0 : EndIf
      Box(X+ActiveTab*TabW, Y, TabW+1, TabH, RGB(0, 0, 0))   ;Active Tab
      Box(X+ActiveTab*TabW+1, Y+(TabH-1), TabW-1, 1, BackColor)   ;Active Tab
    EndProcedure
    
    Procedure DrawScrollArea(X, Y, Width, Height, InnerW, InnerH, ScrollX, ScrollY)
      Protected ScrollCursorX, ScrollCursorWidth, ScrollCursorY, ScrollCursorHeight
      DrawingMode(#PB_2DDrawing_Outlined)
      Box(X, Y, Width, Height, RGB(130, 135, 144))   ;Border Black RGB(0, 0, 0))
      DrawingMode(#PB_2DDrawing_Default)
      Box(X+1, Y+Height-18, Width-2, 17, RGB(240, 240, 240))   ;ScrollBarX Background
      Box(X+Width-18, Y+1, 17, Height-2, RGB(240, 240, 240))   ;ScrollBarY Background
                                                               ;Arrow ScrollX Bottom Left
      LineXY(X+6, Y+Height-9, X+11, Y+Height-12, RGB(0, 0, 0)) : LineXY(X+6, Y+Height-9, X+11, Y+Height-6, RGB(0, 0, 0))
      ;Arrow ScrollY Top Right
      LineXY(X+Width-9, Y+6, X+Width-12, Y+11, RGB(0, 0, 0)) : LineXY(X+Width-9, Y+6, X+Width-6, Y+11, RGB(0, 0, 0))
      ;Arrow ScrollX Bottom Right
      LineXY(X+Width-26, Y+Height-9, X+Width-31, Y+Height-12, RGB(0, 0, 0)) : LineXY(X+Width-26, Y+Height-9, X+Width-31, Y+Height-6, RGB(0, 0, 0))
      ;Arrow ScrollY Bottom Right
      LineXY(X+Width-9, Y+Height-26, X+Width-12, Y+Height-31, RGB(0, 0, 0)) : LineXY(X+Width-9, Y+Height-26, X+Width-6, Y+Height-31, RGB(0, 0, 0))
      
      ScrollCursorWidth = Width-54   ;Cursor length 100% (18 *2 for Arrow + 18 for the bottom left corner)
      If InnerW > Width-18
        ScrollCursorWidth = (ScrollCursorWidth*(Width-18))/InnerW
        If ScrollX > Width-54 - ScrollCursorWidth : ScrollX = Width-54 - ScrollCursorWidth : EndIf
      Else
        ScrollX = 0
      EndIf
      ;Debug "ScrollStepX = 1 => " +StrF(InnerW/(Width-54), 2)
      Box(X+18+ScrollX, Y+Height-18, ScrollCursorWidth, 17, RGB(205, 205, 205))   ;ScrollX Cursor
      
      ScrollCursorHeight = Height-54   ;Cursor length 100% (18 *2 for Arrow + 18 for the bottom left corner)
      If InnerH > Height-18
        ScrollCursorHeight = (ScrollCursorHeight*(Height-18))/InnerH
        If ScrollY > Height-54 - ScrollCursorHeight : ScrollY = Height-54 - ScrollCursorHeight : EndIf
      Else
        ScrollY = 0
      EndIf
      ;Debug "ScrollStepY = 1 => " +StrF(InnerH/(Height-54), 2)
      Box(X+Width-18, Y+18+ScrollY, 17, ScrollCursorHeight, RGB(205, 205, 205))   ;ScrollY Cursor
    EndProcedure
    
    Procedure DrawGrid()
      ;Notes: To display the gadgets after grid drawing (canvas), we need to resize the gadgets and the move handles
      Protected GridBackground.i = $EBE6E1, GridColor.i = $CECCCC, ScrollAreaColor = $A0A0A0, DftBackColor.i = $F0F0F0
      Protected X.i, Y.i, Spacing.i = GridSize
      If ShowGrid = #False
        CompilerIf #PB_Compiler_OS = #PB_OS_MacOS : DftBackColor = $C0C0C0 : CompilerEndIf
        Spacing = 8192 : GridBackground = DftBackColor : ScrollAreaColor = DftBackColor
        If WinBackColor = 0
          GridBackground = DftBackColor
        Else
          GridBackground = WinBackColor
        EndIf
      EndIf
      If StartDrawing(CanvasOutput(#DrawArea))
        Box(0, 0, OutputWidth(), OutputHeight(), ScrollAreaColor)
        Box(X, Y, UserScreen_Width, UserScreen_Height, GridBackground)
        For X = 0 To UserScreen_Width
          For Y = 0 To UserScreen_Height
            Line(0,Y,UserScreen_Width,1,GridColor)
            Y+Spacing-1
          Next
          Line(X,0,1,UserScreen_Height,GridColor)
          X+Spacing-1
        Next
        Line(0, UserScreen_Height, UserScreen_Width, 1, #WinHandleColor)
        Line(UserScreen_Width, 0, 1, UserScreen_Height, #WinHandleColor)
        
        ;To redraw Gadget and DragHandle above the grid
        If IsGadget(GadgetHandle(0)) : ResizeGadget(GadgetHandle(0), #PB_Ignore, #PB_Ignore, #PB_Ignore, #PB_Ignore) : EndIf
        With SVDListGadget()
          ForEach SVDListGadget()
            If \DrawGadget = #False
              ;ResizeGadget(\Gadget, #PB_Ignore, #PB_Ignore, #PB_Ignore, #PB_Ignore)
              ;ResizeGadget(\DragHandle, #PB_Ignore, #PB_Ignore, #PB_Ignore, #PB_Ignore)
            Else
              Select \Model
                Case "ContainerGadget" : DrawContainer(\X, \Y, \Width, \Height)
                Case "FrameGadget" : DrawFrame(\X, \Y, \Width, \Height, \Caption, GridBackground)
                Case "PanelGadget" : DrawPanel(\X, \Y, \Width, \Height, \Caption, GridBackground)
                Case "ScrollAreaGadget" : DrawScrollArea(\X, \Y, \Width, \Height, Val(Mid(\Option1,7)), Val(Mid(\Option2,7)), 0, 0)
              EndSelect
            EndIf
          Next
          StopDrawing()
          ForEach SVDListGadget()
            If \DrawGadget = #True
              DrawAreaHandleBorder(\Gadget, #FreeHandelColor)
            EndIf
          Next
        EndWith
      EndIf
    EndProcedure
    
    Procedure DrawAreaHandleBorder(Gadget.i, BorderColor.i)
      With SVDListGadget()
        ForEach SVDListGadget()
          If \Gadget = Gadget And \DrawGadget = #True
            If StartDrawing(CanvasOutput(#DrawArea))
              DrawingMode(#PB_2DDrawing_Outlined)
              Box(\X-#OutSideBorder-1, \Y-#OutSideBorder-1, \Width+(2*#OutSideBorder)+2, \Height+(2*#OutSideBorder)+2, BorderColor)
              StopDrawing()
            EndIf
            Break
          EndIf
        Next
      EndWith
    EndProcedure
    
    Procedure DrawHandleBorder(DragHandle.i, BorderColor.i)
      If StartDrawing(CanvasOutput(DragHandle))   ;Draw the border around the gadget
        Box(0, 0, OutputWidth(), OutputHeight(), BorderColor)
        Box(1, 1, OutputWidth()-2, OutputHeight()-2, $FFFFFF)
        StopDrawing()
      EndIf
    EndProcedure
    
    Procedure ReDrawGadgetHandleBorder()
      With SVDListGadget()
        ForEach SVDListGadget()
          If \DrawGadget = #False
            ResizeGadget(\Gadget, #PB_Ignore, #PB_Ignore, #PB_Ignore, #PB_Ignore)
            ResizeGadget(\DragHandle, #PB_Ignore, #PB_Ignore, #PB_Ignore, #PB_Ignore)
          EndIf
        Next
      EndWith
    EndProcedure
    
    Procedure ReDrawHandle()
      Protected i.i
      For I = 0 To 8
        ResizeGadget(GadgetHandle(I), #PB_Ignore, #PB_Ignore, #PB_Ignore, #PB_Ignore)
      Next
    EndProcedure
    
    Procedure  MouseOverDrawArea()
      Protected X = UserScreen_Width + GadgetX(#ScrollDrawArea) - GetGadgetAttribute(#ScrollDrawArea, #PB_ScrollArea_X), Y = UserScreen_Height + GadgetY(#ScrollDrawArea) - GetGadgetAttribute(#ScrollDrawArea, #PB_ScrollArea_Y)
      Protected Mx = WindowMouseX(0), My = WindowMouseY(0)
      If Mx > GadgetX(#ScrollDrawArea) And Mx < X And My > GadgetY(#ScrollDrawArea) And My < Y
        ProcedureReturn 1   ;Mouse is on Gadget
      EndIf
      ProcedureReturn 0   ;Mouse is not on Gadget
    EndProcedure
    
    Procedure.i GridMatch(Value.i, Grid.i=1, Min.i=0, Max.i=$7FFFFFFF)
      Value = Round(Value/Grid, #PB_Round_Nearest)*Grid
      If Value < Min
        ProcedureReturn Min
      ElseIf Value > Max
        ProcedureReturn Max
      Else
        ProcedureReturn Value
      EndIf
    EndProcedure
    
    Procedure ResizeSVDGadget(Gadget.i, X.i, Y.i, Width.i, Height.i)
      Protected *SVDListGadget.SVDGadget
      With SVDListGadget()
        ForEach SVDListGadget()
          If \Gadget = Gadget
            ;Only one of the values X, Y, Width or Height. Sent from an interface, with control there. other values must be negative (#PB_Ignore=-65535)
            If X >= 0 And Y < 0 And Width < 0 And Height < 0
              \X = GridMatch(X, 1, 0, UserScreen_Width-\Width)
            ElseIf Y >= 0 And X < 0 And Width < 0 And Height < 0
              \Y = GridMatch(Y, 1, 0, UserScreen_Height-\Height)
            ElseIf Width >= 0 And X < 0 And Y < 0 And Height < 0
              \Width = GridMatch(Width, 1, 0, UserScreen_Width-\X)
            ElseIf Height >= 0 And X < 0 And Y < 0 And Width < 0
              \Height = GridMatch(Height, 1, 0, UserScreen_Height-\Y)
            Else
              ProcedureReturn #False
            EndIf
            SavPosDim\X = \X : SavPosDim\Y = \Y : SavPosDim\Width = \Width : SavPosDim\Height = \Height
            If \DrawGadget = #False 
              ResizeGadget(Gadget, \X, \Y, \Width, \Height)
            Else
              DrawGrid()
            EndIf
            ResizeHandle(Gadget)
            Break
          EndIf
        Next
      EndWith
    EndProcedure
    
    Procedure ResizeHandle(Gadget)
      Protected *SVDListGadget.SVDGadget
      Protected GadgetX0, GadgetWidth0, GadgetX1
      Protected GadgetY0, GadgetHeight0, GadgetY1
      
      With SVDListGadget()
        ForEach SVDListGadget()
          If \Gadget = Gadget
            GadgetX0 = \X : GadgetWidth0 = \Width : GadgetX1 = GadgetX0 + GadgetWidth0
            GadgetY0 = \Y : GadgetHeight0 = \Height : GadgetY1 = GadgetY0 + GadgetHeight0
            If \DragHandle   ;Moved Handle
              ResizeGadget(\DragHandle, GadgetX0-#OutSideBorder, GadgetY0-#OutSideBorder, GadgetWidth0+(2*#OutSideBorder), GadgetHeight0+(2*#OutSideBorder))
              DrawHandleBorder(\DragHandle, #HandelColor)
            Else
              DrawAreaHandleBorder(\Gadget, #HandelColor)
            EndIf
            If \Handle[1]   ;Handle top, middle (N)
              ResizeGadget(\Handle[1], GadgetX0+(GadgetWidth0-#HandelSize)/2, GadgetY0-#HandelSize, #PB_Ignore, #PB_Ignore)
            EndIf
            If \Handle[2]  ;Handle top, right (NE)
              ResizeGadget(\Handle[2], GadgetX1, GadgetY0-#HandelSize, #PB_Ignore, #PB_Ignore)
            EndIf
            If \Handle[3]   ;Handle middle, right (E)
              ResizeGadget(\Handle[3], GadgetX1, GadgetY0+(GadgetHeight0-#HandelSize)/2, #PB_Ignore, #PB_Ignore)
            EndIf
            If \Handle[4]   ;Handle bottom, right (SE)
              ResizeGadget(\Handle[4], GadgetX1, GadgetY1, #PB_Ignore, #PB_Ignore)
            EndIf
            If \Handle[5]    ;Handle bottom, middle (S)
              ResizeGadget(\Handle[5], GadgetX0+(GadgetWidth0-#HandelSize)/2, GadgetY1, #PB_Ignore, #PB_Ignore)
            EndIf
            If \Handle[6]   ;Handle bottom, left (SW)
              ResizeGadget(\Handle[6], GadgetX0-#HandelSize, GadgetY1, #PB_Ignore, #PB_Ignore)
            EndIf
            If \Handle[7]   ;Handle middle, left (W)
              ResizeGadget(\Handle[7], GadgetX0-#HandelSize, GadgetY0+(GadgetHeight0-#HandelSize)/2, #PB_Ignore, #PB_Ignore)
            EndIf
            If \Handle[8]   ;Handle top, left (NW)
              ResizeGadget(\Handle[8], GadgetX0-#HandelSize, GadgetY0-#HandelSize, #PB_Ignore, #PB_Ignore)
            EndIf
            Break
          EndIf
        Next
      EndWith
    EndProcedure
    
    Procedure SVD_Callback()
      ;Notes: To display the gadgets after drag Handles resizing (canvas), we need to resize the gadgets
      ;We need to do it here for events : #PB_EventType_Focus, #PB_EventType_LostFocus, #PB_EventType_KeyDown (If Resize Done)
      ;                 #PB_EventType_RightButtonDown, #PB_EventType_MiddleButtonDown, #PB_EventType_LeftButtonDown
      ; -----------------------------------------------------------------------------------------------------------
      ;Canvas Event: MouseEnter=65537, MouseLeave=65538, MouseMove=65539, MouseWheel=65546, LeftButtonDown=65540
      ;  LeftButtonUp=65541, LeftClick=0, LeftDoubleClick=2, RightButtonDown=65542, RightButtonUp=65543
      ;  RightClick=13111, RightDoubleClick=3, MiddleButtonDown=65544, MiddleButtonUp=65545, Focus=14000, LostFocus=14001
      ;  KeyDown=65547, KeyUp=65548, Input=65549, Resize=6
      Static Selected.b, X.i, Y.i, OffsetX.i, OffsetY.i, GadgetX0.i, GadgetWidth0, GadgetX1.i, GadgetY0.i, GadgetHeight0, GadgetY1.i
      Static ScrollX.i, ScrollY.i
      Protected *SVDListGadget.SVDGadget = GetGadgetData(EventGadget()), ResizeDone.b, I.i
      With *SVDListGadget
        Select EventType()
            
          Case #PB_EventType_Focus
            If \DragHandle = EventGadget()
              If LastDragHandleFocus > 0 And IsGadget(LastDragHandleFocus) : DrawHandleBorder(LastDragHandleFocus, #FreeHandelColor) : EndIf
              If LastGadgetFocus > 1 
                If IsGadget(LastGadgetFocus) : ResizeGadget(LastGadgetFocus, #PB_Ignore, #PB_Ignore, #PB_Ignore, #PB_Ignore) : EndIf
                DrawAreaHandleBorder(LastGadgetFocus, #FreeHandelColor)
              EndIf
              SelectedDrawGadget = -1
              LastDragHandleFocus = \DragHandle
              LastGadgetFocus = \Gadget
              SelectedDrawGadget = -1
              For I = 1 To 8
                \Handle[I] = GadgetHandle(I)
                SetGadgetData(\Handle[I], *SVDListGadget)
                HideGadget(\Handle[I],#False)
                BindGadgetEvent(\Handle[I], @SVD_Callback()) 
              Next
              ResizeHandle(\Gadget)
              ResizeGadget(\Gadget, #PB_Ignore, #PB_Ignore, #PB_Ignore, #PB_Ignore)   ;to avoid a white frame (=canvas) instead of gadget
              AddKeyboardShortcut(0, #PB_Shortcut_Delete, #Shortcut_Delete)
              SavPosDim\X = \X : SavPosDim\Y = \Y : SavPosDim\Width = \Width : SavPosDim\Height = \Height
              ;PostEvent(#PB_Event_Gadget, GetActiveWindow(), \Gadget, #SVD_Gadget_Focus, @SavPosDim)
              PostEvent(#PB_Event_Gadget, 0, \Gadget, #SVD_Gadget_Focus, @SavPosDim)   ;For Debug
            EndIf
            
          Case #PB_EventType_LostFocus
            ResizeGadget(\Gadget, #PB_Ignore, #PB_Ignore, #PB_Ignore, #PB_Ignore)   ;to avoid a white frame (=canvas) instead of gadget
                                                                                    ;Do not Post Event to keep X, Y, Width, Height SpinGadget on hand
            
          Case #PB_EventType_KeyDown
            GadgetX0 = \X : GadgetWidth0 = \Width : GadgetX1 = GadgetX0 + GadgetWidth0
            GadgetY0 = \Y : GadgetHeight0 = \Height : GadgetY1 = GadgetY0 + GadgetHeight0
            Select GetGadgetAttribute(EventGadget(),#PB_Canvas_Key)
              Case #PB_Shortcut_Up
                If GetGadgetAttribute(\DragHandle, #PB_Canvas_Modifiers) = #PB_Canvas_Shift And IsGadget(\Handle[1])
                  ResizeGadget(\Gadget, #PB_Ignore, #PB_Ignore, #PB_Ignore, GridMatch(GadgetHeight0-DragSpace, DragSpace, #MinSize)) : ResizeDone = #True 
                ElseIf IsGadget(\DragHandle) Or IsGadget(\Handle[1])
                  ResizeGadget(\Gadget, #PB_Ignore, GridMatch(GadgetY0-DragSpace, DragSpace, 0), #PB_Ignore, #PB_Ignore) : ResizeDone = #True
                EndIf
              Case #PB_Shortcut_Right
                If GetGadgetAttribute(\DragHandle,#PB_Canvas_Modifiers) = #PB_Canvas_Shift And IsGadget(\Handle[3])
                  ResizeGadget(\Gadget, #PB_Ignore, #PB_Ignore, GridMatch(GadgetWidth0+DragSpace, DragSpace, 0, UserScreen_Width-GadgetX0), #PB_Ignore) : ResizeDone = #True
                ElseIf IsGadget(\DragHandle) Or IsGadget(\Handle[3])
                  ResizeGadget(\Gadget, GridMatch(GadgetX0+DragSpace, DragSpace, 0, UserScreen_Width-GadgetWidth0), #PB_Ignore, #PB_Ignore, #PB_Ignore) : ResizeDone = #True
                EndIf
              Case #PB_Shortcut_Down
                If GetGadgetAttribute(\DragHandle, #PB_Canvas_Modifiers) = #PB_Canvas_Shift And IsGadget(\Handle[5])
                  ResizeGadget(\Gadget, #PB_Ignore, #PB_Ignore, #PB_Ignore, GridMatch(GadgetHeight0+DragSpace, DragSpace, 0, UserScreen_Height-GadgetY0)) : ResizeDone = #True
                ElseIf IsGadget(\DragHandle) Or IsGadget(\Handle[5])
                  ResizeGadget(\Gadget, #PB_Ignore, GridMatch(GadgetY0+DragSpace, DragSpace, 0, UserScreen_Height-GadgetHeight0), #PB_Ignore, #PB_Ignore) : ResizeDone = #True
                EndIf
              Case #PB_Shortcut_Left
                If GetGadgetAttribute(\DragHandle, #PB_Canvas_Modifiers) = #PB_Canvas_Shift And IsGadget(\Handle[7])
                  ResizeGadget(\Gadget, #PB_Ignore, #PB_Ignore, GridMatch(GadgetWidth0-DragSpace, DragSpace, #MinSize), #PB_Ignore) : ResizeDone = #True
                ElseIf IsGadget(\DragHandle) Or IsGadget(\Handle[7])
                  ResizeGadget(\Gadget, GridMatch(GadgetX0-DragSpace, DragSpace, 0), #PB_Ignore, #PB_Ignore, #PB_Ignore) : ResizeDone = #True
                EndIf
            EndSelect
            If ResizeDone
              \X = GadgetX(\Gadget) : \Y = GadgetY(\Gadget) : \Width = GadgetWidth(\Gadget) : \Height = GadgetHeight(\Gadget)
              SavPosDim\X = \X : SavPosDim\Y = \Y : SavPosDim\Width = \Width : SavPosDim\Height = \Height
              ResizeHandle(\Gadget)
              ResizeGadget(\Gadget, #PB_Ignore, #PB_Ignore, #PB_Ignore, #PB_Ignore)   ;to avoid a white frame (=canvas) instead of gadget
                                                                                      ;PostEvent(#PB_Event_Gadget, GetActiveWindow(), \Gadget, #SVD_Gadget_Resize, @SavPosDim)
              PostEvent(#PB_Event_Gadget, 0, \Gadget, #SVD_Gadget_Resize, @SavPosDim) ;For Debug
              ResizeDone = #False
            EndIf
            
          Case #PB_EventType_KeyUp
            ReDrawGadgetHandleBorder()   ;Redraw all Gadget to avoid overlay effects
            
          Case #PB_EventType_RightButtonDown
            ResizeGadget(\Gadget, #PB_Ignore, #PB_Ignore, #PB_Ignore, #PB_Ignore)   ;to avoid a white frame (=canvas) instead of gadget
            
          Case #PB_EventType_MiddleButtonDown
            ResizeGadget(\Gadget, #PB_Ignore, #PB_Ignore, #PB_Ignore, #PB_Ignore)   ;to avoid a white frame (=canvas) instead of gadget
            
          Case #PB_EventType_LeftButtonDown
            If \DragHandle <> EventGadget()
              If IsGadget(\DragHandle)       ;Or \DrawGadget= #False
                SetActiveGadget(\DragHandle)
              EndIf
            EndIf   ;To keep Keyboard focus
            Selected = #True
            OffsetX = GetGadgetAttribute(EventGadget(), #PB_Canvas_MouseX) : OffsetY = GetGadgetAttribute(EventGadget(), #PB_Canvas_MouseY)
            GadgetX0 = \X : GadgetWidth0 = \Width: GadgetX1 = GadgetX0 + GadgetWidth0
            GadgetY0 = \Y : GadgetHeight0 = \Height :GadgetY1 = GadgetY0 + GadgetHeight0
            SavPosDim\X = GadgetX0 : SavPosDim\Y = GadgetX0 : SavPosDim\Width = GadgetWidth0 : SavPosDim\Height = GadgetHeight0
            If IsGadget(\ParentGadget)
              If GadgetType(\ParentGadget) = #PB_GadgetType_ScrollArea
                ScrollX = GadgetX(\ParentGadget)-GetGadgetAttribute(\ParentGadget, #PB_ScrollArea_X) : ScrollY = GadgetY(\ParentGadget)-GetGadgetAttribute(\ParentGadget, #PB_ScrollArea_Y)
              Else
                ScrollX = GadgetX(\ParentGadget) : ScrollY = GadgetY(\ParentGadget)
              EndIf
            ElseIf IsWindow(\ParentGadget)   ;Window
              ScrollX = 0 : ScrollY = 0
            EndIf
            If IsGadget(\Gadget)
              ResizeGadget(\Gadget, #PB_Ignore, #PB_Ignore, #PB_Ignore, #PB_Ignore)   ;to avoid a white frame (=canvas) instead of gadget
            EndIf
            
          Case #PB_EventType_LeftButtonUp
            Selected = #False
            ReDrawGadgetHandleBorder()   ;Redraw all Gadget to avoid overlay effects
            
          Case #PB_EventType_MouseMove
            If Selected
              X = WindowMouseX(0)-OffsetX-ScrollX : Y = WindowMouseY(0)-OffsetY-ScrollY
              ;<== FOR DEBUG: X = WindowMouseX(GetActiveWindow())-OffsetX-ScrollX : Y = WindowMouseY(GetActiveWindow())-OffsetY-ScrollY
              Select EventGadget()
                Case \DragHandle   ;Moved Gadget NESW
                  \X = GridMatch(X+#OutSideBorder, DragSpace, 0, UserScreen_Width-GadgetWidth0)
                  \Y = GridMatch(Y+#OutSideBorder, DragSpace, 0, UserScreen_Height-GadgetHeight0)
                Case \Handle[1]   ;Handle top, middle (N)
                  \Height = GridMatch(GadgetY1-(Y+#HandelSize), DragSpace, #MinSize, GadgetY1)
                  \Y = GridMatch(Y+#HandelSize, DragSpace, 0, GadgetY1-\Height)
                Case \Handle[2]   ;Handle top, right (NE)
                  \Width = GridMatch(X, DragSpace, GadgetX0+#MinSize, UserScreen_Width)-GadgetX0
                  \Height = GridMatch(GadgetY1-(Y+#HandelSize), DragSpace, #MinSize, GadgetY1)
                  \Y = GridMatch(Y+#HandelSize, DragSpace, 0, GadgetY1-\Height)
                Case \Handle[3]   ;Handle middle, right (E)
                  \Width = GridMatch(X, DragSpace, GadgetX0+#MinSize, UserScreen_Width)-GadgetX0
                Case \Handle[4]   ;Handle bottom, right (SE)
                  \Width = GridMatch(X, DragSpace, GadgetX0+#MinSize, UserScreen_Width)-GadgetX0
                  \Height = GridMatch(Y, DragSpace, GadgetY0+#MinSize, UserScreen_Height)-GadgetY0
                Case \Handle[5]   ;Handle bottom, middle (S)
                  \Height = GridMatch(Y, DragSpace, GadgetY0+#MinSize, UserScreen_Height)-GadgetY0
                Case \Handle[6]   ;Handle bottom, left (SW)
                  \Width = GridMatch(GadgetX1-(X+#HandelSize), DragSpace, #MinSize, GadgetX1)
                  \Height = GridMatch(Y, DragSpace, GadgetY0+#MinSize, UserScreen_Height)-GadgetY0
                  \X = GridMatch(X+#HandelSize, DragSpace, 0, GadgetX1-\Width)
                Case \Handle[7]   ;Handle middle, left (W)
                  \Width = GridMatch(GadgetX1-(X+#HandelSize), DragSpace, #MinSize, GadgetX1)
                  \X = GridMatch(X+#HandelSize, DragSpace, 0, GadgetX1-\Width)
                Case \Handle[8]   ;Handle top, left (NW)
                  \Width = GridMatch(GadgetX1-(X+#HandelSize), DragSpace, #MinSize, GadgetX1)
                  \Height = GridMatch(GadgetY1-(Y+#HandelSize), DragSpace, #MinSize, GadgetY1)
                  \X = GridMatch(X+#HandelSize, DragSpace, 0, GadgetX1-\Width)
                  \Y = GridMatch(Y+#HandelSize, DragSpace, 0, GadgetY1-\Height)
              EndSelect
              If \X <> SavPosDim\X Or \Y <> SavPosDim\Y Or \Width <> SavPosDim\Width Or \Height <> SavPosDim\Height
                SavPosDim\X = \X : SavPosDim\Y = \Y : SavPosDim\Width = \Width : SavPosDim\Height = \Height
                ;Check move or resize, the gadgets are moved following Drag Spacing
                If \DrawGadget = #False
                  ResizeGadget(\Gadget, \X, \Y, \Width, \Height)
                Else
                  DrawGrid()
                EndIf
                ResizeHandle(\Gadget)
                ;PostEvent(#PB_Event_Gadget, GetActiveWindow(), \Gadget, #SVD_Gadget_Resize, @SavPosDim)
                PostEvent(#PB_Event_Gadget, 0, \Gadget, #SVD_Gadget_Resize, @SavPosDim)      ;For Debug
              EndIf
            EndIf
        EndSelect
      EndWith
    EndProcedure
    
    Procedure SVD_DrawCallback()
      Static MouseDown.b, Selected.b, X.i, Y.i, OffsetX.i, OffsetY.i, DeltaX.i, DeltaY.i
      Static MouseOverGadget.i, SavPBCursor, SavPosDim.PosDim
      Protected ResizeDone.b, I.i
      
      Select EventType()
          
        Case #PB_EventType_RightClick
          ;PostEvent(#PB_Event_Gadget, GetActiveWindow(), #DrawArea, #SVD_DrawArea_RightClick)
          PostEvent(#PB_Event_Gadget, 0, #DrawArea, #SVD_DrawArea_RightClick)   ;RightClick for the MenuPopup
          
        Case #PB_EventType_KeyDown
          If SelectedDrawGadget <> -1
            With SVDListGadget()
              ForEach SVDListGadget()
                If \Gadget = SelectedDrawGadget
                  Select GetGadgetAttribute(EventGadget(),#PB_Canvas_Key)
                    Case #PB_Shortcut_Up
                      If GetGadgetAttribute(#DrawArea, #PB_Canvas_Modifiers) = #PB_Canvas_Shift And IsGadget(\Handle[1])
                        \Height =  GridMatch(\Height-DragSpace, DragSpace, #MinSize) : ResizeDone = #True
                      ElseIf IsGadget(\Handle[1])
                        \Y = GridMatch(\Y-DragSpace, DragSpace, 0) : ResizeDone = #True
                      EndIf
                    Case #PB_Shortcut_Right
                      If GetGadgetAttribute(#DrawArea,#PB_Canvas_Modifiers) = #PB_Canvas_Shift And IsGadget(\Handle[3])
                        \Width = GridMatch(\Width+DragSpace, DragSpace, 0, UserScreen_Width-\X) : ResizeDone = #True
                      ElseIf IsGadget(\Handle[3])
                        \X = GridMatch(\X+DragSpace, DragSpace, 0, UserScreen_Width-\Width) : ResizeDone = #True
                      EndIf
                    Case #PB_Shortcut_Down
                      If GetGadgetAttribute(#DrawArea, #PB_Canvas_Modifiers) = #PB_Canvas_Shift
                        \Height = GridMatch(\Height+DragSpace, DragSpace, 0, UserScreen_Height-\Y) : ResizeDone = #True
                      ElseIf IsGadget(\Handle[5])
                        \Y = GridMatch(\Y+DragSpace, DragSpace, 0, UserScreen_Height-\Height) : ResizeDone = #True
                      EndIf
                    Case #PB_Shortcut_Left
                      If GetGadgetAttribute(#DrawArea, #PB_Canvas_Modifiers) = #PB_Canvas_Shift
                        \Width = GridMatch(\Width-DragSpace, DragSpace, #MinSize) : ResizeDone = #True
                      ElseIf IsGadget(\Handle[7])
                        \X = GridMatch(\X-DragSpace, DragSpace, 0) : ResizeDone = #True
                      EndIf
                  EndSelect
                  If ResizeDone
                    SavPosDim\X = \X : SavPosDim\Y = \Y : SavPosDim\Width = \Width : SavPosDim\Height = \Height
                    DrawGrid()
                    ResizeHandle(SelectedDrawGadget)
                    ;PostEvent(#PB_Event_Gadget, GetActiveWindow(), SelectedDrawGadget, #SVD_Gadget_Resize, @SavPosDim)
                    PostEvent(#PB_Event_Gadget, 0, SelectedDrawGadget, #SVD_Gadget_Resize, @SavPosDim)      ;For Debug
                    ResizeDone = #False
                  EndIf
                  Break
                EndIf
              Next
            EndWith
          EndIf
          
        Case #PB_EventType_KeyUp
          ReDrawGadgetHandleBorder()   ;Redraw all Gadget to avoid overlay effects
          
        Case #PB_EventType_LeftButtonDown
          If MouseOverGadget <> -1
            SelectedDrawGadget = MouseOverGadget
            SetActiveDrawGadget(SelectedDrawGadget)
            MouseDown = #True
          ElseIf MouseOverDrawArea() = #True
            SetActiveDrawAera()
            ;PostEvent(#PB_Event_Gadget, GetActiveWindow(), #DrawArea, #SVD_DrawArea_Focus)
            PostEvent(#PB_Event_Gadget, 0, #DrawArea, #SVD_DrawArea_Focus)   ;Left Click Lost focus for now
          ElseIf IsGadget(LastGadgetFocus)
            SelectSVDGadget(LastGadgetFocus)
          EndIf
          
        Case #PB_EventType_LeftButtonUp
          MouseDown = #False
          ReDrawGadgetHandleBorder()   ;Redraw all Gadget to avoid overlay effects
          
        Case #PB_EventType_MouseMove
          OffsetX = GetGadgetAttribute(#DrawArea, #PB_Canvas_MouseX)
          OffsetY = GetGadgetAttribute(#DrawArea, #PB_Canvas_MouseY)
          
          If MouseDown = #False
            ;Survol d'un gadget ?
            MouseOverGadget = -1
            With SVDListGadget()
              ForEach SVDListGadget()
                If \DrawGadget = #True And OffsetX > = \X And OffsetX <= \X + \Width  And OffsetY >= \Y And OffsetY <= \Y + \Height
                  MouseOverGadget = \Gadget
                  DeltaX = OffsetX - \X
                  DeltaY = OffsetY - \Y
                EndIf
              Next
            EndWith
            If MouseOverGadget <> -1
              If SavPBCursor <> #PB_Cursor_Arrows
                SetGadgetAttribute(#DrawArea, #PB_Canvas_Cursor, #PB_Cursor_Arrows) : SavPBCursor = #PB_Cursor_Arrows
              EndIf
            Else
              If SavPBCursor <> #PB_Cursor_Default
                SetGadgetAttribute(#DrawArea, #PB_Canvas_Cursor, #PB_Cursor_Default) : SavPBCursor = #PB_Cursor_Default
              EndIf
            EndIf
          Else
            If SelectedDrawGadget <> -1
              With SVDListGadget()
                ForEach SVDListGadget()
                  If \Gadget = SelectedDrawGadget
                    \X = GridMatch(OffsetX - DeltaX, DragSpace, 0, UserScreen_Width-\Width)
                    \Y = GridMatch(OffsetY - DeltaY, DragSpace, 0, UserScreen_Height-\Height)
                    If \X <> SavPosDim\X Or \Y <> SavPosDim\Y Or \Width <> SavPosDim\Width Or \Height <> SavPosDim\Height
                      SavPosDim\X = \X : SavPosDim\Y = \Y : SavPosDim\Width = \Width : SavPosDim\Height = \Height
                      DrawGrid()
                      ResizeHandle(SelectedDrawGadget)
                      ;PostEvent(#PB_Event_Gadget, GetActiveWindow(), SelectedDrawGadget, #SVD_Gadget_Resize, @SavPosDim)
                      PostEvent(#PB_Event_Gadget, 0, SelectedDrawGadget, #SVD_Gadget_Resize, @SavPosDim)      ;For Debug
                    EndIf
                    Break
                  EndIf
                Next
              EndWith 
            EndIf
          EndIf
          
      EndSelect
    EndProcedure
    
    Procedure SVD_WinCallback()
      Static Selected.b, OffsetX.i, OffsetY.i, WinWidth.i, WinHeight.i
      Static ScrollX.i, ScrollY.i, SavPosDim.PosDim
      Protected  WinHandle = EventGadget(), ParentGadget = GetGadgetData(EventGadget())
      
      Select EventType()
        Case #PB_EventType_LeftButtonDown
          Selected = #True
          ;SetActiveGadget(-1)   ;Lost Focus on last Gadget (DragHandle) Selected
          SetActiveDrawAera()
          ;PostEvent(#PB_Event_Gadget, GetActiveWindow(), WinHandle, #SVD_Window_Focus)
          PostEvent(#PB_Event_Gadget, 0, WinHandle, #SVD_Window_Focus)   ;InitWindowSelected
          OffsetX = GetGadgetAttribute(WinHandle, #PB_Canvas_MouseX) : OffsetY = GetGadgetAttribute(WinHandle, #PB_Canvas_MouseY)
          If IsGadget(ParentGadget)
            If GadgetType(ParentGadget) = #PB_GadgetType_ScrollArea
              ScrollX = GadgetX(ParentGadget)-GetGadgetAttribute(ParentGadget, #PB_ScrollArea_X) : ScrollY = GadgetY(ParentGadget)-GetGadgetAttribute(ParentGadget, #PB_ScrollArea_Y)
            Else
              ScrollX = GadgetX(ParentGadget) : ScrollY = GadgetY(ParentGadget)
            EndIf
          ElseIf IsWindow(ParentGadget)   ;Window
            ScrollX = 0 : ScrollY = 0
          EndIf
          
        Case #PB_EventType_LeftButtonUp
          Selected = #False
          
        Case #PB_EventType_MouseMove
          If Selected = #True
            WinWidth = WindowMouseX(0)-OffsetX-ScrollX - 1 : WinHeight = WindowMouseY(0)-OffsetY-ScrollY - 1   ;The border is drawn at +1
                                                                                                               ;<== FOR DEBUG: WinWidth = WindowMouseX(GetActiveWindow())-OffsetX-ScrollX - 1 : WinHeight = WindowMouseY(GetActiveWindow())-OffsetY-ScrollY - 1
            WinWidth = GridMatch(WinWidth, DragSpace, #MinSize, GetGadgetAttribute(ParentGadget, #PB_ScrollArea_InnerWidth) - 10)
            WinHeight = GridMatch(WinHeight, DragSpace, #MinSize, GetGadgetAttribute(ParentGadget, #PB_ScrollArea_InnerHeight) - 10)
            SavPosDim\X = 0 : SavPosDim\Y = 0 : SavPosDim\Width = WinWidth : SavPosDim\Height = WinHeight
            ;PostEvent(#PB_Event_Gadget, GetActiveWindow(), WinHandle, #SVD_Window_ReSize, @SavPosDim)
            PostEvent(#PB_Event_Gadget, 0, WinHandle, #SVD_Window_ReSize, @SavPosDim)   ;Updates the 4 SpinGadget(Width,Height)+UserScreen_Width,UserScreen_Height+Resize(WinHandle)+DrawGrid
          EndIf
          
      EndSelect
    EndProcedure
    
    Procedure SetActiveDrawAera()
      Protected I.i
      ;SetActiveGadget(-1)   ;LOST FOCUS, NO KEYBOARD
      If LastDragHandleFocus > 0 And IsGadget(LastDragHandleFocus) : DrawHandleBorder(LastDragHandleFocus, #FreeHandelColor) : EndIf
      ;If LastDragHandleFocus > 0 And IsGadget(LastDragHandleFocus) : DrawHandleBorder(LastDragHandleFocus, #FreeHandelColor) : EndIf
      If LastGadgetFocus > 1 
        If IsGadget(LastGadgetFocus) : ResizeGadget(LastGadgetFocus, #PB_Ignore, #PB_Ignore, #PB_Ignore, #PB_Ignore) : EndIf
        DrawAreaHandleBorder(LastGadgetFocus, #FreeHandelColor)
      EndIf
      LastGadgetFocus = 0
      LastDragHandleFocus = 0   ;DrawHandleBorder(\DragHandle, #FreeHandelColor)
      SelectedDrawGadget = -1
      For I = 1 To 8
        If GadgetHandle(I)
          UnbindGadgetEvent(GadgetHandle(I), @SVD_Callback())
          HideGadget(GadgetHandle(I),#True)
          ;GadgetHandle(I) = 0 NO
        EndIf
      Next
      RemoveKeyboardShortcut(0, #PB_Shortcut_Delete)
    EndProcedure
    
    Procedure SetActiveDrawGadget(Gadget.i)
      Protected *SVDListGadget.SVDGadget, I.i
      With SVDListGadget()
        ForEach SVDListGadget()
          If \Gadget = Gadget
            If LastDragHandleFocus > 0 And IsGadget(LastDragHandleFocus) : DrawHandleBorder(LastDragHandleFocus, #FreeHandelColor) : EndIf
            If LastGadgetFocus > 1 And IsGadget(LastGadgetFocus) : ResizeGadget(LastGadgetFocus, #PB_Ignore, #PB_Ignore, #PB_Ignore, #PB_Ignore) : EndIf
            ;             If LastGadgetFocus > 1 
            ;               If IsGadget(LastGadgetFocus) : ResizeGadget(LastGadgetFocus, #PB_Ignore, #PB_Ignore, #PB_Ignore, #PB_Ignore) : EndIf
            ;               DrawAreaHandleBorder(LastGadgetFocus, #FreeHandelColor)
            ;             EndIf
            LastGadgetFocus = Gadget
            LastDragHandleFocus = \DragHandle   ;DrawHandleBorder(\DragHandle, #FreeHandelColor)
            SelectedDrawGadget = Gadget
            For I = 1 To 8
              \Handle[I] = GadgetHandle(I)
              SetGadgetData(\Handle[I], SVDListGadget())
              HideGadget(\Handle[I],#False)
              BindGadgetEvent(\Handle[I], @SVD_Callback()) 
            Next
            ResizeHandle(Gadget)
            AddKeyboardShortcut(0, #PB_Shortcut_Delete, #Shortcut_Delete)
            If \DrawGadget = #True
              SavPosDim\X = \X : SavPosDim\Y = \Y : SavPosDim\Width = \Width : SavPosDim\Height = \Height
              ;PostEvent(#PB_Event_Gadget, GetActiveWindow(), Gadget, #SVD_Gadget_Focus, @SavPosDim)
              PostEvent(#PB_Event_Gadget, 0, Gadget, #SVD_Gadget_Focus, SavPosDim)   ;For Debug
            EndIf
            Break
          EndIf
        Next
      EndWith
    EndProcedure
    
    Procedure SetDrawGadgetAttribute(Gadget.i, Caption.s, Option1.s, Option2.s)
      Protected *SVDListGadget.SVDGadget
      With SVDListGadget()
        ForEach SVDListGadget()
          If \Gadget = Gadget
            If Caption <> "-65535" : \Caption = Caption : EndIf
            If Option1 <> "-65535" : \Option1 = Option1 : EndIf
            If Option2 <> "-65535" : \Option2 = Option2 : EndIf
            DrawGrid()
            DrawAreaHandleBorder(Gadget, #HandelColor)
            Break
          EndIf
        Next
      EndWith
    EndProcedure
    
    Procedure SelectSVDGadget(Gadget.i)
      With SVDListGadget()
        ForEach SVDListGadget()
          If \Gadget = Gadget
            If \DrawGadget = #False
              SetActiveGadget(\DragHandle)
            Else
              SetActiveGadget(#DrawArea)   ;To have the keyboard arrows operational right now
              SetActiveDrawGadget(Gadget)
            EndIf
            Break
          EndIf
        Next
      EndWith
    EndProcedure
    
    Procedure DeleteSVDGadget(Gadget.i)
      Protected I.i, K.i, *SVDListGadget.SVDGadget
      ForEach SVDListGadget()
        With SVDListGadget()
          If \Gadget = Gadget
            For I = 1 To 8
              If \Handle[I]
                UnbindGadgetEvent(\Handle[I], @SVD_Callback())                
                SetGadgetData(\Handle[I], #PB_Ignore)
                HideGadget(\Handle[I],#True)
                ;ResizeGadget(\Handle[I], 0, 0, #PB_Ignore, #PB_Ignore)
              EndIf
            Next
            If \DrawGadget = #False
              ;DragHandle
              SortStructuredArray(GadgetDragHandleArray(), #PB_Sort_Descending, OffsetOf(GadgetDragHandle\DragHandle), TypeOf(GadgetDragHandle\DragHandle))
              SortStructuredArray(GadgetDragHandleArray(), #PB_Sort_Descending, OffsetOf(GadgetDragHandle\Gadget), TypeOf(GadgetDragHandle\Gadget))
              For K = 0 To ArraySize(GadgetDragHandleArray())
                If GadgetDragHandleArray(K)\Gadget = Gadget
                  GadgetDragHandleArray(K)\Gadget = 0
                  UnbindGadgetEvent(GadgetDragHandleArray(K)\DragHandle, @SVD_Callback())                
                  SetGadgetData(GadgetDragHandleArray(K)\DragHandle, #PB_Ignore)
                  HideGadget(GadgetDragHandleArray(K)\DragHandle,#True)
                  ;ResizeGadget(\DragHandle, 0, 0, 0, 0)
                  Break
                EndIf
              Next
              DeleteElement(SVDListGadget())
              FreeGadget(Gadget)
            Else
              DeleteElement(SVDListGadget())
              DrawGrid()
            EndIf
            Break
          EndWith
        EndIf
      Next
    EndProcedure
    
    Procedure AddSVDDrawGadget(Gadget.i, Model.s, X.i, Y.i, Width.i, Height.i, Caption.s, Option1.s, Option2.s)
      Protected *SVDListGadget.SVDGadget, I.i
      With SVDListGadget()
        *SVDListGadget = AddElement(SVDListGadget())
        \ParentGadget = #ScrollDrawArea
        \Gadget = Gadget
        \Model = Model.s
        \X = X : \Y = Y : \Width = Width : \Height = Height
        \DrawGadget = #True
        \DragHandle = 0
        \Caption = Caption
        \Option1 = Option1
        \Option2 = Option2
        DrawGrid()
        SetActiveGadget(#DrawArea)   ;To have the keyboard arrows operational right now
        SetActiveDrawGadget(Gadget)
      EndWith
    EndProcedure
    
    Procedure AddSVDGadget(Gadget.i, Model.s)
      Protected *SVDListGadget.SVDGadget, I.i
      With SVDListGadget()
        *SVDListGadget = AddElement(SVDListGadget())
        \ParentGadget = #ScrollDrawArea
        \Gadget = Gadget
        \Model = Model.s
        \X = GadgetX(\Gadget) : \Y = GadgetY(\Gadget) : \Width = GadgetWidth(\Gadget) : \Height = GadgetHeight(\Gadget)
        \DrawGadget = #False
        SortStructuredArray(GadgetDragHandleArray(), #PB_Sort_Descending, OffsetOf(GadgetDragHandle\DragHandle), TypeOf(GadgetDragHandle\DragHandle))
        SortStructuredArray(GadgetDragHandleArray(), #PB_Sort_Ascending, OffsetOf(GadgetDragHandle\Gadget), TypeOf(GadgetDragHandle\Gadget))
        For I = 0 To ArraySize(GadgetDragHandleArray())
          If GadgetDragHandleArray(I)\Gadget = 0 And GadgetDragHandleArray(I)\DragHandle
            \DragHandle = GadgetDragHandleArray(I)\DragHandle
            GadgetDragHandleArray(I)\Gadget = \Gadget
            HideGadget(\DragHandle,#False)
            ResizeGadget(\DragHandle, \X-#OutSideBorder, \Y-#OutSideBorder, \Width+(2*#OutSideBorder), \Height+(2*#OutSideBorder))
            Break
          EndIf
        Next
        SetGadgetData(\DragHandle, SVDListGadget())
        DrawHandleBorder(\DragHandle, #FreeHandelColor)
        BindGadgetEvent(\DragHandle, @SVD_Callback())
        SetActiveGadget(\DragHandle)
      EndWith
    EndProcedure
    
    Procedure DisableSVD()
      Protected *SVDListGadget.SVDGadget, I.i, DftBackColor.i = $F0F0F0
      CompilerIf #PB_Compiler_OS = #PB_OS_MacOS : DftBackColor = $C0C0C0 : CompilerEndIf
      ;UnbindGadgetEvent for Drawn Gadgets (Container + Frame)
      UnbindGadgetEvent(#DrawArea, @SVD_DrawCallback())
      DisableGadget(#DrawArea, #True)
      ;Remove the draw border around Draw Gadget
      With SVDListGadget()
        ForEach SVDListGadget()
          If \DrawGadget = #True
            DrawAreaHandleBorder(\Gadget, DftBackColor)
          Else
            CompilerIf #PB_Compiler_OS = #PB_OS_MacOS
              DisableGadget(\Gadget, #False)
            CompilerEndIf
          EndIf
        Next
      EndWith
      
      ;Handles
      For I = 0 To 8
        If I = 0
          UnbindGadgetEvent(GadgetHandle(0), @SVD_WinCallback())
        Else
          UnbindGadgetEvent(GadgetHandle(I), @SVD_Callback())
          ResizeGadget(GadgetHandle(I), 0, 0, #PB_Ignore, #PB_Ignore)
        EndIf
        SetGadgetData(GadgetHandle(I), #PB_Ignore)
        HideGadget(GadgetHandle(I),#True)
      Next
      ;DragHandle
      SortStructuredArray(GadgetDragHandleArray(), #PB_Sort_Descending, OffsetOf(GadgetDragHandle\DragHandle), TypeOf(GadgetDragHandle\DragHandle))
      SortStructuredArray(GadgetDragHandleArray(), #PB_Sort_Descending, OffsetOf(GadgetDragHandle\Gadget), TypeOf(GadgetDragHandle\Gadget))
      For I = 0 To ArraySize(GadgetDragHandleArray())
        With GadgetDragHandleArray(I)
          If \Gadget <> 0
            \Gadget = 0
            UnbindGadgetEvent(\DragHandle, @SVD_Callback())
            SetGadgetData(\DragHandle, #PB_Ignore)
            HideGadget(\DragHandle,#False)
            ResizeGadget(\DragHandle, 0, 0, 0, 0)
          Else
            Break
          EndIf
        Next
      EndWith
      ResizeGadget(#ScrollDrawArea, #PB_Ignore, #PB_Ignore, #PB_Ignore, #PB_Ignore)
      ;ClearList(SVDListGadget())   ;TagClearList: with Enumerate Object To fill the list
    EndProcedure
    
    Procedure EnableSVD()
      Protected *SVDListGadget.SVDGadget, GadgetObj.i, I.i
      ;       With *SVDListGadget      ;TagClearList: Enumerate Object To fill the list in common with ClearList
      ;         ;If PB_Object_EnumerateNext(PB_Window_Objects, @Window) : Debug Str(Window)+" - "+Str(GetWindowData(Window)) : EndIf
      ;         PB_Object_EnumerateStart(PB_Gadget_Objects)
      ;         While PB_Object_EnumerateNext(PB_Gadget_Objects, @GadgetObj)
      ;           If GetGadgetData(GadgetObj) <> #PB_Ignore And GadgetObj <> #ScrollDrawArea
      ;             *SVDListGadget = AddElement(SVDListGadget())
      ;             \ParentGadget = #ScrollDrawArea
      ;             \Gadget = GadgetObj
      ;             \Model = GadgetObj
      ;           EndIf
      ;         Wend
      ;       EndWith
      
      BindGadgetEvent(#DrawArea, @SVD_DrawCallback())   ;BindGadgetEvent for Drawn Gadgets (Container + Frame)
      DisableGadget(#DrawArea, #False)
      ;Resize and Enable Drag Handle
      SortStructuredArray(GadgetDragHandleArray(), #PB_Sort_Descending, OffsetOf(GadgetDragHandle\DragHandle), TypeOf(GadgetDragHandle\DragHandle))
      SortStructuredArray(GadgetDragHandleArray(), #PB_Sort_Ascending, OffsetOf(GadgetDragHandle\Gadget), TypeOf(GadgetDragHandle\Gadget))
      With SVDListGadget()
        ForEach SVDListGadget()
          If \DrawGadget = #False
            For I = 0 To ArraySize(GadgetDragHandleArray())
              If GadgetDragHandleArray(I)\Gadget = 0 And GadgetDragHandleArray(I)\DragHandle
                \DragHandle = GadgetDragHandleArray(I)\DragHandle
                GadgetDragHandleArray(I)\Gadget = \Gadget
                HideGadget(\DragHandle,#False)
                ResizeGadget(\DragHandle, \X-#OutSideBorder, \Y-#OutSideBorder, \Width+(2*#OutSideBorder), \Height+(2*#OutSideBorder))
                ResizeGadget(\Gadget, #PB_Ignore, #PB_Ignore, #PB_Ignore, #PB_Ignore)
                CompilerIf #PB_Compiler_OS = #PB_OS_MacOS
                  DisableGadget(\Gadget, #True)
                CompilerEndIf
                Break
              EndIf
            Next
            SetGadgetData(\DragHandle, SVDListGadget())
            DrawHandleBorder(\DragHandle, #FreeHandelColor)
            BindGadgetEvent(\DragHandle, @SVD_Callback())
          Else
            ;DrawGrid()
            ;DrawHandleBorder(\DragHandle, #FreeHandelColor)
          EndIf
        Next
      EndWith
      
      HideGadget(GadgetHandle(0),#False)
      SetGadgetData(GadgetHandle(0), #ScrollDrawArea)
      BindGadgetEvent(GadgetHandle(0), @SVD_WinCallback(), #PB_EventType_LeftButtonDown)
      BindGadgetEvent(GadgetHandle(0), @SVD_WinCallback(), #PB_EventType_LeftButtonUp)
      BindGadgetEvent(GadgetHandle(0), @SVD_WinCallback(), #PB_EventType_MouseMove)
    EndProcedure
    
    Procedure DrawAreaSize(Width.i, Height.i)
      UserScreen_Width = Width
      UserScreen_Height = Height
      If IsGadget(GadgetHandle(0)) : ResizeGadget(GadgetHandle(0), Width, Height, #PB_Ignore, #PB_Ignore) : EndIf
    EndProcedure 
    
    Procedure InitSVD(CountGadget.i = 144)
      Protected ScrollDrawAreaWidth.i, ScrollDrawAreaHeight.i, Mycursors.i, I.i
      ;Width and Height of the drawing Area used as Max values when moving
      If IsGadget(#ScrollDrawArea)
        If GadgetType(#ScrollDrawArea) = #PB_GadgetType_ScrollArea
          ScrollDrawAreaWidth = GetGadgetAttribute(#ScrollDrawArea, #PB_ScrollArea_InnerWidth)
          ScrollDrawAreaHeight = GetGadgetAttribute(#ScrollDrawArea, #PB_ScrollArea_InnerHeight)
        Else
          ScrollDrawAreaWidth = GadgetWidth(#ScrollDrawArea)
          ScrollDrawAreaHeight = GadgetHeight(#ScrollDrawArea)
        EndIf
      ElseIf IsWindow(#ScrollDrawArea)   ;Window
        ScrollDrawAreaWidth = WindowWidth(#ScrollDrawArea)
        ScrollDrawAreaHeight = WindowHeight(#ScrollDrawArea)
      EndIf
      
      ;Draw Grid on Canvas disabled
      CompilerIf #PB_Compiler_OS = #PB_OS_Windows
        CanvasGadget(#DrawArea, 0, 0, ScrollDrawAreaWidth, ScrollDrawAreaHeight, #PB_Canvas_Keyboard | #PB_Canvas_Container)   ;Resize with Handles does not work with #PB_Canvas_Keyboard
      CompilerElse
        CanvasGadget(#DrawArea, 0, 0, ScrollDrawAreaWidth, ScrollDrawAreaHeight, #PB_Canvas_Keyboard)   ;Resize with Handles does not work with #PB_Canvas_Keyboard
      CompilerEndIf
      SetGadgetData(#DrawArea, #PB_Ignore)   ;: DisableGadget(#DrawArea,#True)
      
      ;Create Drag Handles canvas in advance, rather than creating each gadget is easier
      ;With many canvas create in advance, it is little bit longer at startup but it does not cost much more in Ram
      ;Create Drag Handle size 0 disable and hidden, used then behind the gadget
      ReDim GadgetDragHandleArray(CountGadget)
      For I = 0 To CountGadget
        GadgetDragHandleArray(I)\DragHandle = CanvasGadget(#PB_Any, 0, 0, 0, 0, #PB_Canvas_Keyboard)
        HideGadget(GadgetDragHandleArray(I)\DragHandle,#True)
        SetGadgetData(GadgetDragHandleArray(I)\DragHandle, #PB_Ignore)
        CompilerIf #PB_Compiler_OS = #PB_OS_MacOS
          SetGadgetAttribute(GadgetDragHandleArray(I)\DragHandle, #PB_Canvas_Cursor, #PB_Cursor_Hand)
        CompilerElse
          SetGadgetAttribute(GadgetDragHandleArray(I)\DragHandle, #PB_Canvas_Cursor, #PB_Cursor_Arrows)
        CompilerEndIf
      Next
      SortStructuredArray(GadgetDragHandleArray(), #PB_Sort_Descending, OffsetOf(GadgetDragHandle\DragHandle), TypeOf(GadgetDragHandle\DragHandle))
      
      ;Create Handle 1 To 8: North, North-East, East, South-East, South, South-West, West, North-West 
      Restore Cursors
      Read.i Mycursors   ;Position 0 used for the drawing area bottom left
      For I = 0 To 8
        GadgetHandle(I) = CanvasGadget(#PB_Any, 0, 0, #HandelSize, #HandelSize)
        HideGadget(GadgetHandle(I),#True)
        If I = 0
          DrawHandleBorder(GadgetHandle(I), #WinHandleColor)   ;Drawing area handle
        Else
          DrawHandleBorder(GadgetHandle(I), #HandelColor)
        EndIf
        Read.i Mycursors
        SetGadgetData(GadgetHandle(I), #PB_Ignore)
        SetGadgetAttribute(GadgetHandle(I), #PB_Canvas_Cursor, Mycursors)
      Next
      
      DataSection
        CompilerIf #PB_Compiler_OS = #PB_OS_Windows
          Cursors:          
          Data.i 0, #PB_Cursor_LeftUpRightDown, #PB_Cursor_UpDown, #PB_Cursor_LeftDownRightUp, #PB_Cursor_LeftRight, #PB_Cursor_LeftUpRightDown
          Data.i #PB_Cursor_UpDown, #PB_Cursor_LeftDownRightUp, #PB_Cursor_LeftRight, #PB_Cursor_LeftUpRightDown
        CompilerElse
          Cursors:          
          Data.i 0, #PB_Cursor_Cross, #PB_Cursor_UpDown, #PB_Cursor_Cross, #PB_Cursor_LeftRight, #PB_Cursor_Cross
          Data.i #PB_Cursor_UpDown, #PB_Cursor_Cross, #PB_Cursor_LeftRight, #PB_Cursor_Cross
        CompilerEndIf
      EndDataSection
    EndProcedure  
  EndModule
  
; IDE Options = PureBasic 5.60 (Windows - x64)
; Folding = -------
; EnableXP
; Executable = SweetyVD.exe
; EnablePurifier