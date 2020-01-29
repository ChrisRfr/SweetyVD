; ---------------------------------------------------------------------------------------
;           Name: SweetyVDmodule
;    Description: Sweety Visual Designer Module
;         Author: ChrisR
;           Date: 2017-06-15
;        Version: 2.1.0.0
;     PB-Version: 5.60, 5.61,.., 5.71 (x86/x64)
;                 On Linux Use PB 5.60 Or 5.61, The gadgets are Not Drawn over the Canvas With the following versions 5.62, 5.70, 5.71, otherwise it works
;             OS: Windows, Linux, Mac
;         Credit: Stargâte - Transformation of gadgets at runtime
;         Credit: Falsam - Tiny Visual Designer (TVD)
;  English-Forum: http://www.purebasic.fr/english/viewtopic.php?f=27&t=68187
;   French-Forum: http://www.purebasic.fr/french/viewtopic.php?f=3&t=16527
;         Github: https://github.com/ChrisRfr/SweetyVD
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
    #SVD_Group
  EndEnumeration
  
  Enumeration 1000
    #ScrollDrawArea
    #DrawArea
    #Shortcut_Delete
  EndEnumeration
  
  Structure SVDGadget
    Gadget.i                      ;Id gadget
    Model.s                       ;Gadget Model (ButtonGadget, TextGadget ........)
    Type.i                        ;Gadget Type
    Name.s                        ;Name
    Selected.b                    ;Gadget selected (0=#False, 1=#True) (left click or from list and tree controls)
    Group.i                       ;Gadget's Group ID 
    DragHandle.i                  ;Drag Handle (Canva behind Gadget)
    Handle.i[9]                   ;Handle N, NE, E, SE, S, SW, W, NW
    X.i                           ;Pos X
    Y.i                           ;Pos Y
    Width.i                       ;Dim Width
    Height.i                      ;Dim Height
    ParentGadget.i                ;Parent Gadget: Windows or Container
    ParentElement.i               ;Tab element for Panel Container
    Level.i                       ;Level 0 for main windows and Gadgets, 1 for Gadgets in container, 2,...
    Caption.s                     ;Caption Gadget
    ToolTip.s                     ;ToolTip
    Option1.s                     ;Option1 (Text, title...)
    Option2.s                     ;Option2
    Option3.s                     ;Option2
    FontID.i                      ;Font ID
    FrontColor.s                  ;FrontColor
    BackColor.s                   ;FrontColor
    Constants.s                   ;Available Constants (Ex: "#PB_Text_Center,#PB_Text_Right,#PB_Text_Border")
    DrawGadget.b                  ;0=#False, 1=#True
    Image.i                       ;Image Number
    Hide.b                        ;Hide Gadget
    Disable.b                     ;Disable Gadget
    Lock.b                        ;Lock Gadget
    ModelType.i                   ;0=Window, 2=Gadget, 9=Gadget Deleted
  EndStructure
  
  Structure DataBuffer
    Handle.i[9]
  EndStructure
  
  Global NewMap SVDListGadget.SVDGadget()
  
  Structure PosDim
    X.i
    Y.i
    Width.i
    Height.i
  EndStructure
  Global SavPosDim.PosDim
  
  Global WinBackColor.i = 0
  Global UserScreen_X.i, UserScreen_Y.i, UserScreen_Width.i, UserScreen_Height.i
  Global DragSpace.i, ShowGrid.b, GridSize.i, SnapGrid.i, SelectedDrawGadget.i, LastGadgetFocus.i
  Global DrawDragHandleBorderOnGridArea.b, DisplayHandleCornerOnMove.b, DisplayUnselectedItemsBorder.b, GroupGadget.b, GroupID.i
  Global AddMenu.b, AddPopupMenu.b, AddToolBar.b, AddStatusBar.b, AddMenuHeight.l, AddToolBarHeight.l, AddStatusBarHeight.l
  Global MinX, MaxX, MinY, MaxY
  
  Declare DrawFullDrawingArea()
  ;
  Declare SetWinRedrawON(Gadget.i, State.b=#True)
  Declare SetGadgetZOrder(gadget, zorder=0)
  Declare.i GridMatch(Value.i, Grid.i=1, Min.i=0, Max.i=$7FFFFFFF)
  Declare.i Max(ValueA.i, ValueB.i)
  Declare.i Min(ValueA.i, ValueB.i)
  ;
  Declare Group_Selected()
  Declare UnGroup_Selected(Gadget.i)
  Declare Align_Left(Gadget.i)
  Declare Align_Right(Gadget.i)
  Declare Align_Top(Gadget.i)
  Declare Align_Bottom(Gadget.i)
  Declare Make_Same_Width(Gadget.i)
  Declare Make_Same_Height(Gadget.i)
  ;  
  Declare DrawGadgetDragHandleBorder(Gadget.i)
  Declare DrawAreaDragHandleBorder(Gadget.i)
  Declare SelectDrawAreaDragHandleBorder(AllGadget.b = #False)
  Declare DrawDragHandleBorder(DragHandle.i, BorderColor.i)
  Declare HideAllHandlesOnMoveGroup(Gadget.i, State.b=#False)
  Declare HideAllHandlesOnMove(Gadget.i, State.b=#False)
  Declare MouseOverDrawArea()
  Declare ResizePaintAllGadgetAndDragHandle()
  Declare ResizePaintHandleCorner()
  Declare ParentPosDim()
  Declare ResizeSVDGadget(Gadget.i, X.i, Y.i, Width.i, Height.i)
  Declare ResizeAllHandlesOfGadgetGroup(Gadget)
  Declare ResizeAllHandlesOfGadget(Gadget)
  Declare.i GroupGadgetEnabled()
  Declare SelectedGroup(IdGroup.i, GroupSelected.b=#False)
  Declare SelectedGadget(Gadget.i, ControlKeyPressed.b=#False)
  ;
  Declare MoveGadgetAndHandleGroup(Gadget.i, AddX.i, AddY.i, HandleCornerOnMove.b = #True)
  Declare MoveGadgetAndHandle(Gadget.i, AddX.i, AddY.i, HandleCornerOnMove.b = #True)
  Declare ResizeGadgetKeyDown(Gadget.i)
  Declare MoveGadgetKeyDown(Gadget.i)
  Declare MoveGadgetKeyUp(Gadget.i)
  Declare FocusActiveDrawAera()
  Declare FocusActiveGadget(Gadget.i)
  Declare FocusActiveDrawGadget(Gadget.i)
  ;
  Declare SVD_ResizeGadget()
  Declare SVD_GadgetCallback()
  Declare SVD_DrawAeraCallback()
  Declare SVD_WinCallback()
  ;
  Declare DrawCanvasGadget(Gadget.i)
  Declare SetDrawGadgetAttribute(Gadget.i)
  Declare SetSelectedGadget(Gadget.i)
  Declare HideSVDGadget(Gadget.i)
  Declare DeleteSVDGadget(Gadget.i)
  Declare AddSVDDrawGadget(Gadget.i)
  Declare AddSVDGadget(Gadget.i)
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
  #ScrollAreaColor = $A0A0A0
  #GridBackground = $EBE6E1
  #GridColor = $CECCCC
  #SelectedHandelColor = $640000     ;BlueDark
  #SelectedHandelColorGroup = $242484;Red
  #WinHandleColor= $000064           ;RedDark
  #FreeHandelColor = $FF8080         ;White=$FFFFFF, grey=$C6C6C6
  #MenuToolsStatusTextColor = $646464
  CompilerIf #PB_Compiler_OS = #PB_OS_MacOS   ;the outside border must be wide on MacOS in order to use it
    #HandelSize = 8
    #OutSideBorder = 3
    #DftBackColor = $C0C0C0
  CompilerElse
    #HandelSize = 7
    #OutSideBorder = 1
    #DftBackColor = $F0F0F0
  CompilerEndIf
  
  Structure SVDParentGadget
    ParentGadget.i
    ParentElement.i
    X.i
    Y.i
    Width.i
    Height.i
  EndStructure
  Global NewMap SVDListParentGadget.SVDParentGadget()
  
  Structure GadgetDragHandle
    DragHandle.i
    Gadget.i
  EndStructure
  Global Dim GadgetDragHandleArray.GadgetDragHandle(0)
  Global Dim GadgetHandle(8)
  
  ; DrawingArea, Grid, Container, DrawFrame, DrawPanel, DrawScrollArea, DrawMenuToolStatusBar()
  IncludePath "Include"
  XIncludeFile "DrawingArea.pb"
  
  Procedure SetWinRedrawON(Gadget.i, State.b=#True)
    CompilerIf #PB_Compiler_OS = #PB_OS_Windows
      If DisplayHandleCornerOnMove = #False
        SendMessage_(GadgetID(Gadget),#WM_SETREDRAW,State,0)
        If State = #True
          ;InvalidateRect_(GadgetID(Gadget), #Null, State)
          RedrawWindow_(GadgetID(Gadget), #Null, #Null, #RDW_INVALIDATE | #RDW_UPDATENOW)     ;#RDW_ERASE | #RDW_FRAME | #RDW_INVALIDATE | #RDW_ALLCHILDREN
        EndIf
      EndIf
    CompilerEndIf
  EndProcedure
  
  Procedure SetGadgetZOrder(gadget.i, zorder=0)
    ;Correct the z-order and draw order for [potentially] overlapping gadgets
    CompilerIf #PB_Compiler_OS = #PB_OS_Windows
      If IsGadget(gadget)
        If zorder = 0   ;Call with zorder=0 just after creating each gadget
          SetWindowLongPtr_(GadgetID(gadget), #GWL_STYLE, GetWindowLongPtr_(GadgetID(gadget), #GWL_STYLE) | #WS_CLIPSIBLINGS)
        ElseIf zorder = 1   ;Call with zorder=1 to later bring a gadget to the top of the z-order
          SetWindowPos_(GadgetID (gadget), #HWND_BOTTOM, 0,0,0,0, #SWP_NOSIZE | #SWP_NOMOVE)
        ElseIf zorder = 9   ;Call with zorder=9 to remove #WS_CLIPSIBLINGS flags
          SetWindowLongPtr_(GadgetID(gadget), #GWL_STYLE, GetWindowLongPtr_(GadgetID(gadget), #GWL_STYLE) & (#WS_CLIPSIBLINGS ! - 1))
        Else   ;Call with zorder=-1 to later bring a gadget to the bottom of the z-order
          SetWindowPos_(GadgetID(gadget), #HWND_TOP, 0, 0, 0, 0, #SWP_NOSIZE | #SWP_NOMOVE)
        EndIf
      EndIf
    CompilerEndIf
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
  
  Procedure.i Max(ValueA.i, ValueB.i)
    If ValueA > ValueB
      ProcedureReturn ValueA
    Else
      ProcedureReturn ValueB
    EndIf
  EndProcedure
  
  Procedure.i Min(ValueA.i, ValueB.i)
    If ValueA < ValueB
      ProcedureReturn ValueA
    Else
      ProcedureReturn ValueB
    EndIf
  EndProcedure
  
  
  ;-
  Procedure Group_Selected()
    If GroupGadget = #True
      GroupID + 1
      With SVDListGadget()
        PushMapPosition(SVDListGadget())
        ForEach SVDListGadget()
          If \Selected = #True
            \Group = GroupID
          EndIf
        Next
        PopMapPosition(SVDListGadget())
        ;FocusActiveGadget(Gadget)
      EndWith
    EndIf
  EndProcedure
  
  Procedure UnGroup_Selected(Gadget.i)
    Protected SavGroup.i
    If GroupGadget = #True
      With SVDListGadget()
        If FindMapElement(SVDListGadget(), Str(Gadget))
          If \Group > 0
            SavGroup = \Group
            PushMapPosition(SVDListGadget())
            ForEach SVDListGadget()
              If \Group = SavGroup
                \Group = 0
                \Selected = #False
              EndIf
            Next
            PopMapPosition(SVDListGadget())
            FocusActiveGadget(Gadget)
          EndIf
        EndIf
      EndWith
    EndIf
  EndProcedure
  
  Procedure Align_Left(Gadget.i)
    Protected LeftPos.i
    If GroupGadget = #True
      With SVDListGadget()
        If FindMapElement(SVDListGadget(), Str(Gadget))
          LeftPos = \X
          PushMapPosition(SVDListGadget())
          ForEach SVDListGadget()
            If \Selected = #True And \Lock = #False And \Gadget <> Gadget
              \X = LeftPos
              If \X + \Width > MaxX
                \Width = MaxX - \X
              EndIf
              ;\X = GridMatch(LeftPos, DragSpace, MinX, MaxX-\Width)
              If IsGadget(\Gadget)
                ResizeGadget(\Gadget, \X, #PB_Ignore, \Width, #PB_Ignore)
                ;ResizeGadget(\Gadget, \X, #PB_Ignore, #PB_Ignore, #PB_Ignore)
              EndIf
              If DrawDragHandleBorderOnGridArea = #True Or \DrawGadget= #True
                DrawFullDrawingArea()
                SelectDrawAreaDragHandleBorder(#False)
              EndIf
              ResizeAllHandlesOfGadget(\Gadget)
            EndIf
          Next
          PopMapPosition(SVDListGadget())
          FocusActiveGadget(Gadget)
        EndIf
      EndWith
    EndIf
  EndProcedure
  
  Procedure Align_Right(Gadget.i)
    Protected RightPos.i
    If GroupGadget = #True
      With SVDListGadget()
        If FindMapElement(SVDListGadget(), Str(Gadget))
          RightPos = \X + \Width
          PushMapPosition(SVDListGadget())
          ForEach SVDListGadget()
            If \Selected = #True And \Lock = #False And \Gadget <> Gadget
              \X = RightPos - \Width
              If \X < MinX
                \X = MinX
                \Width = RightPos - \X
              EndIf
              ;\X = GridMatch(RightPos - \Width, DragSpace, MinX, MaxX)
              If IsGadget(\Gadget)
                ResizeGadget(\Gadget, \X, #PB_Ignore, \Width, #PB_Ignore)
                ;ResizeGadget(\Gadget, \X, #PB_Ignore, #PB_Ignore, #PB_Ignore)
              EndIf
              If DrawDragHandleBorderOnGridArea = #True Or \DrawGadget= #True
                DrawFullDrawingArea()
                SelectDrawAreaDragHandleBorder(#False)
              EndIf
              ResizeAllHandlesOfGadget(\Gadget)
            EndIf
          Next
          PopMapPosition(SVDListGadget())
          FocusActiveGadget(Gadget)
        EndIf
      EndWith
    EndIf
  EndProcedure
  
  Procedure Align_Top(Gadget.i)
    Protected TopPos.i
    If GroupGadget = #True
      With SVDListGadget()
        If FindMapElement(SVDListGadget(), Str(Gadget))
          TopPos = \Y
          PushMapPosition(SVDListGadget())
          ForEach SVDListGadget()
            If \Selected = #True And \Lock = #False And \Gadget <> Gadget
              \Y = TopPos
              If \Y + \Height > MaxY
                \Height = MaxY - \Y
              EndIf
              ;\Y = GridMatch(TopPos, DragSpace, MinY, MaxY-\Height)
              If IsGadget(\Gadget)
                ResizeGadget(\Gadget, #PB_Ignore, \Y, #PB_Ignore, \Height)
                ;ResizeGadget(\Gadget, #PB_Ignore, \Y, #PB_Ignore, #PB_Ignore)
              EndIf
              If DrawDragHandleBorderOnGridArea = #True Or \DrawGadget= #True
                DrawFullDrawingArea()
                SelectDrawAreaDragHandleBorder(#False)
              EndIf
              ResizeAllHandlesOfGadget(\Gadget)
            EndIf
          Next
          PopMapPosition(SVDListGadget())
          FocusActiveGadget(Gadget)
        EndIf
      EndWith
    EndIf
  EndProcedure
  
  Procedure Align_Bottom(Gadget.i)
    Protected BottomPos.i
    If GroupGadget = #True
      With SVDListGadget()
        If FindMapElement(SVDListGadget(), Str(Gadget))
          BottomPos = \Y + \Height
          PushMapPosition(SVDListGadget())
          ForEach SVDListGadget()
            If \Selected = #True And \Lock = #False And \Gadget <> Gadget
              \Y = BottomPos - \Height
              If \Y < MinY
                \Y = MinY
                \Height = BottomPos - \Y
              EndIf
              ;\Y = GridMatch(BottomPos - \Height, DragSpace, MinY, MaxY)
              If IsGadget(\Gadget)
                ResizeGadget(\Gadget, #PB_Ignore, \Y, #PB_Ignore, \Height)
                ;ResizeGadget(\Gadget, #PB_Ignore, \Y, #PB_Ignore, #PB_Ignore)
              EndIf
              If DrawDragHandleBorderOnGridArea = #True Or \DrawGadget= #True
                DrawFullDrawingArea()
                SelectDrawAreaDragHandleBorder(#False)
              EndIf
              ResizeAllHandlesOfGadget(\Gadget)
            EndIf
          Next
          PopMapPosition(SVDListGadget())
          FocusActiveGadget(Gadget)
        EndIf
      EndWith
    EndIf
  EndProcedure
  
  Procedure Make_Same_Width(Gadget.i)
    Protected Width.i
    If GroupGadget = #True
      With SVDListGadget()
        If FindMapElement(SVDListGadget(), Str(Gadget))
          Width = \Width
          PushMapPosition(SVDListGadget())
          ForEach SVDListGadget()
            If \Selected = #True And \Lock = #False And \Gadget <> Gadget
              \Width = Width
              If \X + \Width > MaxX
                \X = MaxX - \Width
              EndIf
              ;\Width = GridMatch(Width, DragSpace, #MinSize, MaxX - \X)
              If IsGadget(\Gadget)
                ResizeGadget(\Gadget, \X, #PB_Ignore, \Width, #PB_Ignore)
                ;ResizeGadget(\Gadget, #PB_Ignore, #PB_Ignore, \Width, #PB_Ignore)
              EndIf
              If DrawDragHandleBorderOnGridArea = #True Or \DrawGadget= #True
                DrawFullDrawingArea()
                SelectDrawAreaDragHandleBorder(#False)
              EndIf
              ResizeAllHandlesOfGadget(\Gadget)
            EndIf
          Next
          PopMapPosition(SVDListGadget())
          FocusActiveGadget(Gadget)
        EndIf
      EndWith  
    EndIf
  EndProcedure
  
  Procedure Make_Same_Height(Gadget.i)
    Protected Height.i
    If GroupGadget = #True
      With SVDListGadget()
        If FindMapElement(SVDListGadget(), Str(Gadget))
          Height = \Height
          PushMapPosition(SVDListGadget())
          ForEach SVDListGadget()
            If \Selected = #True And \Lock = #False And \Gadget <> Gadget
              \Height = Height
              If \Y + \Height > MaxY
                \Y = MaxY - \Height
              EndIf
              ;\Height = GridMatch(Height, DragSpace, #MinSize, MaxY - \Y)
              If IsGadget(\Gadget) 
                ResizeGadget(\Gadget, #PB_Ignore, \Y, #PB_Ignore, \Height)
                ;ResizeGadget(\Gadget, #PB_Ignore, #PB_Ignore, #PB_Ignore, \Height)
              EndIf
              If DrawDragHandleBorderOnGridArea = #True Or \DrawGadget= #True
                DrawFullDrawingArea()
                SelectDrawAreaDragHandleBorder(#False)
              EndIf
              ResizeAllHandlesOfGadget(\Gadget)
            EndIf
          Next
          PopMapPosition(SVDListGadget())
          FocusActiveGadget(Gadget)
        EndIf
      EndWith  
    EndIf
  EndProcedure
  
  ;-
  Procedure DrawGadgetDragHandleBorder(Gadget.i)
    Protected BorderColor.i
    With SVDListGadget()
      If FindMapElement(SVDListGadget(), Str(Gadget))
        If \ModelType <> 0 And \Hide = #False And \DrawGadget = #False
          If \Selected = #True
            If GroupGadget = #True
              BorderColor = #SelectedHandelColorGroup
            Else
              BorderColor = #SelectedHandelColor
            EndIf
          Else
            If DisplayUnselectedItemsBorder = #False
              BorderColor = #GridBackground
            ElseIf \Disable = #True
              BorderColor = #DftBackColor
            Else
              BorderColor = #FreeHandelColor
            EndIf
          EndIf
          If StartDrawing(CanvasOutput(\DragHandle))
            ;DrawingMode(#PB_2DDrawing_Outlined)
            Box(0, 0, OutputWidth(), OutputHeight(), BorderColor)
            Select \Model
              Case "CalendarGadget", "ListViewGadget"   ;Specific for Calendar and ListView Gadget, use a White background to avoid a color changed when moving another gadget on it
                Box(1, 1, OutputWidth()-2, OutputHeight()-2, $FFFFFF)
              Default
                Box(1, 1, OutputWidth()-2, OutputHeight()-2, $F0F0F0)
                ;Box(1, 1, OutputWidth()-2, OutputHeight()-2, #GridBackground)
            EndSelect
            StopDrawing()
          EndIf
        EndIf
      EndIf
    EndWith
  EndProcedure
  
  Procedure DrawAreaDragHandleBorder(Gadget.i)
    Protected BorderColor.i
    With SVDListGadget()
      If FindMapElement(SVDListGadget(), Str(Gadget))
        If \ModelType <> 0 And \Hide = #False
          If DrawDragHandleBorderOnGridArea = #True Or \DrawGadget = #True
            If \Selected = #True
              If GroupGadget = #True
                BorderColor = #SelectedHandelColorGroup
              Else
                BorderColor = #SelectedHandelColor
              EndIf
            Else
              If DisplayUnselectedItemsBorder = #False
                BorderColor = #GridBackground
              ElseIf \Disable = #True
                BorderColor = #DftBackColor
              Else
                BorderColor = #FreeHandelColor
              EndIf
            EndIf
            If StartDrawing(CanvasOutput(#DrawArea))
              DrawingMode(#PB_2DDrawing_Outlined)
              Box(\X-#OutSideBorder, \Y-#OutSideBorder, \Width+(2*#OutSideBorder), \Height+(2*#OutSideBorder), BorderColor)
              ;Box(\X, \Y, \Width, \Height, $F0F0F0)
              ;Box(\X, \Y, \Width, \Height, #GridBackground)
              StopDrawing()
            EndIf
          EndIf
        EndIf
      EndIf
    EndWith
  EndProcedure
  
  Procedure SelectDrawAreaDragHandleBorder(AllGadget.b = #False)   ;#True: all gadgets borders are drawn - #False only Unselected gadgets are drawn
                                                                   ;It is to display the borders during the moves (Unselected gadgets borders) and at the end of the move (All gadgets borders). Avoids redrawing all the time (Flicker)
    With SVDListGadget()
      PushMapPosition(SVDListGadget())
      ForEach SVDListGadget()
        If DrawDragHandleBorderOnGridArea = #True Or \DrawGadget = #True
          If AllGadget = #True
            DrawAreaDragHandleBorder(\Gadget)
          Else
            If DisplayUnselectedItemsBorder = #True And \Selected = #False
              DrawAreaDragHandleBorder(\Gadget)
            EndIf
          EndIf
          If IsGadget(\Gadget) : ResizeGadget(\Gadget, #PB_Ignore, #PB_Ignore, #PB_Ignore, #PB_Ignore) : EndIf
        EndIf
      Next
      PopMapPosition(SVDListGadget())
    EndWith
  EndProcedure
  
  Procedure DrawDragHandleBorder(DragHandle.i, BorderColor.i)
    If StartDrawing(CanvasOutput(DragHandle))
      ;DrawingMode(#PB_2DDrawing_Outlined)
      Box(0, 0, OutputWidth(), OutputHeight(), BorderColor)
      Box(1, 1, OutputWidth()-2, OutputHeight()-2, $F0F0F0)   ;Without DrawingMode(#PB_2DDrawing_Outlined)
                                                              ;Box(1, 1, OutputWidth()-2, OutputHeight()-2, $FFCC33)   ;Without DrawingMode(#PB_2DDrawing_Outlined)
                                                              ;Box(1, 1, OutputWidth()-2, OutputHeight()-2, #GridBackground)   ;Without DrawingMode(#PB_2DDrawing_Outlined)
      StopDrawing()
    EndIf
  EndProcedure
  
  ;-
  Procedure HideAllHandlesOnMoveGroup(Gadget.i, bState.b=#False)
    Protected I.i
    With SVDListGadget()
      ;Mini and Maxi 
      PushMapPosition(SVDListGadget())
      ForEach SVDListGadget()
        If \Selected = #True And \Type > 0
          CompilerIf #PB_Compiler_OS = #PB_OS_Windows
            If IsGadget(\DragHandle)
              HideGadget(\DragHandle,bState)
              If bState = #False
                If \Gadget = Gadget : SetActiveGadget(\DragHandle) : EndIf
              EndIf
            EndIf
          CompilerEndIf
          If DisplayHandleCornerOnMove = #False   ;= Handle Corner
            If \Gadget = Gadget
              For I = 1 To 8
                If IsGadget(\Handle[I]) : HideGadget(\Handle[I],bState) : EndIf
              Next
            EndIf
          EndIf
        EndIf
      Next
      PopMapPosition(SVDListGadget())
    EndWith
  EndProcedure
  
  Procedure HideAllHandlesOnMove(Gadget.i, bState.b=#False)
    Protected I.i
    With SVDListGadget()
      ; For Testing: Visible, Hide others Drag Handle to reduce overlap and flicker (No)
      ;         PushMapPosition(SVDListGadget())
      ;         ForEach SVDListGadget()
      ;           ;For testing Hide Or resize To 0 DragHandle
      ;           If \Selected = #False And IsGadget(\DragHandle)
      ;             HideGadget(\DragHandle,bState)
      ;             ;If bState = #True : ResizeGadget(\DragHandle, 0, 0, 0, 0): Else : ResizeAllHandlesOfGadget(\Gadget)
      ;             ;EndIf
      ;           EndIf
      ;           If IsGadget(\Gadget) : ResizeGadget(\Gadget, #PB_Ignore, #PB_Ignore, #PB_Ignore, #PB_Ignore) : EndIf
      ;         Next
      ;         PopMapPosition(SVDListGadget())
      ; Visible, Hide Drag Handle and Handle Corner of the selected Gadget
      If FindMapElement(SVDListGadget(), Str(Gadget))
        If \Type > 0
          ;Always Hide Drag Handle on Move to avoid overlapping and flickering. but at the same time, the gadget borderis not drawn.
          ;It could possibly be drawn on the drawing area, but in this case the drawing area would have to be redrawn each time the gadget is moved.
          CompilerIf #PB_Compiler_OS = #PB_OS_Windows   ;One of the important sources of flickering on Windows
            If IsGadget(\DragHandle)
              HideGadget(\DragHandle,bState)
              If bState = #False : SetActiveGadget(\DragHandle) : EndIf
            EndIf
          CompilerEndIf
          If DisplayHandleCornerOnMove = #False   ;= Handle Corner
            For I = 1 To 8
              If IsGadget(\Handle[I]) : HideGadget(\Handle[I],bState) : EndIf
            Next
          EndIf
        EndIf
      EndIf
    EndWith
  EndProcedure
  
  Procedure  MouseOverDrawArea()
    Protected X = UserScreen_Width + GadgetX(#ScrollDrawArea) - GetGadgetAttribute(#ScrollDrawArea, #PB_ScrollArea_X), Y = UserScreen_Height + GadgetY(#ScrollDrawArea) - GetGadgetAttribute(#ScrollDrawArea, #PB_ScrollArea_Y)
    Protected Mx = WindowMouseX(0), My = WindowMouseY(0)
    If Mx > GadgetX(#ScrollDrawArea) And Mx < X And My > GadgetY(#ScrollDrawArea) And My < Y
      ProcedureReturn 1   ;Mouse is on Gadget
    EndIf
    ProcedureReturn 0   ;Mouse is not on Gadget
  EndProcedure
  
  Procedure ResizePaintAllGadgetAndDragHandle()
    With SVDListGadget()
      PushMapPosition(SVDListGadget())
      ForEach SVDListGadget()
        If \ModelType <> 0 And \DrawGadget = #False
          ResizeGadget(\Gadget, #PB_Ignore, #PB_Ignore, #PB_Ignore, #PB_Ignore)
          ResizeGadget(\DragHandle, #PB_Ignore, #PB_Ignore, #PB_Ignore, #PB_Ignore)
        EndIf
      Next
      PopMapPosition(SVDListGadget())
    EndWith
  EndProcedure
  
  Procedure ResizePaintHandleCorner()
    Protected I.i
    For I = 0 To 8
      ResizeGadget(GadgetHandle(I), #PB_Ignore, #PB_Ignore, #PB_Ignore, #PB_Ignore)
    Next
  EndProcedure
  
  Procedure ParentPosDim()
    ;         \ParentGadget = 1000000001
    ;         If \ParentGadget = #ScrollDrawArea
    MinX = 0
    MaxX = UserScreen_Width
    MinY = 0
    MaxY = UserScreen_Height
    If AddMenu = #True : MinY + AddMenuHeight : EndIf
    If AddToolBar = #True : MinY + AddToolBarHeight : EndIf
    If AddStatusBar = #True : MaxY-AddStatusBarHeight+1 : EndIf
    ;         Else
    ;           If FindMapElement(SVDListParentGadget(), Str(\ParentGadget))
    ;             PushMapPosition(SVDListGadget())
    ;             ForEach SVDListParentGadget()
    ;               If SVDListParentGadget()\ParentGadget = \ParentGadget
    ;                 MinX = SVDListParentGadget()\X
    ;                 MaxX = MinX + SVDListParentGadget()\Width
    ;                 MinY = SVDListParentGadget()\Y
    ;                 MaxY = MinY + SVDListParentGadget()\Height
    ;               EndIf
    ;             Next
    ;             PopMapPosition(SVDListGadget())
    ;           EndIf
    ;         EndIf
  EndProcedure
  
  Procedure ResizeImageGadget(Gadget.i)
    Protected TmpImage.i
    With SVDListGadget()
      If FindMapElement(SVDListGadget(), Str(Gadget))
        If \Image And IsImage(\Image)
          ;Not necessary for ButtonImage Gadget
          ;If GadgetType(\Gadget) = #PB_GadgetType_ButtonImage
          ;SetGadgetAttribute(\Gadget, #PB_Button_Image, ImageID(\Image))
          ;EndIf
          If GadgetType(\Gadget) = #PB_GadgetType_Image
            ;On the real Image Gadget, the image is normally not resized, it is done here for ease of use and to get the handles
            If \Width < ImageWidth(\Image) Or \Height < ImageHeight(\Image)
              TmpImage = CreateImage(#PB_Any, Min(ImageWidth(\Image), \Width), Min(ImageHeight(\Image), \Height))
              If TmpImage
                If StartDrawing(ImageOutput(TmpImage))
                  DrawingMode(#PB_2DDrawing_AllChannels)
                  DrawImage(ImageID(\Image), 0, 0, OutputWidth(), OutputHeight())
                  StopDrawing()
                EndIf
                SetGadgetState(\Gadget, ImageID(TmpImage))
                ResizeGadget(\Gadget, #PB_Ignore, #PB_Ignore, \Width, \Height)
                ;FreeImage(TmpImage)
              EndIf
            Else
              SetGadgetState(\Gadget, ImageID(\Image))   ;The Gadget is resized to the image size. Fixed with ResizeGadget
              ResizeGadget(\Gadget, #PB_Ignore, #PB_Ignore, \Width, \Height)
            EndIf
          EndIf
        EndIf
      EndIf
    EndWith
  EndProcedure
  
  Procedure ResizeSVDGadget(Gadget.i, X.i, Y.i, Width.i, Height.i)
    ParentPosDim()
    With SVDListGadget()
      If FindMapElement(SVDListGadget(), Str(Gadget))
        ;Only one of the values X, Y, Width or Height. Sent from an interface, with control there. other values must be negative (#PB_Ignore=-65535)
        If X >= 0 And Y < 0 And Width < 0 And Height < 0
          \X = GridMatch(X, 1, MinX, MaxX-\Width)
        ElseIf Y >= 0 And X < 0 And Width < 0 And Height < 0
          \Y = GridMatch(Y, 1, MinY, MaxY-\Height)
        ElseIf Width >= 0 And X < 0 And Y < 0 And Height < 0
          \Width = GridMatch(Width, 1, MinX, MaxX-\X)
        ElseIf Height >= 0 And X < 0 And Y < 0 And Width < 0
          \Height = GridMatch(Height, 1, MinY, MaxY-\Y)
        Else
          ProcedureReturn #False
        EndIf
        If \DrawGadget = #False
          ResizeGadget(Gadget, \X, \Y, \Width, \Height)
        EndIf
        ;If GroupGadget = # True
        ;  ResizeAllHandlesOfGadgetGroup(Gadget)
        ;Else
        ResizeAllHandlesOfGadget(Gadget)
        ;EndIf
        If DrawDragHandleBorderOnGridArea = #True Or \DrawGadget = #True
          DrawFullDrawingArea()
          SelectDrawAreaDragHandleBorder(#True)
        EndIf
        ;ResizeGadget(Gadget, #PB_Ignore, #PB_Ignore, #PB_Ignore, #PB_Ignore)
      EndIf
    EndWith
  EndProcedure
  
  Procedure ResizeAllHandlesOfGadgetGroup(Gadget)
    Protected GadgetWidth0, GadgetHeight0
    With SVDListGadget()
      PushMapPosition(SVDListGadget())
      ForEach SVDListGadget()
        If \Gadget = Gadget
          ResizeAllHandlesOfGadget(Gadget)
        Else
          If \DragHandle   ;Moved Handle
            GadgetWidth0 = \Width : GadgetHeight0 = \Height
            If DrawDragHandleBorderOnGridArea = #True
              ResizeGadget(\DragHandle, \X, \Y, \Width, \Height)
            Else
              ResizeGadget(\DragHandle, \X-#OutSideBorder, \Y-#OutSideBorder, \Width+(2*#OutSideBorder), \Height+(2*#OutSideBorder))
            EndIf
            If \Width = GadgetWidth0 And \Height = GadgetHeight0  ;Move only, Post a #PB_EventType_Resize Event to Redraw the Handle Border
              PostEvent(#PB_Event_Gadget, 0, \DragHandle, #PB_EventType_Resize)
            EndIf
          Else
            ;DrawAreaDragHandleBorder(\Gadget)
          EndIf
        EndIf
      Next
      PopMapPosition(SVDListGadget())
    EndWith
  EndProcedure
  
  Procedure ResizeAllHandlesOfGadget(Gadget)
    Protected GadgetX0, GadgetWidth0, GadgetX1
    Protected GadgetY0, GadgetHeight0, GadgetY1
    
    With SVDListGadget()
      If FindMapElement(SVDListGadget(), Str(Gadget))
        GadgetX0 = \X : GadgetWidth0 = \Width : GadgetX1 = GadgetX0 + GadgetWidth0
        GadgetY0 = \Y : GadgetHeight0 = \Height : GadgetY1 = GadgetY0 + GadgetHeight0
        If \DragHandle   ;Moved Handle
          If DrawDragHandleBorderOnGridArea = #True
            ResizeGadget(\DragHandle, GadgetX0, GadgetY0, GadgetWidth0, GadgetHeight0)
          Else
            ResizeGadget(\DragHandle, GadgetX0-#OutSideBorder, GadgetY0-#OutSideBorder, GadgetWidth0+(2*#OutSideBorder), GadgetHeight0+(2*#OutSideBorder))
          EndIf
          If \Width = SavPosDim\Width And \Height = SavPosDim\Height  ;Move only, Post a #PB_EventType_Resize Event to Redraw the Handle Border
            PostEvent(#PB_Event_Gadget, 0, \DragHandle, #PB_EventType_Resize)
          EndIf
        Else
          ;DrawAreaDragHandleBorder(\Gadget)
        EndIf
        ;Optional, cosmetic: Handle Corner Inside Gadget, if desired
        ;GadgetX0 +1 : GadgetWidth0 -2 : GadgetX1 = GadgetX0 + GadgetWidth0
        ;GadgetY0 +1 : GadgetHeight0 -2 : GadgetY1 = GadgetY0 + GadgetHeight0
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
      EndIf
    EndWith
  EndProcedure
  
  Procedure.i GroupGadgetEnabled()
    Protected CountSelectedGadget.i, iReturn.i
    With SVDListGadget()
      PushMapPosition(SVDListGadget())
      ForEach SVDListGadget()
        If \Selected = #True
          CountSelectedGadget +1
        EndIf
      Next
      PopMapPosition(SVDListGadget())
    EndWith
    If CountSelectedGadget > 1
      iReturn = #True
    EndIf
    ProcedureReturn iReturn     
  EndProcedure
  
  Procedure SelectedGroup(IdGroup.i, GroupSelected.b=#False)
    With SVDListGadget()
      PushMapPosition(SVDListGadget())
      ForEach SVDListGadget()
        If \Type <> 0   ;OpenWindow
          If \Group = IdGroup
            \Selected = GroupSelected
          EndIf
        EndIf
      Next
      PopMapPosition(SVDListGadget())
    EndWith
  EndProcedure
  
  Procedure SelectedGadget(Gadget.i, ControlKeyPressed.b=#False)
    Protected SavGroupGadget.b = GroupGadget, CountSelectedGadget.i, I.i
    With SVDListGadget()
      If ControlKeyPressed = #False
        If FindMapElement(SVDListGadget(), Str(Gadget))
          If GroupGadget = #True And \Selected = #True
            GroupGadget = #True
          Else
            GroupGadget = #False
          EndIf
        EndIf
      Else
        ;the real status is done below (If >1 Gadget selected) via the procedure GroupGadgetEnabled()
        GroupGadget = #True
      EndIf
      
      If GroupGadget = #False
        PushMapPosition(SVDListGadget())
        ForEach SVDListGadget()
          If \Type <> 0   ;OpenWindow
            If \Gadget = Gadget
              \Selected = #True
            Else
              \Selected = #False
              ;;If every gadget has its own corner
              ;For I = 1 To 8 : If \Handle[I] : HideGadget(\Handle[I],#True) : EndIf : Next
            EndIf
            If \Group > 0
              SelectedGroup(\Group, \Selected)
              GroupGadget = #True
            EndIf
            If DrawDragHandleBorderOnGridArea = #True Or \DrawGadget = #True
              DrawAreaDragHandleBorder(\Gadget)
            Else
              DrawGadgetDragHandleBorder(\Gadget)
            EndIf
            If IsGadget(\Gadget) : ResizeGadget(\Gadget, #PB_Ignore, #PB_Ignore, #PB_Ignore, #PB_Ignore) : EndIf
          EndIf
        Next
        PopMapPosition(SVDListGadget())
      EndIf
      
      If GroupGadget = #True   ;Not Else GroupGadget can be updated to #True if Group Selected
        PushMapPosition(SVDListGadget())
        ForEach SVDListGadget()
          If \Type <> 0   ;OpenWindow
            If \Gadget = Gadget
              \Selected = #True
            EndIf
            If \Group > 0
              SelectedGroup(\Group, \Selected)
            EndIf
            If DrawDragHandleBorderOnGridArea = #True Or \DrawGadget = #True
              DrawAreaDragHandleBorder(\Gadget)
            Else
              DrawGadgetDragHandleBorder(\Gadget)
            EndIf
            If IsGadget(\Gadget) : ResizeGadget(\Gadget, #PB_Ignore, #PB_Ignore, #PB_Ignore, #PB_Ignore) : EndIf
          EndIf
        Next
        PopMapPosition(SVDListGadget())
        GroupGadget = GroupGadgetEnabled()
      EndIf
    EndWith
    If SavGroupGadget <> GroupGadget
      PostEvent(#PB_Event_Gadget, 0, 0, #SVD_Group)
    EndIf  
  EndProcedure
  
  ;-
  Procedure MoveGadgetAndHandleGroup(Gadget.i, AddX.i, AddY.i, HandleCornerOnMove.b = #True)
    Protected MiniX.i=9999, MaxiX.i, MiniY.i=9999, MaxiY.i, X1.i, Y1.i, kbdevent.i, I.i
    With SVDListGadget()
      ;Mini and Maxi of the Group
      ForEach SVDListGadget()
        If \Selected = #True
          If \X < MiniX : MiniX = \X : EndIf
          If \Y < MiniY : MiniY = \Y : EndIf
          If \X + \Width > MaxiX : MaxiX = \X + \Width : EndIf
          If \Y + \Height > MaxiY : MaxiY = \Y + \Height : EndIf
        EndIf
      Next
      
      ;Calculate AddX, AddY following Snap to Grid and mini maxi related to Group  
      If FindMapElement(SVDListGadget(), Str(Gadget))
        If \Lock = #False
          If AddX <> 0
            X1 = GridMatch(\X+AddX, DragSpace, \X - (MiniX-MinX), \X + (MaxX-MaxiX))
            AddX = X1 - SavPosDim\X
          EndIf
          If AddY <> 0
            Y1 = GridMatch(\Y+AddY, DragSpace, \Y - (MiniY-MinY), \Y + (MaxY-MaxiY))
            AddY = Y1 - SavPosDim\Y
          EndIf
        EndIf   
      EndIf       
      
      If AddX <> 0 Or AddY <> 0
        PushMapPosition(SVDListGadget())
        ForEach SVDListGadget()
          If \Selected = #True And \Lock = #False
            \X = \X + AddX : \Y = \Y + AddY
            If \DrawGadget = #False
              ResizeGadget(\Gadget, \X, \Y, #PB_Ignore, #PB_Ignore)
            EndIf
            If DrawDragHandleBorderOnGridArea = #True Or \DrawGadget = #True
              DrawFullDrawingArea()
              SelectDrawAreaDragHandleBorder(#False)
            EndIf
            
            If HandleCornerOnMove = #True
              If \DragHandle : ResizeGadget(\DragHandle, GadgetX(\DragHandle) + AddX, GadgetY(\DragHandle) + AddY, #PB_Ignore, #PB_Ignore) : EndIf
              If \Gadget = Gadget
                For I = 1 To 8
                  If IsGadget(\Handle[I]) : ResizeGadget(\Handle[I], GadgetX(\Handle[I]) + AddX, GadgetY(\Handle[I]) + AddY, #PB_Ignore, #PB_Ignore) : EndIf
                Next
              EndIf
            EndIf
            If \Gadget = Gadget
              SavPosDim\X = \X : SavPosDim\Y = \Y
              PostEvent(#PB_Event_Gadget, 0, \Gadget, #SVD_Gadget_Resize, @SavPosDim)
            EndIf
          EndIf
        Next
        PopMapPosition(SVDListGadget())
      EndIf
    EndWith
  EndProcedure
  
  Procedure MoveGadgetAndHandle(Gadget.i, AddX.i, AddY.i, HandleCornerOnMove.b = #True)
    Protected X1.i, Y1.i, I.i
    With SVDListGadget()
      If FindMapElement(SVDListGadget(), Str(Gadget))
        If \Lock = #False
          X1 = GridMatch(\X+AddX, DragSpace, MinX, MaxX-\Width)
          Y1 = GridMatch(\Y+AddY, DragSpace, MinY, MaxY-\Height)
          If X1 <> SavPosDim\X Or Y1 <> SavPosDim\Y
            \X = X1 : \Y = Y1
            AddX = \X - SavPosDim\X : AddY = \Y - SavPosDim\Y
            If \DrawGadget = #False
              ResizeGadget(\Gadget, \X, \Y, #PB_Ignore, #PB_Ignore)
            EndIf
            If DrawDragHandleBorderOnGridArea = #True Or \DrawGadget = #True
              DrawFullDrawingArea()
              SelectDrawAreaDragHandleBorder(#False)
            EndIf
            If HandleCornerOnMove = #True
              If \DragHandle : ResizeGadget(\DragHandle, GadgetX(\DragHandle) + AddX, GadgetY(\DragHandle) + AddY, #PB_Ignore, #PB_Ignore) : EndIf
              For I = 1 To 8
                If IsGadget(\Handle[I]) : ResizeGadget(\Handle[I], GadgetX(\Handle[I]) + AddX, GadgetY(\Handle[I]) + AddY, #PB_Ignore, #PB_Ignore) : EndIf
              Next
            EndIf
            SavPosDim\X = \X : SavPosDim\Y = \Y
            PostEvent(#PB_Event_Gadget, 0, \Gadget, #SVD_Gadget_Resize, @SavPosDim)
          EndIf
        EndIf
      EndWith
    EndIf
  EndProcedure
  
  Procedure ResizeGadgetKeyDown(Gadget.i)
    Protected Width1.i, Height1.i, Handle.i, KbdEvent.i
    With SVDListGadget()
      If FindMapElement(SVDListGadget(), Str(Gadget))
        If \Lock = #False
          If \DrawGadget= #False
            Handle = \DragHandle
          Else
            Handle = #DrawArea
          EndIf
          KbdEvent = GetGadgetAttribute(Handle, #PB_Canvas_Key)
          If KbdEvent = #PB_Shortcut_Up Or KbdEvent = #PB_Shortcut_Right Or KbdEvent = #PB_Shortcut_Down Or KbdEvent = #PB_Shortcut_Left
            Width1 = \Width : Height1 = \Height
            Select KbdEvent
              Case #PB_Shortcut_Up
                If IsGadget(\Handle[1]) : Height1 = GridMatch(\Height-DragSpace, DragSpace, #MinSize) : EndIf
              Case #PB_Shortcut_Right
                If IsGadget(\Handle[3]) : Width1  = GridMatch(\Width+DragSpace, DragSpace, 0, MaxX-\X) : EndIf
              Case #PB_Shortcut_Down
                If IsGadget(\Handle[5]) : Height1 = GridMatch(\Height+DragSpace, DragSpace, 0, MaxY-\Y) : EndIf
              Case #PB_Shortcut_Left
                If IsGadget(\Handle[7]) : Width1  = GridMatch(\Width-DragSpace, DragSpace, #MinSize) : EndIf
            EndSelect
            
            If SavPosDim\Width <> Width1 Or SavPosDim\Height <> Height1
              \Width = Width1 : \Height = Height1
              If \DrawGadget= #False
                ResizeGadget(\Gadget, #PB_Ignore, #PB_Ignore, \Width, \Height)
                If GadgetType(\Gadget) = #PB_GadgetType_Image
                  ResizeImageGadget(\Gadget)
                EndIf
              EndIf
              If DrawDragHandleBorderOnGridArea = #True Or \DrawGadget= #True
                DrawFullDrawingArea()
                SelectDrawAreaDragHandleBorder(#False)
              EndIf
              ;If GroupGadget = # True
              ;  ResizeAllHandlesOfGadgetGroup(Gadget)
              ;Else
              ResizeAllHandlesOfGadget(Gadget)
              ;EndIf
              SavPosDim\Width = \Width : SavPosDim\Height = \Height
              PostEvent(#PB_Event_Gadget, 0, Gadget, #SVD_Gadget_Resize, @SavPosDim)
            EndIf
          EndIf
        EndIf
      EndIf
    EndWith
  EndProcedure
  
  Procedure MoveGadgetKeyDown(Gadget.i)
    Protected Handle.i, KbdEvent.i, I.i
    With SVDListGadget()
      If FindMapElement(SVDListGadget(), Str(Gadget)) 
        If \Lock = #False
          If \DrawGadget= #False
            Handle = \DragHandle
          Else
            Handle = #DrawArea
          EndIf
          KbdEvent = GetGadgetAttribute(Handle, #PB_Canvas_Key)
          If KbdEvent = #PB_Shortcut_Up Or KbdEvent = #PB_Shortcut_Right Or KbdEvent = #PB_Shortcut_Down Or KbdEvent = #PB_Shortcut_Left
            If GroupGadget = #True
              Select KbdEvent
                Case #PB_Shortcut_Up
                  MoveGadgetAndHandleGroup(\Gadget, 0, -DragSpace, #True)
                Case #PB_Shortcut_Right
                  MoveGadgetAndHandleGroup(\Gadget, DragSpace, 0, #True)
                Case #PB_Shortcut_Down
                  MoveGadgetAndHandleGroup(\Gadget, 0, DragSpace, #True)
                Case #PB_Shortcut_Left
                  MoveGadgetAndHandleGroup(\Gadget, -DragSpace, 0, #True)
              EndSelect
            Else
              Select KbdEvent
                Case #PB_Shortcut_Up
                  MoveGadgetAndHandle(\Gadget, 0, -DragSpace, #True)
                Case #PB_Shortcut_Right
                  MoveGadgetAndHandle(\Gadget, DragSpace, 0, #True)
                Case #PB_Shortcut_Down
                  MoveGadgetAndHandle(\Gadget, 0, DragSpace, #True)
                Case #PB_Shortcut_Left
                  MoveGadgetAndHandle(\Gadget, -DragSpace, 0, #True)
              EndSelect
            EndIf
          EndIf
        EndIf
      EndIf
    EndWith
  EndProcedure
  
  Procedure MoveGadgetKeyUp(Gadget.i)
    Protected Handle.i, KbdEvent.i
    With SVDListGadget()
      If FindMapElement(SVDListGadget(), Str(Gadget))
        If \DrawGadget= #False
          Handle = \DragHandle
        Else
          Handle = #DrawArea
        EndIf
        KbdEvent = GetGadgetAttribute(Handle, #PB_Canvas_Key)
        If KbdEvent = #PB_Shortcut_Up Or KbdEvent = #PB_Shortcut_Right Or KbdEvent = #PB_Shortcut_Down Or KbdEvent = #PB_Shortcut_Left
          If DrawDragHandleBorderOnGridArea = #True Or \DrawGadget= #True
            DrawFullDrawingArea()
            SelectDrawAreaDragHandleBorder(#True)
          EndIf
          ResizePaintAllGadgetAndDragHandle()   ;Redraw all Gadget to avoid overlay effects
        EndIf
      EndIf
    EndWith
  EndProcedure
  
  Procedure FocusActiveDrawAera()
    Protected I.i
    If GroupGadget = #True   ;UnGroup
      PushMapPosition(SVDListGadget())
      ForEach SVDListGadget()
        SVDListGadget()\Selected = #False
      Next
      PopMapPosition(SVDListGadget())
      GroupGadget = #False
      PostEvent(#PB_Event_Gadget, 0, 0, #SVD_Group)
    EndIf
    LastGadgetFocus = 0
    SelectedDrawGadget = #PB_Ignore
    For I = 1 To 8
      If GadgetHandle(I)
        UnbindGadgetEvent(GadgetHandle(I), @SVD_GadgetCallback())
        HideGadget(GadgetHandle(I),#True)
      EndIf
    Next
    SelectedGadget(0)
    RemoveKeyboardShortcut(0, #PB_Shortcut_Delete)
  EndProcedure
  
  Procedure FocusActiveGadget(Gadget.i)
    Protected ControlKeyPressed.b, I.i
    With SVDListGadget()
      If FindMapElement(SVDListGadget(), Str(Gadget))
        SelectedDrawGadget = #PB_Ignore
        If \Hide = #False
          ;For testing (NO) with SetGadgetZOrder(\DragHandle, -9) in LostFocus
          ;SetGadgetZOrder(\DragHandle) : SetGadgetZOrder(\DragHandle, -1)
          LastGadgetFocus = \Gadget
          For I = 1 To 8
            \Handle[I] = GadgetHandle(I)
            SetGadgetData(\Handle[I], SVDListGadget())
            HideGadget(\Handle[I],#False)
            ;For testing
            ;SetGadgetZOrder(\Handle[I], -1)   ;SetGadgetZOrder(\Handle[I]) : : SetGadgetZOrder(\Handle[I], 9)
            BindGadgetEvent(\Handle[I], @SVD_GadgetCallback())
          Next
          ;If GroupGadget = #True
          ;  ResizeAllHandlesOfGadgetGroup(\Gadget)
          ;Else
          ResizeAllHandlesOfGadget(\Gadget)
          ;EndIf
          If IsGadget(\DragHandle) And GetGadgetAttribute(\DragHandle, #PB_Canvas_Modifiers) = #PB_Canvas_Control
            ControlKeyPressed = #True
          EndIf
          SelectedGadget(\Gadget, ControlKeyPressed)
          AddKeyboardShortcut(0, #PB_Shortcut_Delete, #Shortcut_Delete)
        Else
          LastGadgetFocus = 0
          For I = 1 To 8
            If GadgetHandle(I)
              UnbindGadgetEvent(GadgetHandle(I), @SVD_GadgetCallback())
              HideGadget(GadgetHandle(I),#True)
            EndIf
          Next
          SelectedGadget(0)
          RemoveKeyboardShortcut(0, #PB_Shortcut_Delete)
        EndIf
        ParentPosDim()
        SavPosDim\X = \X : SavPosDim\Y = \Y : SavPosDim\Width = \Width : SavPosDim\Height = \Height
        PostEvent(#PB_Event_Gadget, 0, Gadget, #SVD_Gadget_Focus, @SavPosDim)
      EndIf
    EndWith
  EndProcedure
  
  Procedure FocusActiveDrawGadget(Gadget.i)
    Protected ControlKeyPressed.b, I.i
    With SVDListGadget()
      If FindMapElement(SVDListGadget(), Str(Gadget))
        SelectedDrawGadget = \Gadget
        If \Hide = #False
          LastGadgetFocus = \Gadget
          For I = 1 To 8
            \Handle[I] = GadgetHandle(I)
            SetGadgetData(\Handle[I], SVDListGadget())
            HideGadget(\Handle[I],#False)
            BindGadgetEvent(\Handle[I], @SVD_GadgetCallback())
          Next
          ;If GroupGadget = #True
          ;  ResizeAllHandlesOfGadgetGroup(Gadget)
          ;Else
          ResizeAllHandlesOfGadget(Gadget)
          ;EndIf
          If GetGadgetAttribute(#DrawArea, #PB_Canvas_Modifiers) = #PB_Canvas_Control
            ControlKeyPressed = #True
          EndIf
          SelectedGadget(\Gadget, ControlKeyPressed)
          AddKeyboardShortcut(0, #PB_Shortcut_Delete, #Shortcut_Delete)
        Else
          LastGadgetFocus = 0
          For I = 1 To 8
            If GadgetHandle(I)
              UnbindGadgetEvent(GadgetHandle(I), @SVD_GadgetCallback())
              HideGadget(GadgetHandle(I),#True)
            EndIf
          Next
          SelectedGadget(0)
          RemoveKeyboardShortcut(0, #PB_Shortcut_Delete)
        EndIf
        If \DrawGadget = #True
          ParentPosDim()
          SavPosDim\X = \X : SavPosDim\Y = \Y : SavPosDim\Width = \Width : SavPosDim\Height = \Height
          PostEvent(#PB_Event_Gadget, 0, Gadget, #SVD_Gadget_Focus, @SavPosDim)
        EndIf
      EndIf
    EndWith
  EndProcedure
  
  ;-
  Procedure SVD_ResizeGadget()
    Protected TmpImage.i
    With SVDListGadget()
      If FindMapElement(SVDListGadget(), Str(EventGadget()))
        ;SVD_ResizeGadget Callback is called for #PB_EventType_Resize for Canvas Gadget only - BindGadgetEvent(\Gadget, @SVD_ResizeGadget(), #PB_EventType_Resize)
        If GadgetType(\Gadget) = #PB_GadgetType_Canvas
          If \Image And IsImage(\Image)
            ;Seems better to stretch the image for the design by using OutputWidth(), OutputHeight()
            If StartDrawing(CanvasOutput(\Gadget))
              DrawingMode(#PB_2DDrawing_AllChannels)
              If \Width < ImageWidth(\Image) Or \Height < ImageHeight(\Image)
                Box(\X, \Y, OutputWidth(), OutputHeight(), $F0F0F0)
                TmpImage = GrabImage(\Image, #PB_Any, 0, 0, Min(ImageWidth(\Image), \Width), Min(ImageHeight(\Image), \Height))
                ;DrawImage(ImageID(TmpImage), 0, 0, Min(ImageWidth(\Image), \Width), Min(ImageHeight(\Image), \Height))
                ;DrawAlphaImage(ImageID(TmpImage), 0, 0, 225)
                DrawImage(ImageID(TmpImage), 0, 0, OutputWidth(), OutputHeight())
                FreeImage(TmpImage)
              Else
                ;DrawImage(ImageID(\Image), 0, 0, ImageWidth(\Image), ImageHeight(\Image))
                DrawImage(ImageID(\Image), 0, 0, OutputWidth(), OutputHeight())
              EndIf
              StopDrawing()
            EndIf
          Else
            If StartDrawing(CanvasOutput(\Gadget))
              Box(0, 0, OutputWidth(), OutputHeight(), $FFFFFF)
              StopDrawing()
            EndIf
          EndIf
          If Left(\Caption, 5) = "#Text" And Mid(\Caption, 7) <> ""
            If StartDrawing(CanvasOutput(\Gadget))
              DrawingMode(#PB_2DDrawing_Transparent)
              If \FontID <> 0 : DrawingFont(FontID(\FontID)) : EndIf
              DrawText(5, 5, Mid(\Caption, 7), #Blue, #White)
              StopDrawing()
            EndIf
          EndIf
        EndIf
      EndIf
    EndWith
  EndProcedure
  
  Procedure SVD_GadgetCallback()
    ;Notes: To display the gadgets after drag Handles resizing (canvas), we need to resize the gadgets
    ;We need to do it here for events : #PB_EventType_Focus, #PB_EventType_LostFocus, #PB_EventType_KeyDown (If Resize Done)
    ;                 #PB_EventType_RightButtonDown, #PB_EventType_MiddleButtonDown, #PB_EventType_LeftButtonDown
    ; -----------------------------------------------------------------------------------------------------------
    ;Canvas Event: MouseEnter=65537, MouseLeave=65538, MouseMove=65539, MouseWheel=65546, LeftButtonDown=65540
    ;  LeftButtonUp=65541, LeftClick=0, LeftDoubleClick=2, RightButtonDown=65542, RightButtonUp=65543
    ;  RightClick=13111, RightDoubleClick=3, MiddleButtonDown=65544, MiddleButtonUp=65545, Focus=14000, LostFocus=14001
    ;  KeyDown=65547, KeyUp=65548, Input=65549, Resize=6
    Static Selected.b, MousePosX.i, MousePosY.i, GadgetX0.i, GadgetWidth0, GadgetX1.i, GadgetY0.i, GadgetHeight0, GadgetY1.i
    Static ScrollX.i, ScrollY.i   ;, ForceResize.i
    Protected *SVDListGadget.SVDGadget = GetGadgetData(EventGadget()), *SVDListParentGadget.SVDParentGadget
    Protected X.i, Y.i, X1.i, Y1.i, Width1.i, Height1.i, I.i
    
    With *SVDListGadget
      Select EventType()
          
          ;-> DragHandle_EventType_Resize
        Case  #PB_EventType_Resize
          If DrawDragHandleBorderOnGridArea = #True
            ;DrawAreaDragHandleBorder(\Gadget)   ;No, It would be necessary to redraw the drawing area and then the selected gadgets border at each move.
          Else
            DrawGadgetDragHandleBorder(\Gadget)
          EndIf
          
          ;-> Gadget_EventType_Focus
        Case #PB_EventType_Focus
          FocusActiveGadget(\Gadget)
          
          ;-> Gadget_EventType_LostFocus
        Case #PB_EventType_LostFocus
          ResizeGadget(\Gadget, #PB_Ignore, #PB_Ignore, #PB_Ignore, #PB_Ignore)
          ;For testing (NO) with SetGadgetZOrder(\DragHandle) : SetGadgetZOrder(\DragHandle, -1) in FocusActiveGadget (Focus)
          ;SetGadgetZOrder(\DragHandle, 9)
          RemoveKeyboardShortcut(0, #PB_Shortcut_Delete)
          ;ResizeSVDGadget(\Gadget, #PB_Ignore, #PB_Ignore, #PB_Ignore, #PB_Ignore)
          ;Do not Post Event to keep X, Y, Width, Height SpinGadget on hand
          
          ;-> Gadget_EventType_KeyDown
        Case #PB_EventType_KeyDown
          If GetGadgetAttribute(\DragHandle, #PB_Canvas_Modifiers) = #PB_Canvas_Shift
            ResizeGadgetKeyDown(\Gadget)
          Else
            MoveGadgetKeyDown(\Gadget)
          EndIf
          
          ;-> Gadget_EventType_KeyUp
        Case #PB_EventType_KeyUp
          MoveGadgetKeyUp(\Gadget)
          
          ;  |-- #PB_EventType_RightButtonDown
        Case #PB_EventType_RightButtonDown
          ResizeGadget(\Gadget, #PB_Ignore, #PB_Ignore, #PB_Ignore, #PB_Ignore)   ;to avoid a white frame (=canvas) instead of gadget
          
          ;  |-- #PB_EventType_MiddleButtonDown
        Case #PB_EventType_MiddleButtonDown
          ResizeGadget(\Gadget, #PB_Ignore, #PB_Ignore, #PB_Ignore, #PB_Ignore)   ;to avoid a white frame (=canvas) instead of gadget
          
          ;-> Gadget_EventType_LeftButtonDown
        Case #PB_EventType_LeftButtonDown
          If \DragHandle <> EventGadget()
            If IsGadget(\DragHandle)
              SetActiveGadget(\DragHandle)
            EndIf
          EndIf   ;To keep Keyboard focus
          Selected = #True
          ;Force ResizeGadget Event if only moved. Init in LeftButtonDown, Width changed then +1-1+1... in MouseMove and at the end, restore the right size in LeftButtonUp if -1
          ;ForceResize = 1
          SavPosDim\X = \X : SavPosDim\Y = \Y : SavPosDim\Width = \Width : SavPosDim\Height = \Height
          MousePosX = GetGadgetAttribute(EventGadget(), #PB_Canvas_MouseX)
          MousePosY = GetGadgetAttribute(EventGadget(), #PB_Canvas_MouseY)
          GadgetX0 = \X : GadgetWidth0 = \Width: GadgetX1 = GadgetX0 + GadgetWidth0
          GadgetY0 = \Y : GadgetHeight0 = \Height :GadgetY1 = GadgetY0 + GadgetHeight0
          If IsGadget(\ParentGadget)
            If GadgetType(\ParentGadget) = #PB_GadgetType_ScrollArea
              ScrollX = GadgetX(\ParentGadget)-GetGadgetAttribute(\ParentGadget, #PB_ScrollArea_X) : ScrollY = GadgetY(\ParentGadget)-GetGadgetAttribute(\ParentGadget, #PB_ScrollArea_Y)
            Else   ;Other Containers
              ScrollX = GadgetX(\ParentGadget) : ScrollY = GadgetY(\ParentGadget)
            EndIf
          ElseIf IsWindow(\ParentGadget)   ;Window
            ScrollX = 0 : ScrollY = 0
          EndIf
          If IsGadget(\Gadget)
            ResizeGadget(\Gadget, #PB_Ignore, #PB_Ignore, #PB_Ignore, #PB_Ignore)   ;to avoid a white frame (canvas) instead of gadget
          EndIf
          If DrawDragHandleBorderOnGridArea = #True Or \DrawGadget= #True
            DrawFullDrawingArea()
            SelectDrawAreaDragHandleBorder(#False)
          EndIf
          If GroupGadget = # True
            HideAllHandlesOnMoveGroup(\Gadget, #True)
          Else
            HideAllHandlesOnMove(\Gadget, #True)
          EndIf
          ResizePaintAllGadgetAndDragHandle()   ;Redraw all Gadget to avoid overlay effects
          
          ;-> Gadget_EventType_LeftButtonUp
        Case #PB_EventType_LeftButtonUp
          Selected = #False
          ;Force ResizeGadget Event if only moved. Init in LeftButtonDown, Width changed then +1-1+1... in MouseMove and at the end, restore the right size in LeftButtonUp if -1
          ;If ForceResize = -1 : \Width + ForceResize : ResizeGadget(\Gadget, \X, \Y, \Width, #PB_Ignore) : EndIf
          If DrawDragHandleBorderOnGridArea = #True Or \DrawGadget = #True
            DrawFullDrawingArea()
            SelectDrawAreaDragHandleBorder(#True)
          EndIf
          If GroupGadget = # True
            ResizeAllHandlesOfGadgetGroup(\Gadget)
            HideAllHandlesOnMoveGroup(\Gadget, #False)
          Else
            ResizeAllHandlesOfGadget(\Gadget)
            HideAllHandlesOnMove(\Gadget, #False)
          EndIf
          ;For Testing
          ;If DisplayHandleCornerOnMove = #False : SetWinRedrawON(#DrawArea, #True) : EndIf
          If \Model = "WebGadget"   ;Specific for WebGadget to Redraw it. No success on #PB_EventType_LostFocus
            ResizeGadget(\Gadget, #PB_Ignore, #PB_Ignore, #PB_Ignore, GadgetHeight(\Gadget)-1)
            ResizeGadget(\Gadget, #PB_Ignore, #PB_Ignore, #PB_Ignore, GadgetHeight(\Gadget)+1)
          EndIf
          ResizeSVDGadget(\Gadget, #PB_Ignore, #PB_Ignore, #PB_Ignore, #PB_Ignore)
          ResizePaintAllGadgetAndDragHandle()   ;Redraw all Gadget to avoid overlay effects
          
          ;-> Gadget_EventType_MouseMove
        Case #PB_EventType_MouseMove
          If Selected And \Lock = #False
            X = WindowMouseX(0)-MousePosX-ScrollX
            Y = WindowMouseY(0)-MousePosY-ScrollY
            ;MOVE Gadget
            If EventGadget() = \DragHandle
              If DrawDragHandleBorderOnGridArea = #False
                X+#OutSideBorder : Y+#OutSideBorder
              EndIf
              If X <> SavPosDim\X Or Y <> SavPosDim\Y
                If GroupGadget = #True
                  MoveGadgetAndHandleGroup(\Gadget, X - SavPosDim\X, Y - SavPosDim\Y, DisplayHandleCornerOnMove)
                Else
                  MoveGadgetAndHandle(\Gadget, X - SavPosDim\X, Y - SavPosDim\Y, DisplayHandleCornerOnMove)
                EndIf
              EndIf
              ;RESIZE Gadget
            Else
              X1 = \X : Y1 = \Y : Width1 = \Width: Height1 = \Height
              Select EventGadget()
                Case \Handle[1]   ;Handle top, middle (N)
                  Height1 = GridMatch(GadgetY1-(Y+#HandelSize), DragSpace, #MinSize, GadgetY1-MinY)
                  Y1 = GridMatch(Y+#HandelSize, DragSpace, MinY, GadgetY1-Height1)
                Case \Handle[2]   ;Handle top, right (NE)
                  Width1 = GridMatch(X, DragSpace, GadgetX0+#MinSize, MaxX)-GadgetX0
                  Height1 = GridMatch(GadgetY1-(Y+#HandelSize), DragSpace, #MinSize, GadgetY1-MinY)
                  Y1 = GridMatch(Y+#HandelSize, DragSpace, MinY, GadgetY1-Height1)
                Case \Handle[3]   ;Handle middle, right (E)
                  Width1 = GridMatch(X, DragSpace, GadgetX0+#MinSize, MaxX)-GadgetX0
                Case \Handle[4]   ;Handle bottom, right (SE)
                  Width1 = GridMatch(X, DragSpace, GadgetX0+#MinSize, MaxX)-GadgetX0
                  Height1 = GridMatch(Y, DragSpace, GadgetY0+#MinSize, MaxY)-GadgetY0
                Case \Handle[5]   ;Handle bottom, middle (S)
                  Height1 = GridMatch(Y, DragSpace, GadgetY0+#MinSize, MaxY)-GadgetY0
                Case \Handle[6]   ;Handle bottom, left (SW)
                  Width1 = GridMatch(GadgetX1-(X+#HandelSize), DragSpace, #MinSize, GadgetX1-MinX)
                  Height1 = GridMatch(Y, DragSpace, GadgetY0+#MinSize, MaxY)-GadgetY0
                  X1 = GridMatch(X+#HandelSize, DragSpace, MinX, GadgetX1-Width1)
                Case \Handle[7]   ;Handle middle, left (W)
                  Width1 = GridMatch(GadgetX1-(X+#HandelSize), DragSpace, #MinSize, GadgetX1-MinX)
                  X1 = GridMatch(X+#HandelSize, DragSpace, MinX, GadgetX1-Width1)
                Case \Handle[8]   ;Handle top, left (NW)
                  Width1 = GridMatch(GadgetX1-(X+#HandelSize), DragSpace, #MinSize, GadgetX1-MinX)
                  Height1 = GridMatch(GadgetY1-(Y+#HandelSize), DragSpace, #MinSize, GadgetY1-MinY)
                  X1 = GridMatch(X+#HandelSize, DragSpace, MinX, GadgetX1-Width1)
                  Y1 = GridMatch(Y+#HandelSize, DragSpace, MinY, GadgetY1-Height1)
              EndSelect
              
              If X1 <> SavPosDim\X Or Y1 <> SavPosDim\Y Or Width1 <> SavPosDim\Width Or Height1 <> SavPosDim\Height
                ;Do not use SetWinRedrawON False/True with WS_CLIPCHILDREN GWL_STYLE on the #DrawArea
                ;SetWinRedrawON(#DrawArea, #False)
                \X = X1 : \Y = Y1 : \Width = Width1 : \Height= Height1
                If \DrawGadget = #False
                  ResizeGadget(\Gadget, \X, \Y, \Width, \Height)
                  If GadgetType(\Gadget) = #PB_GadgetType_Image
                    ResizeImageGadget(\Gadget)
                  EndIf
                EndIf
                If DrawDragHandleBorderOnGridArea = #True Or \DrawGadget = #True
                  DrawFullDrawingArea()
                  SelectDrawAreaDragHandleBorder(#False)
                EndIf
                If DisplayHandleCornerOnMove = #True
                  If GroupGadget = # True
                    ResizeAllHandlesOfGadgetGroup(\Gadget)
                  Else
                    ResizeAllHandlesOfGadget(\Gadget)
                  EndIf
                EndIf
                ;Do not use SetWinRedrawON False/True with WS_CLIPCHILDREN GWL_STYLE on the #DrawArea
                ;SetWinRedrawON(#DrawArea, #True)
                SavPosDim\X = \X : SavPosDim\Y = \Y : SavPosDim\Width = \Width : SavPosDim\Height = \Height
                ;Force ResizeGadget Event if only moved. Init in LeftButtonDown, Width changed then +1-1+1... in MouseMove and at the end, restore the right size in LeftButtonUp if -1
                ;If ForceResize = -1  : SavPosDim\Width + ForceResize : EndIf
                PostEvent(#PB_Event_Gadget, 0, \Gadget, #SVD_Gadget_Resize, @SavPosDim)
              EndIf
            EndIf
          EndIf
      EndSelect
    EndWith
  EndProcedure
  
  Procedure SVD_DrawAeraCallback()
    Static DrawGadget_Focus.b, Selected.b, MousePosX.i, MousePosY.i, DeltaX.i, DeltaY.i
    Static MouseOverGadget.i, SavPBCursor
    Protected X1.i, Y1.i, I.i
    
    Select EventType()
        
        ;  |-- #PB_EventType_LostFocus
      Case #PB_EventType_LostFocus
        RemoveKeyboardShortcut(0, #PB_Shortcut_Delete)
        
        ;  |-- #PB_EventType_RightClick
      Case #PB_EventType_RightClick
        PostEvent(#PB_Event_Gadget, 0, #DrawArea, #SVD_DrawArea_RightClick)   ;Right Click for the MenuPopup
        
        ;-> DrawAera_EventType_KeyDown
      Case #PB_EventType_KeyDown
        If GetGadgetAttribute(#DrawArea, #PB_Canvas_Modifiers) = #PB_Canvas_Shift
          ResizeGadgetKeyDown(SelectedDrawGadget)
        Else
          MoveGadgetKeyDown(SelectedDrawGadget)
        EndIf
        
        ;-> DrawAera_EventType_KeyUp
      Case #PB_EventType_KeyUp
        If SelectedDrawGadget <> #PB_Ignore
          MoveGadgetKeyUp(SelectedDrawGadget)
        EndIf
        
        ;-> DrawAera_EventType_LeftButtonDown
      Case #PB_EventType_LeftButtonDown
        If MouseOverGadget <> #PB_Ignore
          DrawGadget_Focus = #True
          ParentPosDim()
          DrawFullDrawingArea()
          SelectDrawAreaDragHandleBorder(#False)
          SelectedDrawGadget = MouseOverGadget
          FocusActiveDrawGadget(SelectedDrawGadget)
          If GroupGadget = # True
            HideAllHandlesOnMoveGroup(SelectedDrawGadget, #True)
          Else
            HideAllHandlesOnMove(SelectedDrawGadget, #True)
          EndIf
        ElseIf MouseOverDrawArea() = #True
          DrawGadget_Focus = #False
          FocusActiveDrawAera()
          PostEvent(#PB_Event_Gadget, 0, #DrawArea, #SVD_DrawArea_Focus)   ;Left Click Lost focus for now
        ElseIf IsGadget(LastGadgetFocus)
          SetSelectedGadget(LastGadgetFocus)
        EndIf
        
        ;-> DrawAera_EventType_LeftButtonUp
      Case #PB_EventType_LeftButtonUp
        DrawGadget_Focus = #False
        DrawFullDrawingArea()
        SelectDrawAreaDragHandleBorder(#True)
        If SelectedDrawGadget <> #PB_Ignore
          With SVDListGadget()
            If FindMapElement(SVDListGadget(), Str(SelectedDrawGadget))
              If GroupGadget = # True
                ResizeAllHandlesOfGadgetGroup(SelectedDrawGadget)
                HideAllHandlesOnMoveGroup(SelectedDrawGadget, #False)
              Else
                ResizeAllHandlesOfGadget(SelectedDrawGadget)
                HideAllHandlesOnMove(SelectedDrawGadget, #False)
              EndIf
            EndIf
          EndWith
        EndIf
        ResizePaintAllGadgetAndDragHandle()   ;Redraw all Gadget to avoid overlay effects
        
        ;-> DrawAera_EventType_MouseMove
      Case #PB_EventType_MouseMove
        MousePosX = GetGadgetAttribute(#DrawArea, #PB_Canvas_MouseX)
        MousePosY = GetGadgetAttribute(#DrawArea, #PB_Canvas_MouseY)
        
        If DrawGadget_Focus = #False
          ;Set Cursor if Mouse over Gadget
          MouseOverGadget = #PB_Ignore
          With SVDListGadget()
            ForEach SVDListGadget()
              If \ModelType <> 0 And \Hide = #False And \DrawGadget = #True And MousePosX > = \X And MousePosX <= \X + \Width  And MousePosY >= \Y And MousePosY <= \Y + \Height
                MouseOverGadget = \Gadget
                SavPosDim\X = \X : SavPosDim\Y = \Y : SavPosDim\Width = \Width : SavPosDim\Height = \Height
                DeltaX = MousePosX - \X
                DeltaY = MousePosY - \Y
              EndIf
            Next
          EndWith
          If MouseOverGadget <> #PB_Ignore
            If SavPBCursor <> #PB_Cursor_Arrows
              SetGadgetAttribute(#DrawArea, #PB_Canvas_Cursor, #PB_Cursor_Arrows) : SavPBCursor = #PB_Cursor_Arrows
            EndIf
          Else
            If SavPBCursor <> #PB_Cursor_Default
              SetGadgetAttribute(#DrawArea, #PB_Canvas_Cursor, #PB_Cursor_Default) : SavPBCursor = #PB_Cursor_Default
            EndIf
          EndIf
          
        ElseIf SelectedDrawGadget <> #PB_Ignore   ;Move selected Gadget
          If MousePosX - DeltaX <> SavPosDim\X Or MousePosY - DeltaY <> SavPosDim\Y
            If GroupGadget = #True
              MoveGadgetAndHandleGroup(SelectedDrawGadget, MousePosX - DeltaX - SavPosDim\X, MousePosY - DeltaY - SavPosDim\Y, DisplayHandleCornerOnMove)
            Else
              MoveGadgetAndHandle(SelectedDrawGadget, MousePosX - DeltaX - SavPosDim\X, MousePosY - DeltaY - SavPosDim\Y, DisplayHandleCornerOnMove)
            EndIf
          EndIf
          ;X1 = GridMatch(MousePosX - DeltaX, DragSpace, MinX, MaxX-\Width)
          ;Y1 = GridMatch(MousePosY - DeltaY, DragSpace, MinY, MaxY-\Height)
          ;If X1 <> SavPosDim\X Or Y1 <> SavPosDim\Y
          ;  MoveGadgetAndHandle(SelectedDrawGadget, X1 - SavPosDim\X, Y1 - SavPosDim\Y, DisplayHandleCornerOnMove)
          ;EndIf
        EndIf
        
    EndSelect
  EndProcedure
  
  Procedure SVD_WinCallback()
    Static Selected.b, MousePosX.i, MousePosY.i, WinWidth.i, WinHeight.i
    Static ScrollX.i, ScrollY.i
    Protected  WinHandle = EventGadget(), ParentGadget = GetGadgetData(EventGadget())
    
    Select EventType()
      Case #PB_EventType_LeftButtonDown
        Selected = #True
        ParentPosDim()
        If AddStatusBar = #True : MinY+AddStatusBarHeight : EndIf   ;Add the height of the status bar to MinY for the minimum height of the window
        FocusActiveDrawAera()
        PostEvent(#PB_Event_Gadget, 0, WinHandle, #SVD_Window_Focus)   ;Init Window Selected
        MousePosX = GetGadgetAttribute(WinHandle, #PB_Canvas_MouseX) : MousePosY = GetGadgetAttribute(WinHandle, #PB_Canvas_MouseY)
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
          WinWidth = WindowMouseX(0)-MousePosX-ScrollX-1 : WinHeight = WindowMouseY(0)-MousePosY-ScrollY-1
          WinWidth = GridMatch(WinWidth, DragSpace, MinX+#MinSize, GetGadgetAttribute(ParentGadget, #PB_ScrollArea_InnerWidth) - 10)
          WinHeight = GridMatch(WinHeight, DragSpace, MinY+#MinSize, GetGadgetAttribute(ParentGadget, #PB_ScrollArea_InnerHeight) - 10)
          SavPosDim\X = 0 : SavPosDim\Y = 0 : SavPosDim\Width = WinWidth : SavPosDim\Height = WinHeight
          PostEvent(#PB_Event_Gadget, 0, WinHandle, #SVD_Window_ReSize, @SavPosDim)   ;Updates the 4 SpinGadget(Width,Height)+UserScreen_Width,UserScreen_Height+Resize(WinHandle)+DrawFullDrawingArea
        EndIf
        
    EndSelect
  EndProcedure
  ;-
  
  Procedure DrawCanvasGadget(Gadget.i)
    PostEvent(#PB_Event_Gadget, 0, Gadget, #PB_EventType_Resize)
  EndProcedure
  
  Procedure SetDrawGadgetAttribute(Gadget.i)
    DrawFullDrawingArea()
    SelectDrawAreaDragHandleBorder(#True)
  EndProcedure
  
  Procedure SetSelectedGadget(Gadget.i)
    With SVDListGadget()
      If FindMapElement(SVDListGadget(), Str(Gadget))
        If \DrawGadget = #False
          SetActiveGadget(\DragHandle)
        Else
          SetActiveGadget(#DrawArea)   ;To have the keyboard arrows operational right now
          If Gadget = 0
            FocusActiveDrawAera()
          Else
            FocusActiveDrawGadget(Gadget)
          EndIf
        EndIf
      EndIf
    EndWith
  EndProcedure
  
  Procedure HideSVDGadget(Gadget.i)
    Protected I.i
    With SVDListGadget()
      If FindMapElement(SVDListGadget(), Str(Gadget))
        If \DrawGadget = #False
          HideGadget(Gadget, SVDListGadget()\Hide)
          HideGadget(\DragHandle,\Hide)
          SetActiveGadget(\DragHandle)
        Else
          DrawFullDrawingArea()
          SelectDrawAreaDragHandleBorder(#True)
          FocusActiveDrawGadget(Gadget)
        EndIf
      EndIf
    EndWith
  EndProcedure
  
  Procedure DeleteSVDGadget(Gadget.i)
    Protected I.i, K.i
    With SVDListGadget()
      If FindMapElement(SVDListGadget(), Str(Gadget))
        If IsGadget(\Gadget) And GadgetType(\Gadget) = #PB_GadgetType_Canvas
          UnbindGadgetEvent(\Gadget, @SVD_ResizeGadget(), #PB_EventType_Resize)
        EndIf
        For I = 1 To 8
          If \Handle[I]
            UnbindGadgetEvent(\Handle[I], @SVD_GadgetCallback())
            SetGadgetData(\Handle[I], #PB_Ignore)
            HideGadget(\Handle[I],#True)
          EndIf
        Next
        If \DrawGadget = #False    ;DragHandle Array
          SortStructuredArray(GadgetDragHandleArray(), #PB_Sort_Descending, OffsetOf(GadgetDragHandle\DragHandle), TypeOf(GadgetDragHandle\DragHandle))
          SortStructuredArray(GadgetDragHandleArray(), #PB_Sort_Descending, OffsetOf(GadgetDragHandle\Gadget), TypeOf(GadgetDragHandle\Gadget))
          For K = 0 To ArraySize(GadgetDragHandleArray())
            If GadgetDragHandleArray(K)\Gadget = Gadget
              GadgetDragHandleArray(K)\Gadget = 0
              UnbindGadgetEvent(GadgetDragHandleArray(K)\DragHandle, @SVD_GadgetCallback())
              SetGadgetData(GadgetDragHandleArray(K)\DragHandle, #PB_Ignore)
              HideGadget(GadgetDragHandleArray(K)\DragHandle,#True)
              Break
            EndIf
          Next
          DeleteMapElement(SVDListGadget(), Str(Gadget))
          FreeGadget(Gadget)
          If DrawDragHandleBorderOnGridArea =#True
            DrawFullDrawingArea()
            SelectDrawAreaDragHandleBorder(#True)
          EndIf
        Else
          DeleteMapElement(SVDListGadget(), Str(Gadget))
          DrawFullDrawingArea()
          SelectDrawAreaDragHandleBorder(#True)
        EndIf
      EndIf
    EndWith
  EndProcedure
  
  Procedure AddSVDDrawGadget(Gadget.i)
    Protected *SVDListParentGadget.SVDParentGadget, I.i
    With SVDListGadget()
      If FindMapElement(SVDListGadget(), Str(Gadget))
        \DragHandle = 0
        If \Model = "ContainerGadget" Or \Model = "PanelGadget" Or \Model = "ScrollAreaGadget"
          AddMapElement(SVDListParentGadget(), Str(\ParentGadget))
          SVDListParentGadget()\ParentGadget = Gadget
          SVDListParentGadget()\X = SVDListGadget()\X : SVDListParentGadget()\Y = SVDListGadget()\Y
          SVDListParentGadget()\Width = SVDListGadget()\Width : SVDListParentGadget()\Height = SVDListGadget()\Height
        EndIf
      EndIf
    EndWith
    DrawFullDrawingArea()
    SelectDrawAreaDragHandleBorder(#True)
    SetActiveGadget(#DrawArea)   ;To have the keyboard arrows operational right now
    FocusActiveDrawGadget(Gadget)
  EndProcedure
  
  Procedure AddSVDGadget(Gadget.i)
    Protected I.i
    With SVDListGadget()
      If FindMapElement(SVDListGadget(), Str(Gadget))
        SortStructuredArray(GadgetDragHandleArray(), #PB_Sort_Descending, OffsetOf(GadgetDragHandle\DragHandle), TypeOf(GadgetDragHandle\DragHandle))
        SortStructuredArray(GadgetDragHandleArray(), #PB_Sort_Ascending, OffsetOf(GadgetDragHandle\Gadget), TypeOf(GadgetDragHandle\Gadget))
        For I = 0 To ArraySize(GadgetDragHandleArray())
          If GadgetDragHandleArray(I)\Gadget = 0 And GadgetDragHandleArray(I)\DragHandle
            \DragHandle = GadgetDragHandleArray(I)\DragHandle
            GadgetDragHandleArray(I)\Gadget = \Gadget
            HideGadget(\DragHandle,#False)
            If DrawDragHandleBorderOnGridArea = #True   ;CompilerIf #PB_Compiler_OS = #PB_OS_MacOS
              ResizeGadget(\DragHandle, \X, \Y, \Width, \Height)
            Else
              ResizeGadget(\DragHandle, \X-#OutSideBorder, \Y-#OutSideBorder, \Width+(2*#OutSideBorder), \Height+(2*#OutSideBorder))
            EndIf
            Break
          EndIf
        Next
        SetGadgetData(\DragHandle, SVDListGadget())
        If DrawDragHandleBorderOnGridArea = #False
          DrawDragHandleBorder(\DragHandle, #FreeHandelColor)
        EndIf
        BindGadgetEvent(\DragHandle, @SVD_GadgetCallback())
        
        If IsGadget(\Gadget) And GadgetType(\Gadget) = #PB_GadgetType_Canvas
          BindGadgetEvent(\Gadget, @SVD_ResizeGadget(), #PB_EventType_Resize)
        EndIf
        SetActiveGadget(\DragHandle)
        
        ;Example For testing on \Gadget or \DragHandle... #GWL_STYLE or/and #GWL_EXSTYLE (CompilerIf #PB_Compiler_OS = #PB_OS_Windows)
        ;SetWindowLongPtr_(GadgetID(\Gadget), #GWL_EXSTYLE, GetWindowLongPtr_(GadgetID(\Gadget), #GWL_STYLE) | #WS_CLIPSIBLINGS)
        ;SetWindowLongPtr_(GadgetID(\Gadget), #GWL_EXSTYLE, GetWindowLongPtr_(GadgetID(\Gadget), #GWL_STYLE) & (#WS_CLIPSIBLINGS ! - 1))
      EndIf
    EndWith
  EndProcedure
  
  Procedure DisableSVD()
    Protected I.i
    ;UnbindGadgetEvent for Draw Gadgets (Container + Frame)
    UnbindGadgetEvent(#DrawArea, @SVD_DrawAeraCallback())
    DisableGadget(#DrawArea, #True)
    ;Remove the draw border around Draw Gadget
    With SVDListGadget()
      ForEach SVDListGadget()
        If \ModelType <> 0
          If \DrawGadget = #True
            DrawAreaDragHandleBorder(\Gadget)
          Else
            CompilerIf #PB_Compiler_OS = #PB_OS_MacOS
              DisableGadget(\Gadget, #False)
            CompilerEndIf
          EndIf
        EndIf
      Next
    EndWith
    
    ;Unbind Handles
    For I = 0 To 8
      If I = 0
        UnbindGadgetEvent(GadgetHandle(0), @SVD_WinCallback())
      Else
        UnbindGadgetEvent(GadgetHandle(I), @SVD_GadgetCallback())
        ResizeGadget(GadgetHandle(I), 0, 0, #PB_Ignore, #PB_Ignore)
      EndIf
      SetGadgetData(GadgetHandle(I), #PB_Ignore)
      HideGadget(GadgetHandle(I),#True)
    Next
    ;Unbind DragHandle and Canvas Gadget
    SortStructuredArray(GadgetDragHandleArray(), #PB_Sort_Descending, OffsetOf(GadgetDragHandle\DragHandle), TypeOf(GadgetDragHandle\DragHandle))
    SortStructuredArray(GadgetDragHandleArray(), #PB_Sort_Descending, OffsetOf(GadgetDragHandle\Gadget), TypeOf(GadgetDragHandle\Gadget))
    For I = 0 To ArraySize(GadgetDragHandleArray())
      With GadgetDragHandleArray(I)
        If \Gadget <> 0
          UnbindGadgetEvent(\DragHandle, @SVD_GadgetCallback())
          If IsGadget(\Gadget) And GadgetType(\Gadget) = #PB_GadgetType_Canvas
            UnbindGadgetEvent(\Gadget, @SVD_ResizeGadget(), #PB_EventType_Resize)
          EndIf
          \Gadget = 0
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
    Protected GadgetObj.i, I.i
    ;       With SVDListGadget()      ;TagClearList: Enumerate Object To fill the list in common with ClearList
    ;         ;If PB_Object_EnumerateNext(PB_Window_Objects, @Window) : Debug Str(Window)+" - "+Str(GetWindowData(Window)) : EndIf
    ;         PB_Object_EnumerateStart(PB_Gadget_Objects)
    ;         While PB_Object_EnumerateNext(PB_Gadget_Objects, @GadgetObj)
    ;           If GetGadgetData(GadgetObj) <> #PB_Ignore And GadgetObj <> #ScrollDrawArea
    ;             AddMapElement(SVDListGadget(), Str(GadgetObj))
    ;             \ParentGadget = #ScrollDrawArea
    ;             \Gadget = GadgetObj
    ;             \Model = GadgetObj
    ;           EndIf
    ;         Wend
    ;       EndWith
    
    BindGadgetEvent(#DrawArea, @SVD_DrawAeraCallback())   ;BindGadgetEvent for Drawn Gadgets (Container + Frame)
    DisableGadget(#DrawArea, #False)
    ;Resize and Enable Drag Handle
    SortStructuredArray(GadgetDragHandleArray(), #PB_Sort_Descending, OffsetOf(GadgetDragHandle\DragHandle), TypeOf(GadgetDragHandle\DragHandle))
    SortStructuredArray(GadgetDragHandleArray(), #PB_Sort_Ascending, OffsetOf(GadgetDragHandle\Gadget), TypeOf(GadgetDragHandle\Gadget))
    With SVDListGadget()
      ForEach SVDListGadget()
        If \ModelType <> 0 And \DrawGadget = #False
          For I = 0 To ArraySize(GadgetDragHandleArray())
            If GadgetDragHandleArray(I)\Gadget = 0 And GadgetDragHandleArray(I)\DragHandle
              \DragHandle = GadgetDragHandleArray(I)\DragHandle
              GadgetDragHandleArray(I)\Gadget = \Gadget
              HideGadget(\DragHandle,#False)
              If DrawDragHandleBorderOnGridArea = #True
                ResizeGadget(\DragHandle, \X, \Y, \Width, \Height)
              Else
                ResizeGadget(\DragHandle, \X-#OutSideBorder, \Y-#OutSideBorder, \Width+(2*#OutSideBorder), \Height+(2*#OutSideBorder))
              EndIf
              ResizeGadget(\Gadget, #PB_Ignore, #PB_Ignore, #PB_Ignore, #PB_Ignore)
              CompilerIf #PB_Compiler_OS = #PB_OS_MacOS : DisableGadget(\Gadget, #True) : CompilerEndIf
              Break
            EndIf
          Next
          SetGadgetData(\DragHandle, SVDListGadget())
          DrawDragHandleBorder(\DragHandle, #FreeHandelColor)
          BindGadgetEvent(\DragHandle, @SVD_GadgetCallback())
          If IsGadget(\Gadget) And GadgetType(\Gadget) = #PB_GadgetType_Canvas
            BindGadgetEvent(\Gadget, @SVD_ResizeGadget(), #PB_EventType_Resize)
          EndIf
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
    
    ;Draw Grid on Canvas
    CompilerIf #PB_Compiler_OS = #PB_OS_Windows
      CanvasGadget(#DrawArea, 0, 0, ScrollDrawAreaWidth, ScrollDrawAreaHeight, #PB_Canvas_Keyboard | #PB_Canvas_Container)   ;Resize with Handles does not work with #PB_Canvas_Keyboard
                                                                                                                             ;OpenGadgetList(#ScrollDrawArea) : CloseGadgetList()   ;OpenGadgetList(#DrawArea)
                                                                                                                             ;SetGadgetZOrder(#DrawArea)
                                                                                                                             ;#WS_CLIPCHILDREN is Important in Draw Aera Canvas Container, to reduce Paint overlays and flickering
      SetWindowLongPtr_(GadgetID(#DrawArea), #GWL_STYLE, GetWindowLongPtr_(GadgetID(#DrawArea), #GWL_STYLE) | #WS_CLIPCHILDREN)
    CompilerElse
      CanvasGadget(#DrawArea, 0, 0, ScrollDrawAreaWidth, ScrollDrawAreaHeight, #PB_Canvas_Keyboard)
    CompilerEndIf
    SetGadgetData(#DrawArea, #PB_Ignore)   ;: DisableGadget(#DrawArea,#True)
    
    ;Create Drag Handle Canvas in advance, size 0 and hidden, used then behind every gadget
    ReDim GadgetDragHandleArray(CountGadget)
    For I = 0 To CountGadget
      With GadgetDragHandleArray(I)
        GadgetDragHandleArray(I)\DragHandle = CanvasGadget(#PB_Any, 0, 0, 0, 0, #PB_Canvas_Keyboard)
        HideGadget(\DragHandle,#True)
        SetGadgetData(\DragHandle, #PB_Ignore)
        CompilerIf #PB_Compiler_OS = #PB_OS_MacOS
          SetGadgetAttribute(\DragHandle, #PB_Canvas_Cursor, #PB_Cursor_Hand)
        CompilerElse
          SetGadgetAttribute(\DragHandle, #PB_Canvas_Cursor, #PB_Cursor_Arrows)
        CompilerEndIf
      EndWith
    Next
    SortStructuredArray(GadgetDragHandleArray(), #PB_Sort_Descending, OffsetOf(GadgetDragHandle\DragHandle), TypeOf(GadgetDragHandle\DragHandle))
    
    ;Create Handle 1 To 8: North, North-East, East, South-East, South, South-West, West, North-West
    Restore Cursors
    Read.i Mycursors
    For I = 0 To 8
      GadgetHandle(I) = CanvasGadget(#PB_Any, 0, 0, #HandelSize, #HandelSize)
      SetGadgetZOrder(GadgetHandle(I))
      HideGadget(GadgetHandle(I),#True)
      If I = 0      ;Position 0 used for the drawing area at bottom right
        DrawDragHandleBorder(GadgetHandle(I), #WinHandleColor)
      Else
        DrawDragHandleBorder(GadgetHandle(I), #SelectedHandelColor)
      EndIf
      Read.i Mycursors
      SetGadgetData(GadgetHandle(I), #PB_Ignore)
      SetGadgetAttribute(GadgetHandle(I), #PB_Canvas_Cursor, Mycursors)
      ;Example For testing on Gadget Handle Corner with #GWL_STYLE or/and #GWL_EXSTYLE (CompilerIf #PB_Compiler_OS = #PB_OS_Windows)
      ;SetWindowLongPtr_(GadgetID(GadgetHandle(I)), #GWL_STYLE, GetWindowLongPtr_(GadgetID(GadgetHandle(I)), #GWL_STYLE) | #WS_CLIPSIBLINGS)
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

; IDE Options = PureBasic 5.71 LTS (Windows - x64)
; Folding = ------------
; EnableXP
; Executable = SweetyVD.exe
; EnablePurifier