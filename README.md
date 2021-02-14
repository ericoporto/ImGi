# ImGi
AGS Script Module for Immediate Gui (based on rxi's Microui)

## usage

```AGS Script
// called on every game cycle, except when the game is blocked
function room_RepExec() // alternatively use repeatedly_execute() 
{
  ImGi.Begin(); 
    
  if(ImGi.BeginWindow("Hello World", 170, 140, 130, 60, eImGi_Opt_AlignCenter | eImGi_Opt_NoClose))
  {
    int rows[];
        
    rows = new int[1];
    rows[0] = 130;           // set a predefined column width size per element in row
    ImGi.LayoutRow(1, rows);  // rows after this line have such column config
       
    ImGi.Text("Welcome to ImGi!\nClick and drag the title header of this window to move it!");
           
    rows = new int[2];
    rows[0] = 60;
    rows[1] = 70;
    ImGi.LayoutRow(2, rows); // reconfig rows for two collumn
        
    ImGi.Label("A Label:");
    if(ImGi.Button("A Button!"))
    {
      player.Say("You clicked the button!");
    }    
  
    ImGi.EndWindow();
  }
    
  ImGi.End();  
}
```

## script API

ImGi entire API uses static functions and attributes

### Basic

#### `void ImGi.Begin()`

Call only once per frame and make sure to call End() after.

#### `void ImGi.End()`

Call only once per frame, after Begin() is called.


---

### Layout System

#### `void ImGi.LayoutRow(int count, int widths[], int height = 0)`

Pass an array of widths with count elements to configure the columns in a row. You can optionally specify a height.


---

### Controls

#### `ImGi_Res ImGi.BeginWindow(String title, int x, int y, int width, int height, ImGi_Opt opt = 0)`

Creates a window, make sure to call a matching EndWindow() if this method return is not false.

#### `void ImGi.EndWindow()`

Has to be called each time a BeginWindow is successful once all elements inside the window are listed

#### `void ImGi.Label(String label)`

This control is a Label containing the specified text.

#### `void ImGi.Text(String text)`

This control is a Multiline Label for visualization only.

#### `String ImGi.TextBox(String label, String buf, int bufsz, ImGi_Result* res = 0, ImGi_Opt opt = 0)`

This control is an editable TextBox.

#### `ImGi_Res ImGi.Button(String label, ImGi_Icon icon = 0, ImGi_Opt opt = eImGi_Opt_AlignCenter)`

his control is a Button.

#### `mGi_Res ImGi.CheckBox(String label, CheckBoxState* chkst)`

This control is a CheckBox.

#### `ImGi_Res ImGi.Number(String label, ImGi_Real* value, float step = 0, ImGi_Opt opt = 0)`

This control shows a Number, set step to allow quick mouse drag adjustments

#### `ImGi_Res ImGi.Slider(String label, ImGi_Real* value, float low, float high, float step = 0, ImGi_Opt opt = 0)`

This control is a Slider.


---

### Style and Design customisation

#### `ImGi_Style* ImGi.Style` 

Holds the Current Style for ImGi.


---

## License

This code is licensed with MIT [`LICENSE`](LICENSE).
