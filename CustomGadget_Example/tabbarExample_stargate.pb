XIncludeFile "../include/TabBarGadget.pbi"

Enumeration
  #Window
  #Gadget
EndEnumeration

OpenWindow(#Window, 0, 0, 400, 200, "TabBarGadget", #PB_Window_MinimizeGadget|#PB_Window_ScreenCentered)
TabBarGadget(#Gadget, 10, 10, WindowWidth(#Window)-20, #TabBarGadget_DefaultHeight, #TabBarGadget_Editable|#TabBarGadget_NoTabMoving|#TabBarGadget_BottomLine, #Window)
  AddTabBarGadgetItem(#Gadget, #PB_Default , "Edit this text")
  AddTabBarGadgetItem(#Gadget, #PB_Default , "with a double click")
  AddTabBarGadgetItem(#Gadget, #PB_Default , "on a tab")

Repeat
  
  Select WaitWindowEvent()
      
    Case #PB_Event_CloseWindow
      End
      
    Case #PB_Event_Gadget
      Select EventGadget()
        Case #Gadget
          Select EventType()
            Case #TabBarGadget_EventType_EditItem
              Debug "Tab "+Str(GetTabBarGadgetItemPosition(#Gadget, #TabBarGadgetItem_Event))+" has been edited."
          EndSelect
      EndSelect
      
  EndSelect
  
ForEver
; IDE Options = PureBasic 5.60 (Windows - x64)
; Folding = -
; EnableAsm
; EnableXP
; EnablePurifier