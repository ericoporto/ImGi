// ImGi Module Header

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
  import static ImGi_Style* Create(); // $AUTOCOMPLETESTATICONLY$  
};

builtin struct ImGi {
  
  import static attribute ImGi_Style* Style;
  
  /// Call only once per frame and make sure to call End() after
  import static void Begin();
  
  /// Call only once per frame, after Begin() is called
  import static void End();
  
  // Layout  
  
  /// Pass an array of widths with count elements to configure the columns in a row. You can optionally specify a height.
  import static void LayoutRow(int count, int widths[], int height = 0);
  
  // Controls
  
  /// Creates a window, make sure to call a matching EndWindow() if this method return is not false
  import static ImGi_Res BeginWindow(String title, int x, int y, int width, int height, ImGi_Opt opt = 0);
  
  /// Has to be called each time a BeginWindow is successful once all elements inside the window are listed
  import static void EndWindow();
   
  /// NOT WORKING YET! 
  import static void OpenPopup(String name);
  
  /// NOT WORKING YET!
  import static ImGi_Res BeginPopup(String name);
  
  /// NOT WORKING YET!
  import static void EndPopup();
  
  /// This control is a Label containing the specified text
  import static void Label(String label);
  
  /// This control is a Multiline Label
  import static void Text(String text);
  
  /// This control is an editable TextBox
  import static String TextBox(String label, ImGi_Result* res, String buf, int bufsz, ImGi_Opt opt = 0);
  
  /// This control shows a Number, set step to allow quick mouse drag adjustment.
  import static ImGi_Res Number(String label, ImGi_Real* value, float step = 0, ImGi_Opt opt = 0);
  
  /// This control is a Slider
  import static ImGi_Res Slider(String label, ImGi_Real* value, float low, float high, float step = 0, ImGi_Opt opt = 0);
  
  /// This control is a Button
  import static ImGi_Res Button(String label, ImGi_Icon icon = 0, ImGi_Opt opt = eImGi_Opt_AlignCenter);
  
  /// This control is a CheckBox
  import static ImGi_Res CheckBox(String label, CheckBoxState* chkst);
};
