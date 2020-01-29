Declare RenameFormFocus()
Declare RenameFormLostFocus()
Declare RenameGadgetForm()
Declare RenameGadget(IdGadget.i)

Procedure RenameGadgetForm()
  Protected I.i
  Protected PropertiesPanelWidth.i = 210
  ContainerGadget(#RenameForm, 5, 228, GadgetWidth(#ContainerSize), GadgetHeight(#ContainerSize), #PB_Container_Single)
  ;CanvasGadget(#RenameForm, 5, 228, PropertiesPanelWidth, 124, #PB_Canvas_Border|#PB_Canvas_Keyboard|#PB_Canvas_Container)
  StringGadget(#RenameGadgetFrom, 2, 2, 154, 22, "", #PB_String_ReadOnly)
  ButtonImageGadget(#RenameFormGadgetButton, 158, 2, 22, 22, ImageID(#Img_Rename)) : DisableGadget(#RenameFormGadgetButton, #True)
  ButtonImageGadget(#DeleteFormGadgetButton, 182, 2, 22, 22, ImageID(#Img_Delete)) : DisableGadget(#DeleteFormGadgetButton, #True)
  StringGadget(#RenameGadgetString, 2, 36, 178, 22, "")
  TextGadget(#RenameGadgetMsg, 4, 58, 204, 18, "")
  ButtonGadget(#RenameGadgetCancel, 75, 74, 50, 20, "Cancel")
  ButtonGadget(#RenameGadgetOK, 130, 74, 50, 20, "OK")
  SetActiveGadget(#RenameGadgetString)
  CloseGadgetList()
  HideGadget(#RenameForm, #True)
EndProcedure

Procedure RenameFormFocus()
  Protected IdGadget.i, GadgetsListElement.i, I.i
  GadgetsListElement = GetGadgetState(#ListGadgets)
  IdGadget=GetGadgetItemData(#ListGadgets, GadgetsListElement)
  If FindMapElement(SVDListGadget(), Str(IdGadget))
    SetGadgetText(#RenameGadgetFrom, Mid(SVDListGadget()\Name,2))
    SetGadgetText(#RenameGadgetString, Mid(SVDListGadget()\Name,2))
  EndIf
  SetGadgetText(#RenameGadgetMsg, "")
  HideGadget(#RenameForm, #False) : HideGadget(#ContainerSize, #True)
  SetActiveGadget(#RenameGadgetString)
  For I = #RenameForm To #RenameGadgetCancel
    If IsGadget(I) : SetGadgetData(I, #RenameForm) : EndIf
  Next
  AddKeyboardShortcut(#MainWindow, #PB_Shortcut_Escape, #Shortcut_Escape) : AddKeyboardShortcut(#MainWindow, #PB_Shortcut_Return, #Shortcut_Return)
  MonitorRenameFormFocus = #True
EndProcedure

Procedure RenameFormLostFocus()
  RemoveKeyboardShortcut(#MainWindow, #PB_Shortcut_Escape) : RemoveKeyboardShortcut(#MainWindow, #PB_Shortcut_Return)
  MonitorRenameFormFocus = #False
  HideGadget(#RenameForm, #True) : HideGadget(#ContainerSize, #False)
EndProcedure

Procedure RenameGadget(IdGadget.i)
  Protected RenameGadgetString.s, I.i, ValidName.b = #True
  RenameGadgetString = GetGadgetText(#RenameGadgetString)
  ;ToDo Check valid char
  If RenameGadgetString = ""
    SetGadgetText(#RenameGadgetMsg, "Enter a Name")
    SetGadgetText(#RenameGadgetString, Mid(RenameGadgetString,2))
    ValidName = #False
  ElseIf Left(RenameGadgetString, 1) = "#"
    SetGadgetText(#RenameGadgetMsg, "# as 1st Char Removed")
    SetGadgetText(#RenameGadgetString, Mid(RenameGadgetString,2))
    ValidName = #False
  Else
    ForEach SVDListGadget()   ;Name already used
      If SVDListGadget()\Gadget <> IdGadget And SVDListGadget()\Name = "#" + RenameGadgetString + "_"
        SetGadgetText(#RenameGadgetMsg, "Name Already Used")
        ValidName = #False
        Break
      EndIf
    Next
    If ValidName = #True
      For I=0 To ArraySize(ModelGadget())
        If ModelGadget(I)\Name = RenameGadgetString   ;Name defined in Model Gadget: SweetyVD.json
          SetGadgetText(#RenameGadgetMsg, "Name is Reserved (Model)")
          ValidName = #False
          Break
        EndIf
      Next
    EndIf
  EndIf
  If ValidName = #True
    If FindMapElement(SVDListGadget(), Str(IdGadget))
      SVDListGadget()\Name = "#" + RenameGadgetString
      SetGadgetItemText(#ListControls, GetGadgetState(#ListControls), RenameGadgetString)
      SetGadgetItemText(#ListGadgets, GetGadgetState(#ListGadgets), RenameGadgetString)
    EndIf
    RenameFormLostFocus()
  Else
    SetActiveGadget(#RenameGadgetString)
  EndIf
EndProcedure
; IDE Options = PureBasic 5.71 LTS (Windows - x64)
; Folding = -
; EnableXP