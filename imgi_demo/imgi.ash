// ImGi Module Header
//
//                   ImGi Version 0.3.0
//
//   ImGi is a Immediate GUI for Adventure Game Studio!
//   Create dynamic GUIs through AGS Script, rendered to screen using Overlays.
//
//   Avoid looking into ImGi internals for now since there's a lot of Work In Progress
// and try to concentrate on the public interface that is accessible through the Header.

// module enums
enum ImGi_Opt {
  eImGi_Opt_AlignCenter = 1, 
  eImGi_Opt_AlignRight = 2, 
  eImGi_Opt_NoInteract = 4, 
  eImGi_Opt_NoFrame = 8, 
  eImGi_Opt_NoResize = 16, 
  eImGi_Opt_NoScroll = 32, 
  eImGi_Opt_NoClose = 64, 
  eImGi_Opt_NoTitle = 128, 
  eImGi_Opt_HoldFocus = 256, 
  eImGi_Opt_AutoSize = 512, 
  eImGi_Opt_PopUp = 1024, 
  eImGi_Opt_Closed = 2048, 
  eImGi_Opt_Expanded = 4096
};


enum ImGi_Color{
  eImGi_Col_Text = 0, 
  eImGi_Col_Border, 
  eImGi_Col_WindowBG, 
  eImGi_Col_TitleBG,  
  eImGi_Col_TitleText, 
  eImGi_Col_PanelBG, 
  eImGi_Col_Button, 
  eImGi_Col_ButtonHover,
  eImGi_Col_ButtonFocus,  
  eImGi_Col_Base, 
  eImGi_Col_BaseHover, 
  eImGi_Col_BaseFocus, 
  eImGi_Col_ScrollBase, 
  eImGi_Col_ScrollThumb, 
  eImGi_Col_MAX
};

enum ImGi_Icon {
  eImGi_Icon_Close = 1,
  eImGi_Icon_Check,
  eImGi_Icon_Collapsed,
  eImGi_Icon_Expanded,
  eImGi_Icon_MAX
};

enum ImGi_Res {
  eImGi_Res_None   = 0,   
  eImGi_Res_Active = 1,
  eImGi_Res_Submit = 2,
  eImGi_Res_Change = 4
};

enum ImGi_Cfg_SkipFrames {
  ImGi_Cfg_SkipFramesNone = 0,   
  ImGi_Cfg_SkipFramesHalf = 2,
};

managed struct CheckBoxState
{
  bool state;  
};

managed struct ImGi_Real
{
  float value;  
};

managed struct ImGi_Result
{
  ImGi_Res state;  
};

managed struct ImGi_Style {
  FontType font;
  int size_x;
  int size_y;
  int padding;
  int spacing;
  int indent;
  int title_height;
  int scrollbar_size;
  int thumb_size;
  int colors[eImGi_Col_MAX];
  
  /// Properly creates a style with default configs. 
  import static ImGi_Style* Create(); // $AUTOCOMPLETESTATICONLY$  
};

builtin managed struct ImGi_Config {
  
  /// Allows skipping frames which may alleviate performance in hi-res games
  import static attribute ImGi_Cfg_SkipFrames SkipFrames; 
};

builtin struct ImGi {
  
  /// Holds the behavior config for ImGi
  import static attribute ImGi_Config* Config;
  
  /// Holds the Current Style for ImGi.
  import static attribute ImGi_Style* Style;
  
  /// Call only once per frame and make sure to call End() after.
  import static void Begin();
  
  /// Call only once per frame, after Begin() is called.
  import static void End();
  
  // Layout  
  
  /// Pass an array of widths with count elements to configure the columns in a row. You can optionally specify a height.
  import static void LayoutRow(int count, int widths[], int height = 0);
  
  // Containers
  
  /// Creates a window, make sure to call a matching EndWindow() if this method return is not false.
  import static ImGi_Res BeginWindow(String title, int x, int y, int width, int height, ImGi_Opt opt = 0);
  
  /// Has to be called each time a BeginWindow is successful once all elements inside the window are listed
  import static void EndWindow();
  
  /// Opens a window that was closed
  import static void OpenWindow(String title);
     
  /// Creates a popup that opens at mouse position and stays. If it returns successful, you have to call EndPopup() after.
  import static ImGi_Res BeginPopup(String name);

  /// Has to be called each time a BeginPopup is successful once all elements inside the popup are listed
  import static void EndPopup();
     
  /// Open the Popup with matching name, has to be called at same level BeginPopup is. 
  import static void OpenPopup(String name);
  
  /// Closes what is the current scope (Window, Popup, ...). Don't call it outside of a Window, a Popup, ...
  import static void Close();

  // Controls
     
  /// This control is a Label containing the specified text.
  import static void Label(String label);
  
  /// This control is a Multiline Label for visualization only.
  import static void Text(String text);
  
  /// This control is an editable TextBox.
  import static String TextBox(String label, String buf, int bufsz, ImGi_Result* res = 0, ImGi_Opt opt = 0);
  
  /// This control is a Button.
  import static ImGi_Res Button(String label, ImGi_Icon icon = 0, ImGi_Opt opt = eImGi_Opt_AlignCenter);
  
  /// This control is a CheckBox.
  import static ImGi_Res CheckBox(String label, CheckBoxState* chkst);
  
  /// This control shows a Number, set step to allow quick mouse drag adjustments.
  import static ImGi_Res Number(String label, ImGi_Real* value, float step = 0, String format = 0, ImGi_Opt opt = 0);
  
  /// This control is a Slider.
  import static ImGi_Res Slider(String label, ImGi_Real* value, float low, float high, float step = 0, String format = 0, ImGi_Opt opt = 0);  
};

// ImGi code is licensed with MIT LICENSE. Copyright (c) 2021 eri0o
// ImGi is based on microui, which is MIT licensed too. Microuis is Copyright (c) 2020 rxi