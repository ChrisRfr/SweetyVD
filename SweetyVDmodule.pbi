; ---------------------------------------------------------------------------------------
;           Name: SweetyVDmodule
;    Description: Sweety Visual Designer Module
;         Author: ChrisR
;           Date: 2017-04-04
;        Version: 1.8.0
;     PB-Version: 5.4* LTS, 5.5*, 5.60 (x86/x64)
;             OS: Windows, Linux, Mac
;         Credit: STARGÅTE: Transformation of gadgets at runtime
;         Credit: Falsam: Tiny Visual Designer (TVD)
;  English-Forum: http://www.purebasic.fr/english/viewtopic.php?f=27&t=68187
;   French-Forum: http://www.purebasic.fr/french/viewtopic.php?f=3&t=16527
; ---------------------------------------------------------------------------------------

DeclareModule SVDesigner
  
  Enumeration #PB_EventType_FirstCustomValue
    #SVD_Gadget_Focus       ; This Event fired to the window if a gadget get focus
    #SVD_Gadget_LostFocus   ; This Event fired to the window if a gadget Lost focus
    #SVD_Gadget_Resize      ; This Event fired to the window if a gadget is resized
    #SVD_WinSize            ; This Event fired to the window if the DrawArea is resized
  EndEnumeration
  
  Enumeration 1000
    #DrawArea
    #Shortcut_Delete
  EndEnumeration
  
  Structure PosDim
    X.i
    Y.i
    Width.i
    Height.i
  EndStructure
  
  Global ParentWidth.i, ParentHeight.i
  Global MyGrid.i, LastGadgetFocus.i, LastDragHandleFocus.i
  
  Declare DrawGrid(Visible.b, GridSpacing.i=20)
  Declare.i GridMatch(Value.i, Grid.i=1, Min.i=0, Max.i=$7FFFFFFF)
  Declare DrawHandleBorder(DragHandle.i, BorderColor.i)
  Declare ResizeSVDGadget(Gadget.i, X.i, Y.i, Width.i, Height.i)  
  Declare ResizeHandle(Gadget)
  Declare SVD_Callback()
  Declare SVD_WinCallback()
  Declare SelectSVDGadget(Gadget.i)
  Declare DeleteSVDGadgetFromDragHandle(DragHandle.i)
  Declare DeleteSVDGadget(Gadget.i)
  Declare DisableSVD()
  Declare AddSVDGadget(ParentGadget.i, Gadget.i)
  Declare EnableSVD(ParentGadget.i, Grid.i=10)
  Declare DrawAreaSize(Width.i, Height.i)
  Declare InitSVD(ParentGadget.i, CountGadget.i = 144)
  
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
    
    #HandelSize = 7
    #MinSize = 6
    #HandelColor = $640000      ;BlueDark
    #WinHandleColor= $000064    ;RedDark
    #FreeHandelColor = $FF8080  ;White=$FFFFFF, grey=$C6C6C6
    CompilerIf #PB_Compiler_OS = #PB_OS_MacOS
      #OutSideBorder = 2
    CompilerElse
      #OutSideBorder = 1
    CompilerEndIf
    
    Structure SVDGadget
      ParentGadget.i
      Gadget.i
      DragHandle.i
      Handle.i[9]
      TypeGadget.i
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
    
    Procedure DrawGrid(Visible.b, GridSpacing.i=20)
      ;Notes: To display the gadgets after grid drawing (canvas), we need resize the gadgets and the move handles
      Protected GridBackground.i = RGB(225,230,235), GridColor.i = RGB(204,204,206), DftBackColor.i = $F0F0F0
      Protected X.i, Y.i 
      If Visible = #False
        CompilerIf #PB_Compiler_OS = #PB_OS_MacOS : DftBackColor = $C0C0C0 : CompilerEndIf
        GridSpacing = 8192 : GridBackground = DftBackColor
      EndIf
      StartDrawing(CanvasOutput(#DrawArea))
      Box(0, 0, OutputWidth(), OutputHeight(), DftBackColor)
      Box(X, Y, ParentWidth, ParentHeight, GridBackground)
      For X = 0 To ParentWidth
        For Y = 0 To ParentHeight
          Line(0,Y,ParentWidth,1,GridColor)
          Y+GridSpacing-1
        Next
        Line(X,0,1,ParentHeight,GridColor)
        X+GridSpacing-1
      Next
      Line(0, ParentHeight, ParentWidth, 1, #WinHandleColor)
      Line(ParentWidth, 0, 1, ParentHeight, #WinHandleColor)
      StopDrawing()
      ;To redraw Gadget and DragHandle above the grid
      If IsGadget(GadgetHandle(0)) : ResizeGadget(GadgetHandle(0), #PB_Ignore, #PB_Ignore, #PB_Ignore, #PB_Ignore) : EndIf
      With SVDListGadget()
        ForEach SVDListGadget()
          ResizeGadget(\Gadget, #PB_Ignore, #PB_Ignore, #PB_Ignore, #PB_Ignore)
          ResizeGadget(\DragHandle, #PB_Ignore, #PB_Ignore, #PB_Ignore, #PB_Ignore)
        Next
      EndWith
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
    
    Procedure DrawHandleBorder(DragHandle.i, BorderColor.i)
      If StartDrawing(CanvasOutput(DragHandle))   ;Delete the border around the gadget
        Box(0, 0, OutputWidth(), OutputHeight(), BorderColor)
        Box(1, 1, OutputWidth()-2, OutputHeight()-2, $FFFFFF)
        StopDrawing()
      EndIf
    EndProcedure  
    
    Procedure ResizeSVDGadget(Gadget.i, X.i, Y.i, Width.i, Height.i)
      Protected *SVDListGadget.SVDGadget
      If IsGadget(Gadget) = 0 Or ParentWidth= 0 Or ParentHeight = 0
        ProcedureReturn #False
      EndIf
      With SVDListGadget()
        ForEach SVDListGadget()
          If \Gadget = Gadget
            ;Only one of the values X, Y, Width or Height. Sent from an interface, with control there. other values must be negative (#PB_Ignore=-65535)
            If X >= 0 And Y < 0 And Width < 0 And Height < 0
              ResizeGadget(Gadget, GridMatch(X, 1, 0, ParentWidth-GadgetWidth(Gadget)), #PB_Ignore, #PB_Ignore, #PB_Ignore)
            ElseIf Y >= 0 And X < 0 And Width < 0 And Height < 0
              ResizeGadget(Gadget, #PB_Ignore, GridMatch(Y, 1, 0, ParentHeight-GadgetHeight(Gadget)), #PB_Ignore, #PB_Ignore)
            ElseIf Width >= 0 And X < 0 And Y < 0 And Height < 0
              ResizeGadget(Gadget, #PB_Ignore, #PB_Ignore, GridMatch(Width, 1, 0, ParentWidth-GadgetX(Gadget)), #PB_Ignore)
            ElseIf Height >= 0 And X < 0 And Y < 0 And Width < 0
              ResizeGadget(Gadget, #PB_Ignore, #PB_Ignore, #PB_Ignore, GridMatch(Height, 1, 0, ParentHeight-GadgetY(Gadget)))
            Else
              ProcedureReturn #False
            EndIf          
            ResizeHandle(Gadget)
          EndIf
        Next
      EndWith
    EndProcedure
    
    Procedure ResizeHandle(Gadget)
      Protected *SVDListGadget.SVDGadget
      Protected GadgetX0 = GadgetX(Gadget), GadgetWidth0 = GadgetWidth(Gadget), GadgetX1 = GadgetX0 + GadgetWidth0
      Protected GadgetY0 = GadgetY(Gadget), GadgetHeight0 = GadgetHeight(Gadget), GadgetY1 = GadgetY0 + GadgetHeight0
      
      With SVDListGadget()
        ForEach SVDListGadget()
          If \Gadget = Gadget
            If \DragHandle   ;Moved Handle
              ResizeGadget(\DragHandle, GadgetX0-#OutSideBorder, GadgetY0-#OutSideBorder, GadgetWidth0+(2*#OutSideBorder), GadgetHeight0+(2*#OutSideBorder))
              DrawHandleBorder(\DragHandle, #HandelColor)
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
      ;Notes: To display the gadgets after drag Handles resizing (canvas), we need resize to the gadgets
      ;We need to do it here for events : #PB_EventType_Focus, #PB_EventType_LostFocus, #PB_EventType_KeyDown (If Resize Done)
      ;                 #PB_EventType_RightButtonDown, #PB_EventType_MiddleButtonDown, #PB_EventType_LeftButtonDown
      ; -----------------------------------------------------------------------------------------------------------
      ;Canvas Event: MouseEnter=65537, MouseLeave=65538, MouseMove=65539, MouseWheel=65546, LeftButtonDown=65540
      ;  LeftButtonUp=65541, LeftClick=0, LeftDoubleClick=2, RightButtonDown=65542, RightButtonUp=65543
      ;  RightClick=13111, RightDoubleClick=3, MiddleButtonDown=65544, MiddleButtonUp=65545, Focus=14000, LostFocus=14001
      ;  KeyDown=65547, KeyUp=65548, Input=65549, Resize=6        
      Static Selected.i, X.i, Y.i, OffsetX.i, OffsetY.i, GadgetX0.i, GadgetWidth0, GadgetX1.i, GadgetY0.i, GadgetHeight0, GadgetY1.i
      Static ScrollX.i, ScrollY.i, SavPosDim.PosDim
      Protected *SVDListGadget.SVDGadget = GetGadgetData(EventGadget()), TmpWidth.i, TmpHeight.i, ResizeDone.b, I.i
      With *SVDListGadget
        Select EventType()
            
          Case #PB_EventType_Focus
            If \DragHandle = EventGadget()
              If LastDragHandleFocus > 0 And IsGadget(LastDragHandleFocus) : DrawHandleBorder(LastDragHandleFocus, #FreeHandelColor) : EndIf
              If LastGadgetFocus > 1 And IsGadget(LastGadgetFocus) : ResizeGadget(LastGadgetFocus, #PB_Ignore, #PB_Ignore, #PB_Ignore, #PB_Ignore) : EndIf
              For I = 1 To 8
                \Handle[I] = GadgetHandle(I)
                SetGadgetData(\Handle[I], *SVDListGadget)
                HideGadget(\Handle[I],#False)
                BindGadgetEvent(\Handle[I], @SVD_Callback()) 
              Next
              ResizeHandle(\Gadget)
            EndIf  
            ResizeGadget(\Gadget, #PB_Ignore, #PB_Ignore, #PB_Ignore, #PB_Ignore)   ;to avoid a white frame (=canvas) instead of gadget
            AddKeyboardShortcut(0, #PB_Shortcut_Delete, #Shortcut_Delete)
            SavPosDim\X = GadgetX(\Gadget) : SavPosDim\Y = GadgetY(\Gadget) : SavPosDim\Width = GadgetWidth(\Gadget) : SavPosDim\Height = GadgetHeight(\Gadget)
            ;PostEvent(#PB_Event_Gadget, GetActiveWindow(), \Gadget, #SVD_Gadget_Focus, @SavPosDim)
            PostEvent(#PB_Event_Gadget, 0, \Gadget, #SVD_Gadget_Focus, @SavPosDim)   ;For Debug
            
          Case #PB_EventType_LostFocus
            If \DragHandle = EventGadget()
              LastGadgetFocus = \Gadget
              LastDragHandleFocus = \DragHandle   ;DrawHandleBorder(\DragHandle, #FreeHandelColor)
              For I = 1 To 8
                If \Handle[I]
                  UnbindGadgetEvent(\Handle[I], @SVD_Callback())
                  HideGadget(\Handle[I],#True)
                  \Handle[I] = 0
                EndIf
              Next
            EndIf 
            ResizeGadget(\Gadget, #PB_Ignore, #PB_Ignore, #PB_Ignore, #PB_Ignore)   ;to avoid a white frame (=canvas) instead of gadget
            RemoveKeyboardShortcut(0, #PB_Shortcut_Delete)
            ;Do not Post Event to keep X, Y, Width, Height SpinGadget on hand
            
          Case #PB_EventType_KeyDown
            GadgetX0 = GadgetX(\Gadget) : GadgetWidth0 = GadgetWidth(\Gadget) : GadgetX1 = GadgetX0 + GadgetWidth0
            GadgetY0 = GadgetY(\Gadget) : GadgetHeight0 = GadgetHeight(\Gadget) : GadgetY1 = GadgetY0 + GadgetHeight0
            Select GetGadgetAttribute(EventGadget(),#PB_Canvas_Key)
              Case #PB_Shortcut_Up
                If GetGadgetAttribute(\DragHandle, #PB_Canvas_Modifiers) = #PB_Canvas_Shift And IsGadget(\Handle[1])
                  ResizeGadget(\Gadget, #PB_Ignore, #PB_Ignore, #PB_Ignore, GridMatch(GadgetHeight0-MyGrid, MyGrid, #MinSize)) : ResizeDone = #True 
                ElseIf IsGadget(\DragHandle) Or IsGadget(\Handle[1])
                  ResizeGadget(\Gadget, #PB_Ignore, GridMatch(GadgetY0-MyGrid, MyGrid, 0), #PB_Ignore, #PB_Ignore) : ResizeDone = #True
                EndIf
              Case #PB_Shortcut_Right
                If GetGadgetAttribute(\DragHandle,#PB_Canvas_Modifiers) = #PB_Canvas_Shift And IsGadget(\Handle[3])
                  ResizeGadget(\Gadget, #PB_Ignore, #PB_Ignore, GridMatch(GadgetWidth0+MyGrid, MyGrid, 0, ParentWidth-GadgetX0), #PB_Ignore) : ResizeDone = #True
                ElseIf IsGadget(\DragHandle) Or IsGadget(\Handle[3])
                  ResizeGadget(\Gadget, GridMatch(GadgetX0+MyGrid, MyGrid, 0, ParentWidth-GadgetWidth0), #PB_Ignore, #PB_Ignore, #PB_Ignore) : ResizeDone = #True
                EndIf
              Case #PB_Shortcut_Down
                If GetGadgetAttribute(\DragHandle, #PB_Canvas_Modifiers) = #PB_Canvas_Shift And IsGadget(\Handle[5])
                  ResizeGadget(\Gadget, #PB_Ignore, #PB_Ignore, #PB_Ignore, GridMatch(GadgetHeight0+MyGrid, MyGrid, 0, ParentHeight-GadgetY0)) : ResizeDone = #True
                ElseIf IsGadget(\DragHandle) Or IsGadget(\Handle[5])
                  ResizeGadget(\Gadget, #PB_Ignore, GridMatch(GadgetY0+MyGrid, MyGrid, 0, ParentHeight-GadgetHeight0), #PB_Ignore, #PB_Ignore) : ResizeDone = #True
                EndIf
              Case #PB_Shortcut_Left
                If GetGadgetAttribute(\DragHandle, #PB_Canvas_Modifiers) = #PB_Canvas_Shift And IsGadget(\Handle[7])
                  ResizeGadget(\Gadget, #PB_Ignore, #PB_Ignore, GridMatch(GadgetWidth0-MyGrid, MyGrid, #MinSize), #PB_Ignore) : ResizeDone = #True
                ElseIf IsGadget(\DragHandle) Or IsGadget(\Handle[7])
                  ResizeGadget(\Gadget, GridMatch(GadgetX0-MyGrid, MyGrid, 0), #PB_Ignore, #PB_Ignore, #PB_Ignore) : ResizeDone = #True
                EndIf
            EndSelect
            If ResizeDone
              ResizeHandle(\Gadget)
              ResizeGadget(\Gadget, #PB_Ignore, #PB_Ignore, #PB_Ignore, #PB_Ignore)   ;to avoid a white frame (=canvas) instead of gadget
              SavPosDim\X = GadgetX(\Gadget) : SavPosDim\Y = GadgetY(\Gadget) : SavPosDim\Width = GadgetWidth(\Gadget) : SavPosDim\Height = GadgetHeight(\Gadget)
              ;PostEvent(#PB_Event_Gadget, GetActiveWindow(), \Gadget, #SVD_Gadget_Resize, @SavPosDim)
              PostEvent(#PB_Event_Gadget, 0, \Gadget, #SVD_Gadget_Resize, @SavPosDim)   ;For Debug
              ResizeDone = #False
            EndIf
            
          Case #PB_EventType_RightButtonDown
            ResizeGadget(\Gadget, #PB_Ignore, #PB_Ignore, #PB_Ignore, #PB_Ignore)   ;to avoid a white frame (=canvas) instead of gadget
            
          Case #PB_EventType_MiddleButtonDown
            ResizeGadget(\Gadget, #PB_Ignore, #PB_Ignore, #PB_Ignore, #PB_Ignore)   ;to avoid a white frame (=canvas) instead of gadget
            
          Case #PB_EventType_LeftButtonDown
            Selected = #True
            OffsetX = GetGadgetAttribute(EventGadget(), #PB_Canvas_MouseX) : OffsetY = GetGadgetAttribute(EventGadget(), #PB_Canvas_MouseY)
            GadgetX0 = GadgetX(\Gadget) : GadgetWidth0 = GadgetWidth(\Gadget) : GadgetX1 = GadgetX0 + GadgetWidth0
            GadgetY0 = GadgetY(\Gadget) : GadgetHeight0 = GadgetHeight(\Gadget) :GadgetY1 = GadgetY0 + GadgetHeight0
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
            ResizeGadget(\Gadget, #PB_Ignore, #PB_Ignore, #PB_Ignore, #PB_Ignore)   ;to avoid a white frame (=canvas) instead of gadget 
            
          Case #PB_EventType_LeftButtonUp
            Selected = #False
            
          Case #PB_EventType_MouseMove
            If Selected
              X = WindowMouseX(0)-OffsetX-ScrollX : Y = WindowMouseY(0)-OffsetY-ScrollY
              ;<== FOR DEBUG: X = WindowMouseX(GetActiveWindow())-OffsetX-ScrollX : Y = WindowMouseY(GetActiveWindow())-OffsetY-ScrollY
              Select EventGadget()
                Case \DragHandle   ;Moved Gadget NESW
                  ResizeGadget(\Gadget, GridMatch(X+#OutSideBorder, MyGrid, 0, ParentWidth-GadgetWidth0), GridMatch(Y+#OutSideBorder, MyGrid, 0, ParentHeight-GadgetHeight0), #PB_Ignore, #PB_Ignore)
                Case \Handle[1]   ;Handle top, middle (N)
                  TmpWidth = GridMatch(GadgetY1-(Y+#HandelSize), MyGrid, #MinSize, GadgetY1)
                  ResizeGadget(\Gadget, #PB_Ignore, GridMatch(Y+#HandelSize, MyGrid, 0, GadgetY1-TmpWidth), #PB_Ignore, TmpWidth)
                Case \Handle[2]   ;Handle top, right (NE)
                  TmpWidth = GridMatch(GadgetY1-(Y+#HandelSize), MyGrid, #MinSize, GadgetY1)
                  ResizeGadget(\Gadget, #PB_Ignore, GridMatch(Y+#HandelSize, MyGrid, 0, GadgetY1-TmpWidth), GridMatch(X, MyGrid, GadgetX0+#MinSize, ParentWidth)-GadgetX0, TmpWidth)
                Case \Handle[3]   ;Handle middle, right (E)
                  ResizeGadget(\Gadget, #PB_Ignore, #PB_Ignore, GridMatch(X, MyGrid, GadgetX0+#MinSize, ParentWidth)-GadgetX0, #PB_Ignore)
                Case \Handle[4]   ;Handle bottom, right (SE)
                  ResizeGadget(\Gadget, #PB_Ignore, #PB_Ignore, GridMatch(X, MyGrid, GadgetX0+#MinSize, ParentWidth)-GadgetX0, GridMatch(Y, MyGrid, GadgetY0+#MinSize, ParentHeight)-GadgetY0)
                Case \Handle[5]   ;Handle bottom, middle (S)
                  ResizeGadget(\Gadget, #PB_Ignore, #PB_Ignore, #PB_Ignore, GridMatch(Y, MyGrid, GadgetY0+#MinSize, ParentHeight)-GadgetY0)
                Case \Handle[6]   ;Handle bottom, left (SW)
                  TmpHeight = GridMatch(GadgetX1-(X+#HandelSize), MyGrid, #MinSize, GadgetX1)
                  ResizeGadget(\Gadget, GridMatch(X+#HandelSize, MyGrid, 0, GadgetX1-TmpHeight), #PB_Ignore, TmpHeight, GridMatch(Y, MyGrid, GadgetY0+#MinSize, ParentHeight)-GadgetY0)
                Case \Handle[7]   ;Handle middle, left (W)
                  TmpHeight = GridMatch(GadgetX1-(X+#HandelSize), MyGrid, #MinSize, GadgetX1)
                  ResizeGadget(\Gadget, GridMatch(X+#HandelSize, MyGrid, 0, GadgetX1-TmpHeight), #PB_Ignore, TmpHeight, #PB_Ignore)
                Case \Handle[8]   ;Handle top, left (NW)
                  TmpWidth = GridMatch(GadgetY1-(Y+#HandelSize), MyGrid, #MinSize, GadgetY1)
                  TmpHeight = GridMatch(GadgetX1-(X+#HandelSize), MyGrid, #MinSize, GadgetX1)
                  ResizeGadget(\Gadget, GridMatch(X+#HandelSize, MyGrid, 0, GadgetX1-TmpHeight), GridMatch(Y+#HandelSize, MyGrid, 0, GadgetY1-TmpWidth), TmpHeight, TmpWidth)
              EndSelect
              ;Check move or resize, the gadgets are moved following Drag Spacing 
              If GadgetX(\Gadget) <> SavPosDim\X Or GadgetY(\Gadget) <> SavPosDim\Y Or GadgetWidth(\Gadget) <> SavPosDim\Width Or GadgetHeight(\Gadget) <> SavPosDim\Height
                ResizeHandle(\Gadget)
                SavPosDim\X = GadgetX(\Gadget) : SavPosDim\Y = GadgetY(\Gadget) : SavPosDim\Width = GadgetWidth(\Gadget) : SavPosDim\Height = GadgetHeight(\Gadget)
                ;PostEvent(#PB_Event_Gadget, GetActiveWindow(), \Gadget, #SVD_Gadget_Resize, @SavPosDim)
                PostEvent(#PB_Event_Gadget, 0, \Gadget, #SVD_Gadget_Resize, @SavPosDim)      ;For Debug
              EndIf
            EndIf
        EndSelect
      EndWith
    EndProcedure
    
    Procedure SVD_WinCallback()
      Static Selected.i, OffsetX.i, OffsetY.i, WinWidth.i, WinHeight.i
      Static ScrollX.i, ScrollY.i, SavPosDim.PosDim
      Protected  WinHandle = EventGadget(), ParentGadget = GetGadgetData(EventGadget())
      
      Select EventType()
        Case #PB_EventType_LeftButtonDown
          Selected = #True
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
            WinWidth = GridMatch(WinWidth, MyGrid, #MinSize, GetGadgetAttribute(ParentGadget, #PB_ScrollArea_InnerWidth) - 10)
            WinHeight = GridMatch(WinHeight, MyGrid, #MinSize, GetGadgetAttribute(ParentGadget, #PB_ScrollArea_InnerHeight) - 10)
            SavPosDim\X = 0 : SavPosDim\Y = 0 : SavPosDim\Width = WinWidth : SavPosDim\Height = WinHeight
            ;PostEvent(#PB_Event_Gadget, GetActiveWindow(), \Gadget, #SVD_WinSize, @SavPosDim)
            PostEvent(#PB_Event_Gadget, 0, WinHandle, #SVD_WinSize, @SavPosDim)   ;Updates the 4 SpinGadget(Width,Height)+ParentWidth,ParentHeight+Resize(WinHandle)+DrawGrid
          EndIf
          
      EndSelect
    EndProcedure
    
    Procedure SelectSVDGadget(Gadget.i)
      If IsGadget(Gadget) = 0
        ProcedureReturn #False
      EndIf
      With SVDListGadget()
        ForEach SVDListGadget()
          If \Gadget = Gadget
            SetActiveGadget(\DragHandle)
            Break
          EndIf
        Next
      EndWith
    EndProcedure
    
    Procedure DeleteSVDGadgetFromDragHandle(DragHandle.i)
      Protected *SVDListGadget.SVDGadget
      If IsGadget(DragHandle) = 0 
        ProcedureReturn #False
      EndIf
      SetActiveGadget(-1)    ;To lost focus before deleting
      With SVDListGadget()   ;Delete Gadget by calling DeleteSVDGadget. It could be done directly but better to call the same delete procedure
        ForEach SVDListGadget()
          If \DragHandle = DragHandle
            DeleteSVDGadget(\Gadget)
          EndIf
        Next
      EndWith
    EndProcedure    
    
    Procedure DeleteSVDGadget(Gadget.i)
      Protected I.i, K.i, *SVDListGadget.SVDGadget
      If IsGadget(Gadget) = 0 
        ProcedureReturn #False
      EndIf
      ForEach SVDListGadget()
        If SVDListGadget()\Gadget = Gadget
          With SVDListGadget()
            For I = 1 To 8
              If \Handle[I]
                UnbindGadgetEvent(\Handle[I], @SVD_Callback())                
                SetGadgetData(\Handle[I], #PB_Ignore)
                HideGadget(\Handle[I],#True)
                ResizeGadget(\Handle[I], 0, 0, #PB_Ignore, #PB_Ignore)
              EndIf
            Next
          EndWith
          ;DragHandle
          SortStructuredArray(GadgetDragHandleArray(), #PB_Sort_Descending, OffsetOf(GadgetDragHandle\DragHandle), TypeOf(GadgetDragHandle\DragHandle))
          SortStructuredArray(GadgetDragHandleArray(), #PB_Sort_Descending, OffsetOf(GadgetDragHandle\Gadget), TypeOf(GadgetDragHandle\Gadget))
          For K = 0 To ArraySize(GadgetDragHandleArray())
            With GadgetDragHandleArray(K)
              If \Gadget = Gadget
                \Gadget = 0
                UnbindGadgetEvent(\DragHandle, @SVD_Callback())                
                SetGadgetData(\DragHandle, #PB_Ignore)
                HideGadget(\DragHandle,#True)
                ResizeGadget(\DragHandle, 0, 0, 0, 0)
                Break
              EndIf
            Next
          EndWith
          DeleteElement(SVDListGadget())
          FreeGadget(Gadget)
          Break
        EndIf
      Next
    EndProcedure
    
    Procedure DisableSVD()
      Protected *SVDListGadget.SVDGadget, I.i
      For I = 0 To 8
        If I = 0
          UnbindGadgetEvent(GadgetHandle(I), @SVD_WinCallback())
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
      ClearList(SVDListGadget())
    EndProcedure
    
    Procedure AddSVDGadget(ParentGadget.i, Gadget.i)
      Protected *SVDListGadget.SVDGadget, I.i
      With SVDListGadget()
        *SVDListGadget = AddElement(SVDListGadget())
        \ParentGadget = ParentGadget
        \Gadget = Gadget
        \TypeGadget = GadgetType(Gadget)
        SortStructuredArray(GadgetDragHandleArray(), #PB_Sort_Descending, OffsetOf(GadgetDragHandle\DragHandle), TypeOf(GadgetDragHandle\DragHandle))
        SortStructuredArray(GadgetDragHandleArray(), #PB_Sort_Ascending, OffsetOf(GadgetDragHandle\Gadget), TypeOf(GadgetDragHandle\Gadget))
        For I = 0 To ArraySize(GadgetDragHandleArray())
          If GadgetDragHandleArray(I)\Gadget = 0 And GadgetDragHandleArray(I)\DragHandle
            \DragHandle = GadgetDragHandleArray(I)\DragHandle
            GadgetDragHandleArray(I)\Gadget = \Gadget
            HideGadget(\DragHandle,#False)
            ResizeGadget(\DragHandle, GadgetX(\Gadget)-#OutSideBorder, GadgetY(\Gadget)-#OutSideBorder, GadgetWidth(\Gadget)+(2*#OutSideBorder), GadgetHeight(\Gadget)+(2*#OutSideBorder))
            Break
          EndIf
        Next
        SetGadgetData(\DragHandle, SVDListGadget())
        DrawHandleBorder(\DragHandle, #FreeHandelColor)
        BindGadgetEvent(\DragHandle, @SVD_Callback())
        SetActiveGadget(\DragHandle)
      EndWith
    EndProcedure
    
    Procedure EnableSVD(ParentGadget.i, Grid.i=10)
      Protected *SVDListGadget.SVDGadget, GadgetObj.i, I.i
      MyGrid = Grid
      With *SVDListGadget
        ;If PB_Object_EnumerateNext(PB_Window_Objects, @Window) : Debug Str(Window)+" - "+Str(GetWindowData(Window)) : EndIf
        PB_Object_EnumerateStart(PB_Gadget_Objects)
        While PB_Object_EnumerateNext(PB_Gadget_Objects, @GadgetObj)
          If GetGadgetData(GadgetObj) <> #PB_Ignore And GadgetObj <> ParentGadget
            *SVDListGadget = AddElement(SVDListGadget())
            \ParentGadget = ParentGadget
            \Gadget = GadgetObj
            \TypeGadget = GadgetType(GadgetObj)
          EndIf
        Wend
      EndWith
      
      ;Resize and Enable Drag Handle
      SortStructuredArray(GadgetDragHandleArray(), #PB_Sort_Descending, OffsetOf(GadgetDragHandle\DragHandle), TypeOf(GadgetDragHandle\DragHandle))
      SortStructuredArray(GadgetDragHandleArray(), #PB_Sort_Ascending, OffsetOf(GadgetDragHandle\Gadget), TypeOf(GadgetDragHandle\Gadget))
      With SVDListGadget()
        ForEach SVDListGadget()
          For I = 0 To ArraySize(GadgetDragHandleArray())
            If GadgetDragHandleArray(I)\Gadget = 0 And GadgetDragHandleArray(I)\DragHandle
              \DragHandle = GadgetDragHandleArray(I)\DragHandle
              GadgetDragHandleArray(I)\Gadget = \Gadget
              HideGadget(\DragHandle,#False)
              ResizeGadget(\DragHandle, GadgetX(\Gadget)-#OutSideBorder, GadgetY(\Gadget)-#OutSideBorder, GadgetWidth(\Gadget)+(2*#OutSideBorder), GadgetHeight(\Gadget)+(2*#OutSideBorder))
              Break
            EndIf
          Next
          SetGadgetData(\DragHandle, SVDListGadget())
          DrawHandleBorder(\DragHandle, #FreeHandelColor)
          BindGadgetEvent(\DragHandle, @SVD_Callback())
        Next
      EndWith
      HideGadget(GadgetHandle(0),#False)
      SetGadgetData(GadgetHandle(0), ParentGadget)
      BindGadgetEvent(GadgetHandle(0), @SVD_WinCallback(), #PB_EventType_LeftButtonDown)
      BindGadgetEvent(GadgetHandle(0), @SVD_WinCallback(), #PB_EventType_LeftButtonUp)
      BindGadgetEvent(GadgetHandle(0), @SVD_WinCallback(), #PB_EventType_MouseMove)
    EndProcedure
    
    Procedure DrawAreaSize(Width.i, Height.i)
      ParentWidth = Width
      ParentHeight = Height
      If IsGadget(GadgetHandle(0)) : ResizeGadget(GadgetHandle(0), Width, Height, #PB_Ignore, #PB_Ignore) : EndIf
    EndProcedure 
    
    Procedure InitSVD(ParentGadget.i, CountGadget.i = 144)
      Protected Mycursors.i, I.i
      ;Width and Height of the drawing Area used as Max values when moving
      If IsGadget(ParentGadget)
        If GadgetType(ParentGadget) = #PB_GadgetType_ScrollArea
          ParentWidth = GetGadgetAttribute(ParentGadget,#PB_ScrollArea_InnerWidth)
          ParentHeight = GetGadgetAttribute(ParentGadget,#PB_ScrollArea_InnerHeight)
        Else
          ParentWidth = GadgetWidth(ParentGadget)
          ParentHeight = GadgetHeight(ParentGadget)
        EndIf
      ElseIf IsWindow(ParentGadget)   ;Window
        ParentWidth = WindowWidth(ParentGadget)
        ParentHeight = WindowHeight(ParentGadget)
      EndIf
      ;Draw Grid on Canvas disabled
      CanvasGadget(#DrawArea, 0, 0, ParentWidth, ParentHeight)
      SetGadgetData(#DrawArea, #PB_Ignore) :  DisableGadget(#DrawArea,#True)    ; HideGadget(#DrawArea,#True)
      DrawGrid(#False)
      
      ;Create Handle 1 to 8: North, North-East, East, South-East, South, South-West, West, North-West 
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
; Folding = ----
; EnableXP
; EnablePurifier