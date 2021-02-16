AGSScriptModule    eri0o Script Module for Immediate Gui ImGi 0.2.2 ��  // ImGi Script - these are the internals of the module

// internals
#define UNCLIPPED_RECT_W Screen.Width
#define UNCLIPPED_RECT_H Screen.Height

// private header
#region PRIVATE_HEADER

#define MAX_STACK_SIZE 500
#define MAX_TEXT_CMD_STR_SIZE 100

#define IMGI_COMMANDLIST_SIZE     696
#define IMGI_ROOTLIST_SIZE        32
#define IMGI_CONTAINERSTACK_SIZE  32
#define IMGI_CLIPSTACK_SIZE       32
#define IMGI_IDSTACK_SIZE         32
#define IMGI_LAYOUTSTACK_SIZE     16
#define IMGI_CONTAINERPOOL_SIZE   48
#define IMGI_TREENODEPOOL_SIZE    48
#define IMGI_MAX_WIDTHS           16
#define IMGI_REAL                 float
#define IMGI_REAL_FMT             "%.4g"
#define IMGI_SLIDER_FMT           "%.3f"
#define IMGI_MAX_FMT              127
#define IMGI_KEY_SHIFT_LEFT       403
#define IMGI_KEY_SHIFT_RIGHT      404
#define IMGI_KEY_CTRL_LEFT        405
#define IMGI_KEY_CTRL_RIGHT       406

enum ImGi_ClipType {
  eImGi_ClipNone = 0, 
  eImGi_ClipPart = 1,
  eImGi_ClipAll
};

enum ImGi_Mouse_Button {
  eImGi_Mouse_None = 0, 
  eImGi_Mouse_Left = 1, 
  eImGi_Mouse_Right = 2, 
  eImGi_Mouse_Middle = 4, 
};

enum ImGi_CmdType {
  eImGi_CmdNone = 0, 
  eImGi_CmdJump, 
  eImGi_CmdClip, 
  eImGi_CmdRect,
  eImGi_CmdText, 
  eImGi_CmdIcon, 
};

enum ImGi_LayoutType { 
  eImGi_Lay_Relative = 1, 
  eImGi_Lay_Absolute = 2 
};

// fake enum, just be consistent
enum ImGi_ID { };
enum ImGiCmd_ID { };

struct StackOfInt {
  int items[MAX_STACK_SIZE];
  
  int index;
  import void Push(int number);
  import int Pop();
};

managed struct Rect {
  int x;
  int y;
  int w;
  int h;
  import static Rect* Create(int x, int y, int w, int h);  // $AUTOCOMPLETESTATICONLY$
  import Rect* Copy();
  import Rect* Intersect(Rect* r);
  import Rect* Expand(int n);
  import bool IsOverlappingPoint(Point* p);
  import bool IsOverlapping(int x, int y);
};

managed struct ImGi_PollItem 
{ 
  int id; 
  int last_update; 
  import static ImGi_PollItem* Create(int id, int last_update);  // $AUTOCOMPLETESTATICONLY$
};

managed struct ImGi_Cmd 
{ 
  ImGi_CmdType type;
  int size;
  ImGiCmd_ID id;
  int x;
  int y;
  int w;
  int h;
  FontType font;
  int color;
  ImGi_Icon icon;
  char str[MAX_TEXT_CMD_STR_SIZE];
  int dst_idx;
  
};

managed struct ImGi_Layout
{
  int body_x;
  int body_y;
  int body_w;
  int body_h;
  
  int next_x;
  int next_y;
  int next_w;
  int next_h;
  
  int pos_x;
  int pos_y;
  
  int size_x;
  int size_y;
  
  int max_x;
  int max_y;
  
  int widths[IMGI_MAX_WIDTHS];
  int items;
  int item_index;
  int next_row;
  ImGi_LayoutType next_type;
  int indent;
};

managed struct ImGi_Container {
  int cmd_head_idx;
  int cmd_tail_idx;

  int rect_x;
  int rect_y;
  int rect_w;
  int rect_h;
  
  int body_x;
  int body_y;
  int body_w;
  int body_h;
  
  int content_w;
  int content_h;
  
  int scroll_x;
  int scroll_y;
  
  int zindex;
  bool open;
};



import ImGi_ID _ImGi_hash(String data, ImGi_ID id = 0);

struct ImGi_Context {
  
  import int text_width(FontType font, String str, int len);
  import int text_height(FontType font);
  import void draw_frame(Rect* r, ImGi_Color colorid);
  
  //state
  
  ImGi_Style* style;
  
  ImGi_ID hover;
  ImGi_ID focus;
  
  ImGi_ID last_id;
  Rect* last_rect;
  int last_zindex;
  
  bool updated_focus;
  int frame;
  
  ImGi_Container* hover_root;
  ImGi_Container* next_hover_root;
  ImGi_Container* scroll_target;
  
  String number_edit_buf;
  ImGi_ID number_edit;
  
  // stacks
  ImGi_Cmd* stk_cmd_items[IMGI_COMMANDLIST_SIZE];
  int stk_cmd_index;
  import void  stk_cmd_push(ImGi_Cmd *cmd);
  import ImGi_Cmd*  stk_cmd_pop();
  
  ImGi_Container* stk_root_items[IMGI_ROOTLIST_SIZE];
  int stk_root_index;
  import void            stk_root_push(ImGi_Container *root);
  import ImGi_Container* stk_root_pop();
  
  ImGi_Container* stk_container_items[IMGI_CONTAINERSTACK_SIZE];
  int stk_container_index;
  import void            stk_container_push(ImGi_Container *container);
  import ImGi_Container* stk_container_pop();
  
  Rect* stk_clip_items[IMGI_CLIPSTACK_SIZE];
  int stk_clip_index;
  import void  stk_clip_push(Rect *container);
  import Rect* stk_clip_pop();
  
  ImGi_ID stk_id_items[IMGI_IDSTACK_SIZE];
  int stk_id_index;
  import void    stk_id_push(ImGi_ID id);
  import ImGi_ID stk_id_pop();
  
  ImGi_Layout* stk_layout_items[IMGI_LAYOUTSTACK_SIZE];
  int stk_layout_index;
  import void         stk_layout_push(ImGi_Layout* layout);
  import ImGi_Layout* stk_layout_pop();
  
  // auxiliary stack methods
  import Rect* get_clip_rect();
  
  /* retained state pools */  
  int container_pool_size;
  ImGi_PollItem* container_pool[IMGI_CONTAINERPOOL_SIZE];
  
  int treenode_pool_size;
  ImGi_PollItem* treenode_pool[IMGI_TREENODEPOOL_SIZE];
  
  ImGi_Container* containers[IMGI_CONTAINERPOOL_SIZE];
  
  /* input state */
  int mouse_pos_x;
  int mouse_pos_y;
   
  int last_mouse_pos_x;
  int last_mouse_pos_y;
  
  int mouse_delta_x;
  int mouse_delta_y;
  
  int scroll_delta_x;
  int scroll_delta_y;
  
  ImGi_Mouse_Button mouse_down;
  ImGi_Mouse_Button mouse_pressed;
  
  int key_down;
  int key_pressed;
  
  String input_text;
  int previous_command_hash;
  
  
  // config options
  int _cfg_skipframes;
  
  // drawing methods
  
    
  // methods  
  import void _stk_root_swap(int p1, int p2);
  import int _stk_root_partition(int lo, int hi);
  import void _stk_root_quicksort(int lo, int hi);
  import void stk_root_qsort(int size);
  
  import void bring_to_front(ImGi_Container* cnt);
  
  int _next_command_idx;
  import ImGi_Cmd* next_command(ImGi_Cmd* cmd);
    
  import void Init();
  import void Begin();
  import void End();
  
  import ImGi_ID GetID(String data = 0);
  import void PushID(String data);
  import void PopID();
  
  import int container_pool_init(int id);
  import int container_pool_get(int id);
  import void container_pool_update(int idx);
  
  import int treenode_pool_init(int id);
  import int treenode_pool_get(int id);
  import void treenode_pool_update(int idx);
  
  import String TextBox_raw(ImGi_Result* res, String buf, int bufsz, ImGi_ID id, Rect* r, ImGi_Opt opt);
  import ImGi_Res number_textbox(ImGi_Real* value, Rect* r, ImGi_ID id, const string format);
  
  import void SetFocus(ImGi_ID id);
  
  // Layout  
  import void LayoutRow(int items, int widths[], int height = 0);
  
  // Controls  
  import ImGi_Res BeginWindow(String title, int x, int y, int width, int height, ImGi_Opt opt = 0);
  import void EndWindow();
   
  import void OpenPopup(String name);
  import ImGi_Res BeginPopup(String name);
  import void EndPopup();
  
  import void Text(String text);
  import String TextBox(String label, ImGi_Result* res, String buf, int bufsz, ImGi_Opt opt = 0);
  import ImGi_Res Number(String label, ImGi_Real* value, const string fmt, float step = 0, ImGi_Opt opt = 0);
  import ImGi_Res Slider(String label, ImGi_Real* value, float low, float high, float step = 0, ImGi_Opt opt = 0);
  import void Label(String label);
  import ImGi_Res Button(String label, ImGi_Icon icon = 0, ImGi_Opt opt = eImGi_Opt_AlignCenter);
  import ImGi_Res CheckBox(String label, CheckBoxState* chkst);
};

#endregion PRIVATE_HEADER
// end of private header

//internals
Rect* unclipped_rect;

// math utilities
#region MATH_UTILITIES
int _max(int a, int b)
{
  if(a>b) return a;
  return b;
}

int _min(int a, int b)
{
  if(a<b) return a;
  return b;
}

int _clamp(int v, int min,  int max)
{
  return _min(max, _max(v, min));
}

float _maxf(float a, float b)
{
  if(a>b) return a;
  return b;
}

float _minf(float a, float b)
{
  if(a<b) return a;
  return b;
}

float _clampf(float v, float min, float max)
{
  return _minf(max, _maxf(v, min));
}
#endregion MATH_UTILITIES

// qsort
#region QSORT
void ImGi_Context::_stk_root_swap(int p1, int p2)
{
  ImGi_Container* temp = this.stk_root_items[p1];
  this.stk_root_items[p1] = this.stk_root_items[p2];
  this.stk_root_items[p2] = temp;
}

int ImGi_Context::_stk_root_partition(int lo, int hi)
{
  int pivot = this.stk_root_items[hi].zindex;
  int i = lo;
  int j;
  for (j = lo; j<hi; j++) {
    if(this.stk_root_items[j].zindex < pivot) {
      this._stk_root_swap(i, j);
      i = i + 1;
    }
  }
  this._stk_root_swap(i, j);
  return i;
}

void ImGi_Context::_stk_root_quicksort(int lo, int hi)
{
  if( lo < hi) {
    int p = this._stk_root_partition(lo, hi);
    this._stk_root_quicksort(lo, p-1);
    this._stk_root_quicksort(p+1, hi);
  }
}

void ImGi_Context::stk_root_qsort(int size)
{
  this._stk_root_quicksort(0, size-1);
}
#endregion QSORT

#region KEYBOARD_UTILITIES
bool _IsShiftKeyPressed()
{
  return IsKeyPressed(IMGI_KEY_SHIFT_LEFT) || IsKeyPressed(IMGI_KEY_SHIFT_RIGHT);
}

bool _IsKeycodeNumeric(eKeyCode keycode)
{
  return keycode >= eKey0 && keycode <= eKey9 || keycode == eKeyPeriod;
}
#endregion KEYBOARD_UTILITIES

// assertion check utility
void expect(bool expr) { if(expr == false) AbortGame("Failed assertion!"); }

// stack
#region STACK_BASICS

void StackOfInt::Push(int number)
{
  expect( this.index < MAX_STACK_SIZE );
  this.items[this.index] = number;
  this.index++;
}

int StackOfInt::Pop()
{
  expect(this.index > 0);
  this.index--;
  return this.items[this.index];
}
#endregion STACK_BASICS

// basic ImGi types
#region IMGI_BASIC_TYPES
Point* NewPoint(int x, int y) {
  Point* p = new Point;
  p.x = x;
  p.y = y;
  return p;
}

// <<-- Rect   ///////////////////////////////////////////////////////////

bool _Rect_Overlaps_Point(int r_x, int r_y, int r_w, int r_h, int p_x, int p_y)
{
  return (
    p_x >= r_x &&
    p_x < r_x + r_w &&
    p_y >= r_y &&
    p_y < r_y + r_h
  );
}

int[] _Rect_Intersect(int r1_x, int r1_y, int r1_w, int r1_h,
                      int r2_x, int r2_y, int r2_w, int r2_h)
{
  int x1 = _max(r1_x, r2_x);
  int y1 = _max(r1_y, r2_y);
  int x2 = _min(r1_x + r1_w, r2_x + r2_w);
  int y2 = _min(r1_y + r1_h, r2_y + r2_h);
  if(x2 < x1) x2 = x1;
  if(y2 < y1) y2 = y1;
  int r[] = new int[4];
  r[0] = x1;
  r[1] = y1;
  r[2] = x2-x1;
  r[3] = y2-y1;
  return r;
}

int[] _Rect_Expand(int r_x, int r_y, int r_w, int r_h, int n)
{
  int r[] = new int[4];
  r[0] = r_x - n;
  r[1] = r_y - n;
  r[2] = r_w + n*2;
  r[3] = r_h + n*2;
  return r;
}

static Rect* Rect::Create(int x, int y, int w, int h)
{
  Rect* r = new Rect;
  r.x = x;
  r.y = y;
  r.w = w;
  r.h = h;
  return r;
}

Rect* _Rect_IntersectR1R2(Rect* r1, Rect* r2)
{
  int r[] = _Rect_Intersect(r1.x, r1.y, r1.w, r1.h, r2.x, r2.y, r2.w, r2.h);
  return Rect.Create(r[0], r[1], r[2], r[3]);
}

bool _Rect_Overlaps_P(Rect* r, int p_x, int p_y)
{
  return _Rect_Overlaps_Point(r.x, r.y, r.w, r.h, p_x, p_y);
}

Rect* Rect::Intersect(Rect* r)
{
  return _Rect_IntersectR1R2(this, r);
}

Rect* Rect::Expand(int n)
{
  int r[] = _Rect_Expand(this.x, this.y, this.w, this.h, n);
  return Rect.Create(r[0], r[1], r[2], r[3]);
}

bool Rect::IsOverlappingPoint(Point* p)
{
  return _Rect_Overlaps_P(this, p.x, p.y);
}

bool Rect::IsOverlapping(int x, int y)
{
  return _Rect_Overlaps_P(this, x, y);
}

Rect* Rect::Copy()
{
  Rect* r = new Rect;
  r.x = this.x;
  r.y = this.y;
  r.w = this.w;
  r.h = this.h;
  return r;
}

// Rect -->>   ///////////////////////////////////////////////////////////
#endregion IMGI_BASIC_TYPES

static ImGi_PollItem* ImGi_PollItem::Create(int id, int last_update)
{
  ImGi_PollItem* pi = new ImGi_PollItem;
  pi.id = id;
  pi.last_update = last_update;
  return pi;
}

static ImGi_Style* ImGi_Style::Create()
{
  ImGi_Style* style = new ImGi_Style;
  style.font = 0;
  style.size_x = 68;
  style.size_y = 10;
  style.padding = 5;
  style.spacing = 4;
  style.indent = 24;
  style.title_height = 24;
  style.scrollbar_size = 12;
  style.thumb_size = 8;
  style.colors[eImGi_Col_Text] = 59196;
  style.colors[eImGi_Col_Border] = 6338;
  style.colors[eImGi_Col_WindowBG] = 12710;
  style.colors[eImGi_Col_TitleBG] = 8419;
  style.colors[eImGi_Col_TitleText] = 61277;
  style.colors[eImGi_Col_PanelBG] = COLOR_TRANSPARENT; //64779; /* orange */
  style.colors[eImGi_Col_Button] = 19017;
  style.colors[eImGi_Col_ButtonHover] = 23243;
  style.colors[eImGi_Col_ButtonFocus] = 31630;
  style.colors[eImGi_Col_Base] = 6371;
  style.colors[eImGi_Col_BaseHover] = 10565;
  style.colors[eImGi_Col_BaseFocus] = 12678;
  style.colors[eImGi_Col_ScrollBase] = 12743;
  style.colors[eImGi_Col_ScrollThumb] = 8452;
  return style;
}

#region POOL
// <<-- Pool   ///////////////////////////////////////////////////////////

void ImGi_Context::container_pool_update(int idx)
{
  this.container_pool[idx].last_update = this.frame;
}

int ImGi_Context::container_pool_init(int id)
{
  this.container_pool_size = IMGI_CONTAINERPOOL_SIZE;
  int i;
  int n = -1;
  int f = this.frame;
  for (i = 0; i < this.container_pool_size; i++) {
    if (this.container_pool[i].last_update < f) {
      f = this.container_pool[i].last_update;
      n = i;
    }
  }
  expect(n > -1);
  this.container_pool[n].id = id;
  this.container_pool_update(n);
  return n;
}

int ImGi_Context::container_pool_get(int id)
{
  int i;
  for (i = 0; i < this.container_pool_size; i++) {
    if (this.container_pool[i].id == id) { return i; }
  }
  return -1;
}


void ImGi_Context::treenode_pool_update(int idx)
{
  this.treenode_pool[idx].last_update = this.frame;
}

int ImGi_Context::treenode_pool_init(int id)
{
  this.treenode_pool_size = IMGI_TREENODEPOOL_SIZE;
  int i, n = -1, f = this.frame;
  for (i = 0; i < this.treenode_pool_size; i++) {
    if (this.treenode_pool[i].last_update < f) {
      f = this.treenode_pool[i].last_update;
      n = i;
    }
  }
  expect(n > -1);
  this.treenode_pool[n].id = id;
  this.treenode_pool_update(n);
  return n;
}

int ImGi_Context::treenode_pool_get(int id)
{
  int i;
  for (i = 0; i < this.treenode_pool_size; i++) {
    if (this.treenode_pool[i].id == id) { return i; }
  }
  return -1;
}

// Pool -->>   ///////////////////////////////////////////////////////////
#endregion POOL

#region STACKS
// <<-- Stacks ///////////////////////////////////////////////////////////

  // Cmd Stack

void ImGi_Context::stk_cmd_push(ImGi_Cmd *cmd)
{
  expect( this.stk_cmd_index < IMGI_COMMANDLIST_SIZE );
  this.stk_cmd_items[this.stk_cmd_index] = cmd;
  this.stk_cmd_index++;
}

ImGi_Cmd* ImGi_Context::stk_cmd_pop()
{
  expect(this.stk_cmd_index > 0);
  this.stk_cmd_index--;
  return this.stk_cmd_items[this.stk_cmd_index];
}

  // Root Stack

void ImGi_Context::stk_root_push(ImGi_Container *root)
{
  expect( this.stk_root_index < IMGI_ROOTLIST_SIZE );
  this.stk_root_items[this.stk_root_index] = root;
  this.stk_root_index++;
}

ImGi_Container* ImGi_Context::stk_root_pop()
{
  expect(this.stk_root_index > 0);
  this.stk_root_index--;
  return this.stk_root_items[this.stk_root_index];
}

  // Container Stack

void ImGi_Context::stk_container_push(ImGi_Container* container)
{
  expect( this.stk_container_index < IMGI_CONTAINERSTACK_SIZE );
  this.stk_container_items[this.stk_container_index] = container;
  this.stk_container_index++;
}

ImGi_Container* ImGi_Context::stk_container_pop()
{
  expect(this.stk_container_index > 0);
  this.stk_container_index--;
  return this.stk_container_items[this.stk_container_index];
}

  // Clip Stack

void ImGi_Context::stk_clip_push(Rect* clip)
{
  expect( this.stk_clip_index < IMGI_CLIPSTACK_SIZE );
  this.stk_clip_items[this.stk_clip_index] = clip;
  this.stk_clip_index++;
}

Rect* ImGi_Context::stk_clip_pop()
{
  expect(this.stk_clip_index > 0);
  this.stk_clip_index--;
  return this.stk_clip_items[this.stk_clip_index];
}

  // ID Stack

void ImGi_Context::stk_id_push(ImGi_ID id)
{
  expect( this.stk_id_index < IMGI_IDSTACK_SIZE );
  this.stk_id_items[this.stk_id_index] = id;
  this.stk_id_index++;
}

ImGi_ID ImGi_Context::stk_id_pop()
{
  expect(this.stk_id_index > 0);
  this.stk_id_index--;
  return this.stk_id_items[this.stk_id_index];
}

  // Layout Stack

void ImGi_Context::stk_layout_push(ImGi_Layout* layout)
{
  expect( this.stk_layout_index < IMGI_LAYOUTSTACK_SIZE );
  this.stk_layout_items[this.stk_layout_index] = layout;
  this.stk_layout_index++;
}

ImGi_Layout* ImGi_Context::stk_layout_pop()
{
  expect(this.stk_layout_index > 0);
  this.stk_layout_index--;
  return this.stk_layout_items[this.stk_layout_index];
}

// Stacks -->> ///////////////////////////////////////////////////////////
#endregion STACKS

#region EXTRA_CLIP_STACKS
// <<-- extras clip stack ////////////////////////////////////////////////

Rect* ImGi_Context::get_clip_rect()
{
  expect(this.stk_clip_index > 0);
  return this.stk_clip_items[this.stk_clip_index - 1];
}

int _check_clip(this ImGi_Context*, Rect* r) {
  Rect* cr = this.get_clip_rect();
  if (r.x > cr.x + cr.w || r.x + r.w < cr.x ||
      r.y > cr.y + cr.h || r.y + r.h < cr.y   )
  {
    return eImGi_ClipAll;
  }

  if (r.x >= cr.x && r.x + r.w <= cr.x + cr.w &&
      r.y >= cr.y && r.y + r.h <= cr.y + cr.h )
  {
    return eImGi_ClipNone;
  }

  return eImGi_ClipPart;
}

ImGi_Layout* get_layout(this ImGi_Context*)
{
  return this.stk_layout_items[this.stk_layout_index-1];
}

ImGi_Container* get_current_container(this ImGi_Context*)
{
  expect(this.stk_container_index > 0);
  return this.stk_container_items[this.stk_container_index -1];
}

void pop_container(this ImGi_Context*)
{
  ImGi_Container* cnt = this.get_current_container();
  ImGi_Layout* layout = this.get_layout();
  cnt.content_w = layout.max_x - layout.body_x;
  cnt.content_h = layout.max_y - layout.body_y;
  /* pop container, layout and id */
  this.stk_container_pop();
  this.stk_layout_pop();
  this.stk_id_pop();
}

void ImGi_Context::bring_to_front(ImGi_Container *cnt) {
  this.last_zindex++;
  cnt.zindex = this.last_zindex;
}

ImGi_Container* get_container(this ImGi_Context*, ImGi_ID id, ImGi_Opt opt)
{
  ImGi_Container* cnt;
  /* try to get existing container from pool */
  int idx = this.container_pool_get(id);
  if(idx >= 0)
  {
    if(this.containers[idx].open || !(opt & eImGi_Opt_Closed))
    {
      this.container_pool_update(idx);
    }
    return this.containers[idx];
  }

  if(opt & eImGi_Opt_Closed) return null;

  /* container not found in pool: init new container */
  idx = this.container_pool_init(id);
  cnt = this.containers[idx];
  cnt.cmd_head_idx = -1; // guarantee head and tail jumps are uninitialized
  cnt.cmd_tail_idx = -1;
  cnt.open = true;
  this.bring_to_front(cnt);
  return cnt;
}

void ImGi_Context::LayoutRow(int items, int widths[], int height) {
  ImGi_Layout* layout = this.get_layout();
  if (widths != null) {
    expect(items <= IMGI_MAX_WIDTHS);
    for(int i=0; i<items; i++)
    {
      layout.widths[i] = widths[i];
    }
  }
  layout.items = items;
  layout.pos_x = layout.indent;
  layout.pos_y = layout.next_row;
  layout.size_y = height;
  layout.item_index = 0;
}

void push_layout(this ImGi_Context*, Rect* body, Point* scroll)
{
  ImGi_Layout* layout = new ImGi_Layout;
  int width[];
  width = new int[1];
  width[0] = 0;
  layout.body_x = body.x - scroll.x;
  layout.body_y = body.y - scroll.y;
  layout.body_w = body.w;
  layout.body_h = body.h;

  layout.max_x = -UNCLIPPED_RECT_W;
  layout.max_y = -UNCLIPPED_RECT_H;

  this.stk_layout_push(layout);
  this.LayoutRow(1, width, 0);
}

// extras clip stack -->> ////////////////////////////////////////////////
#endregion EXTRA_CLIP_STACKS


int ImGi_Context::text_width(FontType font, String str, int len)
{
  return GetTextWidth(str, font);
}

int ImGi_Context::text_height(FontType font)
{
  return GetFontHeight(font);
}


// Context_Basics
void ImGi_Context::Init()
{
  int i;
  /*
  for(i=0; i<IMGI_COMMANDLIST_SIZE; i++)
  {
    this.stk_cmd_items[i] = new ImGi_Cmd;
  }
  for(i=0; i<IMGI_ROOTLIST_SIZE; i++)
  {
    this.stk_root_items[i] = new ImGi_Container;
  }
  for(i=0; i<IMGI_CONTAINERSTACK_SIZE; i++)
  {
    this.stk_container_items[i] = new ImGi_Container;
  }
  for(i=0; i<IMGI_CLIPSTACK_SIZE; i++)
  {
    this.stk_clip_items[i] = new Rect;
  }
  for(i=0; i<IMGI_LAYOUTSTACK_SIZE; i++)
  {
    this.stk_layout_items[i] = new ImGi_Layout;
  }*/

  for(i=0; i<IMGI_CONTAINERPOOL_SIZE; i++)
  {
    this.containers[i] = new ImGi_Container;
  }
  for(i=0; i<IMGI_CONTAINERPOOL_SIZE; i++)
  {
    this.container_pool[i] = new ImGi_PollItem;
    this.container_pool[i].last_update = -1;
  }
  for(i=0; i<IMGI_TREENODEPOOL_SIZE; i++)
  {
    this.treenode_pool[i] = new ImGi_PollItem;
    this.treenode_pool[i].last_update = -1;
  }

  this.style = ImGi_Style.Create();
}

void ImGi_Context::Begin()
{
  this.stk_cmd_index = 0;
  this.stk_root_index = 0;
  this.scroll_target = null;
  this.hover_root = this.next_hover_root;
  this.next_hover_root = null;
  this.mouse_delta_x = this.mouse_pos_x - this.last_mouse_pos_x;
  this.mouse_delta_y = this.mouse_pos_y - this.last_mouse_pos_y;
  this.frame++;
}

int _compare_zindex(ImGi_Container* a, ImGi_Container* b)
{
  return a.zindex - b.zindex;
}

void ImGi_Context::End()
{
  int i, n;
  /*check stacks*/
  expect(this.stk_container_index == 0); // are you here because you called ImGi.End() twice in a frame?
  expect(this.stk_clip_index == 0);
  expect(this.stk_id_index == 0);
  expect(this.stk_layout_index == 0);

  /*handle scroll input*/
  if(this.scroll_target)
  {
    this.scroll_target.scroll_x += this.scroll_delta_x;
    this.scroll_target.scroll_y += this.scroll_delta_y;
  }

  /* unset focus if focus id was not touched this frame */
  if (!this.updated_focus) { this.focus = 0; }
  this.updated_focus = false;

  /* bring hover root to front if mouse was pressed */
  if (this.mouse_pressed && this.next_hover_root != null &&
      this.next_hover_root.zindex < this.last_zindex &&
      this.next_hover_root.zindex >= 0 )
  {
    this.bring_to_front(this.next_hover_root);
  }

  /* reset input state */
  this.key_pressed = 0;
  if(this.input_text == null || this.input_text.Length>0) this.input_text = "";
  this.mouse_pressed = 0;
  this.scroll_delta_x = 0;
  this.scroll_delta_y = 0;
  this.last_mouse_pos_x = this.mouse_pos_x;
  this.last_mouse_pos_y = this.mouse_pos_y;

  /* sort root containers by zindex */
  n = this.stk_root_index;
  this.stk_root_qsort(n);

  /* set root container jump commands */
  for (i=0; i<n; i++)
  {
    ImGi_Container* cnt = this.stk_root_items[i];
    /* if this is the first container then make the first command jump to it.
    ** otherwise set the previous container's tail to jump to this one */
    if(i == 0)
    {
      this.stk_cmd_items[0].dst_idx = cnt.cmd_head_idx + 1;
      this.stk_cmd_items[0].type = eImGi_CmdJump;
    }
    else
    {
      int tail = this.stk_root_items[i-1].cmd_tail_idx;
      this.stk_cmd_items[tail].dst_idx = cnt.cmd_head_idx+1;
    }
    /* make the last container's tail jump to the end of command list */
    if(i == n - 1)
    {
      int tail = cnt.cmd_tail_idx;
//      cnt.cmd_tail_idx = this.stk_cmd_index;
      this.stk_cmd_items[tail].dst_idx = this.stk_cmd_index;
    }
  }
}

void ImGi_Context::SetFocus(ImGi_ID id)
{
  this.focus = id;
  this.updated_focus = true;
}

// 32bit fnv-1a hash
// https://en.wikipedia.org/wiki/Fowler%E2%80%93Noll%E2%80%93Vo_hash_function
#define HASH_INITIAL -18652613
// (uint32 2166136261) -> int32 -18652613

ImGi_ID _ImGi_hash(String data, ImGi_ID id) {
  for(int i=0; i<data.Length; i++){
    id = (id ^ data.Chars[i])* 16777619;
  }
  return id;
}

ImGi_ID ImGi_Context::GetID(String data)
{
  if(String.IsNullOrEmpty(data)) {
    return this.last_id;
  }

  int idx = this.stk_id_index;
  ImGi_ID res;
  if(idx > 0) res = this.stk_id_items[idx-1];
  else res = HASH_INITIAL;
  res = _ImGi_hash(data, res);
  this.last_id = res;
  return res;
}

void ImGi_Context::PushID(String data)
{
  this.stk_id_push(this.GetID(data));
}

void ImGi_Context::PopID()
{
  this.stk_id_pop();
}

void push_clip_rect(this ImGi_Context*, Rect* rect)
{
  Rect* last = this.get_clip_rect();
  this.stk_clip_push(rect.Intersect(last));
}

void pop_clip_rect(this ImGi_Context*)
{
  this.stk_clip_pop();
}

//


// <<-- Cmd  /////////////////////////////////////////////////////////////

int push_jump(this ImGi_Context*,  int dst_idx)
{
  ImGi_Cmd* cmd = new ImGi_Cmd;
  cmd.type = eImGi_CmdJump;
  cmd.dst_idx = dst_idx;

  this.stk_cmd_push(cmd);
  return this.stk_cmd_index-1;
}

void set_clip(this ImGi_Context*, Rect* r)
{
  ImGi_Cmd* cmd = new ImGi_Cmd;
  cmd.type = eImGi_CmdClip;
  cmd.x = r.x;
  cmd.y = r.y;
  cmd.w = r.w;
  cmd.h = r.h;

  this.stk_cmd_push(cmd);
}

void draw_rect(this ImGi_Context*, Rect* rect, int color)
{
  Rect* r = rect.Intersect(this.get_clip_rect());

  if(r.w > 0 && r.h > 0){
    ImGi_Cmd* cmd = new ImGi_Cmd;
    cmd.type = eImGi_CmdRect;
    cmd.x = r.x;
    cmd.y = r.y;
    cmd.w = r.w;
    cmd.h = r.h;
    cmd.color = color;
    this.stk_cmd_push(cmd);
  }
}

void draw_box(this ImGi_Context*, Rect* r, int color)
{
  this.draw_rect(Rect.Create(r.x +1     , r.y        , r.w - 2 , 1  ), color);
  this.draw_rect(Rect.Create(r.x +1     , r.y +r.h -1, r.w - 2 , 1  ), color);
  this.draw_rect(Rect.Create(r.x        , r.y        , 1       , r.h), color);
  this.draw_rect(Rect.Create(r.x +r.w -1, r.y        , 1       , r.h), color);
  
  
//  this.draw_rect(Rect.Create(r.x +1     , r.y        , r.w - 2 , 1  ), 64235 /* red */);
//  this.draw_rect(Rect.Create(r.x +1     , r.y +r.h -1, r.w - 2 , 1  ), 24395 /* green */);
//  this.draw_rect(Rect.Create(r.x        , r.y        , 1       , r.h), 23231 /* blue */);
//  this.draw_rect(Rect.Create(r.x +r.w -1, r.y        , 1       , r.h), 63839 /* pink */);
}

void ImGi_Context::draw_frame(Rect* r, ImGi_Color colorid)
{
  this.draw_rect(r, this.style.colors[colorid]);
  if(colorid == eImGi_Col_ScrollBase  ||
     colorid == eImGi_Col_ScrollThumb ||
     colorid == eImGi_Col_TitleBG) return;

  /* draw border */
  if(this.style.colors[eImGi_Col_Border] != COLOR_TRANSPARENT)
  {
    this.draw_box(r.Expand(1), this.style.colors[eImGi_Col_Border]);
  }
}

void draw_text(this ImGi_Context*, Point* pos, int color, FontType font, String str)
{
  Rect* rect = Rect.Create(pos.x, pos.y, GetTextWidth(str, font), this.text_height(font));

  ImGi_ClipType clipped = this._check_clip(rect);
  if(clipped == eImGi_ClipAll) return;
  if(clipped == eImGi_ClipPart) {
    this.set_clip(this.get_clip_rect());
  }
  /* add command */
  ImGi_Cmd* cmd = new ImGi_Cmd;
  cmd.type = eImGi_CmdText;
  int len = _min(str.Length, MAX_TEXT_CMD_STR_SIZE-1);
  for(int i=0; i<len; i++)
  {
    cmd.str[i]=str.Chars[i];
  }
  cmd.str[len]=0;
  cmd.x = pos.x;
  cmd.y = pos.y;
  cmd.color = color;
  cmd.font = font;
  this.stk_cmd_push(cmd);

  /* reset clipping if it was set */
  if (clipped) this.set_clip(unclipped_rect);
}

void draw_icon(this ImGi_Context*, ImGi_Icon icon, Rect* r, int color)
{
  ImGi_ClipType clipped = this._check_clip(r);
  if (clipped == eImGi_ClipAll ) return;
  if(clipped == eImGi_ClipPart) {
    this.set_clip(this.get_clip_rect());
  }
  /* do icon command */
  ImGi_Cmd* cmd = new ImGi_Cmd;
  cmd.type = eImGi_CmdIcon;
  cmd.icon = icon;
  cmd.x = r.x;
  cmd.y = r.y;
  cmd.w = r.w;
  cmd.h = r.h;
  cmd.color = color;
  this.stk_cmd_push(cmd);

  /* reset clipping if it was set */
  if (clipped) this.set_clip(unclipped_rect);
}

// Cmd -->>  /////////////////////////////////////////////////////////////

// <<-- Layout ///////////////////////////////////////////////////////////

Rect* layout_next(this ImGi_Context*)
{
  ImGi_Layout *layout = this.get_layout();
  ImGi_Style *style = this.style;
  Rect* res = new Rect;

  if (layout.next_type) {
    /* handle rect set by `layout_set_next` */
    int type = layout.next_type;
    layout.next_type = 0;
    res.x = layout.next_x;
    res.y = layout.next_y;
    res.w = layout.next_w;
    res.h = layout.next_h;
    if (type == eImGi_Lay_Absolute)
    {
      this.last_rect = res;
      return res;
    }

  } else {
    /* handle next row */
    if (layout.item_index == layout.items)
    {
      this.LayoutRow(layout.items, null, layout.size_y);
    }

    /* position */
    res.x = layout.pos_x;
    res.y = layout.pos_y;

    /* size */
    if(layout.items > 0) res.w = layout.widths[layout.item_index]; // use width from LayoutRow
    else res.w = layout.size_x; // no layout row set
    res.h = layout.size_y;

    if (res.w == 0) { res.w = style.size_x + style.padding * 2; }
    if (res.h == 0) { res.h = style.size_y + style.padding * 2; }
    if (res.w <  0) { res.w += layout.body_w - res.x + 1; }
    if (res.h <  0) { res.h += layout.body_h - res.y + 1; }

    layout.item_index++;
  }

    /* update position */
  layout.pos_x += res.w + style.spacing;
  layout.next_row = _max(layout.next_row, res.y + res.h + style.spacing);

  /* apply body offset */
  res.x += layout.body_x;
  res.y += layout.body_y;

  /* update max position */
  layout.max_x = _max(layout.max_x, res.x + res.w);
  layout.max_y = _max(layout.max_y, res.y + res.h);

  this.last_rect = res;
  return res;
}

void layout_begin_column(this ImGi_Context*)
{
  Rect* nxt_rect = this.layout_next();
  Point* p = NewPoint(0, 0);
  this.push_layout(nxt_rect, p);
}

void layout_end_column(this ImGi_Context*)
{
  ImGi_Layout* a;
  ImGi_Layout* b;
  b = this.get_layout();
  this.stk_layout_pop();

  /* inherit position/next_row/max from child layout if they are greater */
  a = this.get_layout();
  a.pos_x = _max(a.pos_x, b.pos_x + b.body_x - a.body_x);
  a.next_row = _max(a.next_row,  b.next_row + b.body_y - a.body_y);
  a.max_x = _max(a.max_x, b.max_x);
  a.max_y = _max(a.max_y, b.max_y);
}

void layout_width(this ImGi_Context*, int width)
{
  ImGi_Layout* layout = this.get_layout();
  layout.size_x = width;
}

void layout_height(this ImGi_Context*, int height)
{
  ImGi_Layout* layout = this.get_layout();
  layout.size_y = height;
}

void layout_set_next(this ImGi_Context*, Rect* r, bool relative)
{
  ImGi_Layout* layout = this.get_layout();
  layout.next_x = r.x;
  layout.next_y = r.y;
  layout.next_w = r.w;
  layout.next_h = r.h;
  if(relative) layout.next_type = eImGi_Lay_Relative;
  else layout.next_type = eImGi_Lay_Absolute;
}

// Layout -->> ///////////////////////////////////////////////////////////

// <<-- Controls /////////////////////////////////////////////////////////

bool in_hover_root(this ImGi_Context*)
{
  int i = this.stk_container_index;
  while(i)
  {
    i=i-1;
    if(this.stk_container_items[i] == this.hover_root) return true;
    /* only root containers have their `head` field set; stop searching if we've
    ** reached the current root container */
    if(this.stk_container_items[i].cmd_head_idx > -1) break;
  }
  return false;
}

void draw_control_frame(this ImGi_Context*, ImGi_ID id, Rect* r, ImGi_Color colorid, ImGi_Opt opt)
{
  if(opt & eImGi_Opt_NoFrame) return;
  if(this.focus == id) colorid+=2;
  else if(this.hover == id) colorid+=1;

  this.draw_frame(r, colorid);
}

void draw_control_text(this ImGi_Context*, String str, Rect* r, ImGi_Color colorid, ImGi_Opt opt)
{
  Point* pos = new Point;
  FontType font = this.style.font;
  int tw = GetTextWidth(str, font);
  this.push_clip_rect(r);
  pos.y = r.y + (r.h - GetFontHeight(font))/2;
  if( opt & eImGi_Opt_AlignCenter)
  {
    pos.x = r.x + (r.w - tw)/2;
  }
  else if( opt & eImGi_Opt_AlignRight)
  {
    pos.x = r.x + r.w - tw - this.style.padding;
  }
  else
  {
    pos.x = r.x + this.style.padding;
  }

  this.draw_text(pos, this.style.colors[colorid], font, str);
  this.pop_clip_rect();
}

bool mouse_over(this ImGi_Context*, Rect* r)
{
  Rect* c = this.get_clip_rect();
  bool movr_r = _Rect_Overlaps_Point(r.x, r.y, r.w, r.h, this.mouse_pos_x, this.mouse_pos_y);
  bool movr_c = _Rect_Overlaps_Point(c.x, c.y, c.w, c.h, this.mouse_pos_x, this.mouse_pos_y);
  return movr_r && movr_c && this.in_hover_root();
}


void update_control(this ImGi_Context*, ImGi_ID id, Rect* r, ImGi_Opt opt)
{
  bool mouseover = this.mouse_over(r);

  if(this.focus == id) this.updated_focus = true;
  if(opt & eImGi_Opt_NoInteract) return;
  if(mouseover && !(this.mouse_down)) this.hover = id;

  if(this.focus == id)
  {
    if(this.mouse_pressed && !mouseover) { this.SetFocus(0); }
    if(!(this.mouse_down) && !(opt & eImGi_Opt_HoldFocus))  {  this.SetFocus(0);  }
  }

  if(this.hover == id)
  {
    if(this.mouse_pressed)
    {
      this.SetFocus(id);
    }
    else if(!mouseover)
    {
      this.hover = 0;
    }
  }
}

void ImGi_Context::Text(String text)
{
  int start_i, end_i, p_i;
  int len = text.Length;
  int width[];
  width = new int[1];
  width[0] = -1;
  FontType font = this.style.font;
  int color = this.style.colors[eImGi_Col_Text];
  this.layout_begin_column();
  this.LayoutRow(1, width, GetFontHeight(font));

  do {
    Rect* r = this.layout_next();
    int w = 0;
    end_i = p_i;
    start_i = end_i;
    do {
      int word_i = p_i;
      /* advances p_i to the end of the word */
      while(p_i <= len && 
            text.Chars[p_i] != eKeySpace && 
            text.Chars[p_i] != eKeyCtrlJ) p_i++;
      //AbortGame(String.Format("%s p_i=%d word_i=%d\n\n",text,p_i, word_i));
      w += GetTextWidth(text.Substring(word_i, p_i-word_i), font);
      if(w > r.w && end_i != start_i) break;
      if(p_i < len-1) {
        w += GetTextWidth(text.Substring(p_i, 1), font);
      }
      end_i = p_i;
      p_i++;

    } while(end_i <= len && text.Chars[end_i] != eKeyCtrlJ /* '\n' */);

    this.draw_text(NewPoint(r.x, r.y), color, font, text.Substring(start_i, end_i-start_i));
    p_i = end_i + 1;

  } while(end_i <= len);

  this.layout_end_column();
}

void ImGi_Context::Label(String label)
{
  this.draw_control_text(label, this.layout_next(), eImGi_Col_Text, 0);
}

ImGi_Res ImGi_Context::Button(String label, ImGi_Icon icon, ImGi_Opt opt)
{
  ImGi_Res res = eImGi_Res_None;
  ImGi_ID id;
  if(String.IsNullOrEmpty(label)) {
    id = this.GetID(String.Format("%d", icon));
  }
  else
  {
    id = this.GetID(label);
  }
  Rect* r = this.layout_next();
  this.update_control(id, r, opt);
  /* handle click */
  if(this.mouse_pressed == eImGi_Mouse_Left && this.focus == id)
  {
    res |= eImGi_Res_Submit;
  }
  /* draw */
  this.draw_control_frame(id, r, eImGi_Col_Button, opt);
  if(!String.IsNullOrEmpty(label)) this.draw_control_text(label, r, eImGi_Col_Text, opt);
  if(icon) this.draw_icon(icon, r, this.style.colors[eImGi_Col_Text]);
  return res;
}

ImGi_Res ImGi_Context::CheckBox(String label, CheckBoxState* chkst)
{
  ImGi_Res res = eImGi_Res_None;
  ImGi_ID id = this.GetID(label); //this.GetID(String.Format("%d",chkst.state));
  Rect* r = this.layout_next();
  Rect* box = Rect.Create(r.x, r.y, r.h, r.h);
  this.update_control(id, r, 0);
  /* handle click */
  if(this.mouse_pressed == eImGi_Mouse_Left && this.focus == id)
  {
    res |= eImGi_Res_Change;
    chkst.state = !chkst.state;
  }
  /* draw */
  this.draw_control_frame(id, box, eImGi_Col_Base, 0);
  if(chkst.state)
  {
    this.draw_icon(eImGi_Icon_Check, box, this.style.colors[eImGi_Col_Text]);
  }

  r = Rect.Create(r.x + box.w, r.y, r.w - box.w, r.h);
  this.draw_control_text(label, r, eImGi_Col_Text, 0);
  return res;
}

String ImGi_Context::TextBox_raw(ImGi_Result* res, String buf, int bufsz, ImGi_ID id, Rect* r, ImGi_Opt opt)
{
  if(res == null) res = new ImGi_Result;
  res.state = eImGi_Res_None;
  this.update_control(id, r, opt | eImGi_Opt_HoldFocus);
  
  if(this.focus == id)
  {
    /* handle text input */
    int len = buf.Length;
    int n = _min(bufsz - len - 1,  this.input_text.Length);
    if(n > 0)
    {
      buf = buf.Append(this.input_text.Truncate(n));
      res.state = res.state | eImGi_Res_Change;
    }
    /* handle backspace */
    if(this.key_pressed == eKeyBackspace && len > 0)
    {
      /* skip utf-8 continuation bytes */
      while(true) {
        len = len - 1;
        if(!((buf.Chars[len] & 192) == 128)) break;
      }
      buf = buf.Truncate(len);
      res.state = res.state | eImGi_Res_Change;
    }
    /* handle return */
    if(this.key_pressed == eKeyReturn)
    {
      this.SetFocus(0);
      res.state = res.state | eImGi_Res_Submit;
    }
  } 
  
  /* draw */
  this.draw_control_frame(id, r, eImGi_Col_Base, opt);
  if(this.focus == id)
  {
    int color = this.style.colors[eImGi_Col_Text];
    int font = this.style.font;
    int textw = this.text_width(font, buf, -1);
    int texth = this.text_height(font);
    int ofx = r.w - this.style.padding - textw - 1;
    int textx = r.x + _min(ofx, this.style.padding);
    int texty = r.y + (r.h - texth)/2;
    this.push_clip_rect(r);
    this.draw_text(NewPoint(textx, texty), color, font, buf);
    this.draw_rect(Rect.Create(textx+textw, texty, 1, texth), color);
    this.pop_clip_rect();
  }
  else
  {
    this.draw_control_text(buf, r, eImGi_Col_Text, opt);  
  }
  
  return buf;
}

ImGi_Res ImGi_Context::number_textbox(ImGi_Real* value, Rect* r, ImGi_ID id, const string format)
{
  ImGi_Result* res = new ImGi_Result;
  
  if(this.mouse_pressed == eImGi_Mouse_Left && _IsShiftKeyPressed() && 
     this.hover == id)
  {
    this.number_edit = id;
    this.number_edit_buf = String.Format(format,value.value);
  }
  if(this.number_edit == id)
  {
    this.number_edit_buf = this.TextBox_raw(res, this.number_edit_buf, 16, id, r, 0);
    if(res.state & eImGi_Res_Submit || this.focus != id)
    {
      value.value = this.number_edit_buf.AsFloat;
      this.number_edit = 0;
    } else {
      return eImGi_Res_Active;
    }
  }
  
  return eImGi_Res_None;
}

String ImGi_Context::TextBox(String label, ImGi_Result* res, String buf, int bufsz, ImGi_Opt opt)
{
  ImGi_ID id = this.GetID(label);
  Rect* r = this.layout_next();
  return this.TextBox_raw(res, buf, bufsz, id, r, opt);  
}

ImGi_Res ImGi_Context::Slider(String label, ImGi_Real* value, float low, float high, float step, ImGi_Opt opt)
{
  Rect* thumb;
  int x, w;
  ImGi_Res res = eImGi_Res_None;
  float last = value.value;
  float v = value.value;

  ImGi_ID id = this.GetID(label);
  Rect* base = this.layout_next();
  
  /* handle text input mode */
  if(this.number_textbox(value, base, id, IMGI_SLIDER_FMT)) return res;
  
  /* handle normal mode */
  this.update_control(id, base, opt);
  
  /* handle input */
  if(this.focus == id && (this.mouse_down | this.mouse_pressed) == eImGi_Mouse_Left)
  {
    v = low + IntToFloat(this.mouse_pos_x - base.x) * (high - low) / IntToFloat(base.w);
    if(step != 0.0) {
      v = (((v + step/2.0)/step)) * step;
    }
  }
  /* clamp and store value, update res */
  v = _clampf(v, low, high);
  value.value = v;
  if(last != v) { res = res | eImGi_Res_Change; }
  
  /* draw base */
  this.draw_control_frame(id, base, eImGi_Col_Base, opt);
  /* draw thumb */
  w = this.style.thumb_size;
  x = FloatToInt((v - low) * IntToFloat(base.w -  w) / (high - low));
  thumb = Rect.Create(base.x + x,  base.y,  w, base.h);
  this.draw_control_frame(id, thumb, eImGi_Col_Button, opt);
  /* draw text  */
  this.draw_control_text(String.Format(IMGI_SLIDER_FMT, v), base, eImGi_Col_Text, opt);
  
  return res;
}

ImGi_Res ImGi_Context::Number(String label, ImGi_Real* value, const string format, float step, ImGi_Opt opt)
{
  ImGi_Res res = eImGi_Res_None;
  ImGi_ID id = this.GetID(label);
  Rect* base = this.layout_next();
  float last = value.value;
  
  
  /* handle text input mode */
  if(this.number_textbox(value, base, id, format)) return res;
  
  /* handle normal mode */
  this.update_control(id, base, opt);
  
  /* handle input */
  if(this.focus == id && (this.mouse_down) == eImGi_Mouse_Left)
  {
    value.value = value.value + IntToFloat(this.mouse_delta_x) * step;
  }
  
  /* set flag if value changed */
  if(value.value != last) { res = res | eImGi_Res_Change; }
  
  /* draw base */
  this.draw_control_frame(id, base, eImGi_Col_Base, opt);
  /* draw text  */
  this.draw_control_text(String.Format(format, value.value), base, eImGi_Col_Text, opt);
}

void scrollbars(this ImGi_Context*, ImGi_Container* cnt, Rect* body)
{
  int sz = this.style.scrollbar_size;
  Point* cs = NewPoint(cnt.content_w, cnt.content_h);
  cs.x += this.style.padding * 2;
  cs.y += this.style.padding * 2;
  this.push_clip_rect(body);
  /* resize body to make room for scrollbars */
  if(cs.y > cnt.body_h) body.w -= sz;
  if(cs.x > cnt.body_w) body.h -= sz;

  /* to create a horizontal or vertical scrollbar almost-identical code is
  ** used; only the references to `x|y` `w|h` need to be switched */
  Rect* b = body;
  {
    int maxscroll = cs.y - b.h;

    if(maxscroll > 0 && b.h > 0)
    {
      Rect* base;
      Rect* thumb;
      ImGi_ID id = this.GetID("!yscrollbary");

      /* get sizing / positioning */
      base = Rect.Create(b.x+b.w, b.y, this.style.scrollbar_size, b.h);

      /* handle input */
      this.update_control(id, base, 0);
      if( this.focus == id && this.mouse_down == eImGi_Mouse_Left)
      {
        cnt.scroll_y += this.mouse_delta_y * cs.y / base.h;
      }
      /* clamp scroll to limits */
      cnt.scroll_y = _clamp(cnt.scroll_y,  0, maxscroll);

      /* draw base and thumb */
      this.draw_frame(base, eImGi_Col_ScrollBase);
      thumb = base.Copy();
      thumb.h = _max(this.style.thumb_size, base.h*b.h /cs.y);
      thumb.y += cnt.scroll_y * (base.h - thumb.h) / maxscroll;
      this.draw_frame(thumb, eImGi_Col_ScrollThumb);

      /* set this as the scroll_target (will get scrolled on mousewheel) */
      /* if the mouse is over it */
      if( this.mouse_over(b)) this.scroll_target = cnt;
    }
    else
    {
      cnt.scroll_y = 0;
    }
  }
  {
    int maxscroll = cs.x - b.w;

    if(maxscroll > 0 && b.w > 0)
    {
      Rect* base;
      Rect* thumb;
      ImGi_ID id = this.GetID("!xscrollbarx");

      /* get sizing / positioning */
      base = Rect.Create(b.x, b.y+b.h, b.w, this.style.scrollbar_size);

      /* handle input */
      this.update_control(id, base, 0);
      if( this.focus == id && this.mouse_down == eImGi_Mouse_Left)
      {
        cnt.scroll_x += this.mouse_delta_x * cs.x / base.w;
      }
      /* clamp scroll to limits */
      cnt.scroll_x = _clamp(cnt.scroll_x,  0, maxscroll);

      /* draw base and thumb */
      this.draw_frame(base, eImGi_Col_ScrollBase);
      thumb = base.Copy();
      thumb.w = _max(this.style.thumb_size, base.w*b.w /cs.x);
      thumb.x += cnt.scroll_x * (base.w - thumb.w) / maxscroll;
      this.draw_frame(thumb, eImGi_Col_ScrollThumb);

      /* set this as the scroll_target (will get scrolled on mousewheel) */
      /* if the mouse is over it */
      if( this.mouse_over(b)) this.scroll_target = cnt;
    }
    else
    {
      cnt.scroll_x = 0;
    }
  }

  this.pop_clip_rect();
}

void push_container_body(this ImGi_Context*, ImGi_Container* cnt, Rect* body, ImGi_Opt opt)
{
  if(!(opt & eImGi_Opt_NoScroll))
  {
    this.scrollbars(cnt, body);
  }
  this.push_layout(body.Expand(-this.style.padding), NewPoint(cnt.scroll_x, cnt.scroll_y));
  cnt.body_x = body.x;
  cnt.body_y = body.y;
  cnt.body_w = body.w;
  cnt.body_h = body.h;
}

void begin_root_container(this ImGi_Context*, ImGi_Container* cnt)
{
  this.stk_container_push(cnt);
  /* push container to roots list and push head command */
  this.stk_root_push(cnt);
  cnt.cmd_head_idx = this.push_jump(-1);
  /* set as hover root if the mouse is overlapping this container and it has a
  ** higher zindex than the current hover root */
  if(_Rect_Overlaps_Point(cnt.rect_x, cnt.rect_y, cnt.rect_w, cnt.rect_h,
     this.mouse_pos_x, this.mouse_pos_y) &&
     (this.next_hover_root == null || cnt.zindex > this.next_hover_root.zindex)
  ) {
    this.next_hover_root = cnt;
  }
  /* clipping is reset here in case a root-container is made within
  ** another root-containers's begin/end block; this prevents the inner
  ** root-container being clipped to the outer */
  this.stk_clip_push(unclipped_rect);
}

void end_root_container(this ImGi_Context*)
{
  /* push tail 'goto' jump command and set head 'skip' command. the final steps
  ** on initing these are done in mu_end() */

  ImGi_Container* cnt = this.get_current_container();
  cnt.cmd_tail_idx = this.push_jump(-1);
  this.stk_cmd_items[cnt.cmd_head_idx].dst_idx = this.stk_cmd_index;

  /* pop base clip rect and container */
  this.pop_clip_rect();
  this.pop_container();
}


ImGi_Res ImGi_Context::BeginWindow(String title, int x, int y, int width, int height, ImGi_Opt opt)
{
  Rect* body;
  ImGi_ID id = this.GetID(title);
  ImGi_Container* cnt = this.get_container(id, opt);
  if(cnt == null || !(cnt.open)) return eImGi_Res_None;
  this.stk_id_push(id);

  if(cnt.rect_w == 0) {
    cnt.rect_x = x;
    cnt.rect_y = y;
    cnt.rect_w = width;
    cnt.rect_h = height;
  }
  this.begin_root_container(cnt);
  body = Rect.Create(cnt.rect_x, cnt.rect_y, cnt.rect_w, cnt.rect_h);
  Rect* rect = body.Copy();

  /*draw frame*/
  if(!(opt & eImGi_Opt_NoFrame))
  {
    this.draw_frame(rect, eImGi_Col_WindowBG);
  }

  /* do title bar */
  if(!(opt & eImGi_Opt_NoTitle))
  {
    Rect* tr = rect.Copy();
    tr.h = this.style.title_height;
    this.draw_frame(tr, eImGi_Col_TitleBG);

    /* do title text */
    if(!(opt & eImGi_Opt_NoTitle))
    {
      ImGi_ID _id = this.GetID("!title");
      this.update_control(_id, tr, opt);
      this.draw_control_text(title, tr, eImGi_Col_TitleText, opt);
      if(_id == this.focus && this.mouse_down == eImGi_Mouse_Left)
      {
        cnt.rect_x += this.mouse_delta_x;
        cnt.rect_y += this.mouse_delta_y;
      }
      body.y += tr.h;
      body.h -= tr.h;
    }

    /* do `close` button */
    if(!(opt & eImGi_Opt_NoClose))
    {
      ImGi_ID _id = this.GetID("!close");
      Rect* cr = Rect.Create(tr.x+tr.w-tr.h, tr.y, tr.h, tr.h);
      tr.w -= cr.w;
      this.draw_icon(eImGi_Icon_Close, cr, this.style.colors[eImGi_Col_TitleText]);
      this.update_control(_id, cr, opt);
      if(this.mouse_pressed == eImGi_Mouse_Left && _id == this.focus)
      {
        cnt.open = false;
      }
    }
  }

  this.push_container_body(cnt, body, opt);

  /* do `resize` handle */
  if(!(opt & eImGi_Opt_NoResize))
  {
    int sz = this.style.title_height;
    ImGi_ID _id = this.GetID("!resize");
    Rect* _r = Rect.Create(rect.x+rect.w-sz, rect.y+rect.h-sz, sz, sz);
    this.update_control(_id , _r, opt);
    if(_id == this.focus && this.mouse_down == eImGi_Mouse_Left)
    {
      cnt.rect_w = _max(96, cnt.rect_w + this.mouse_delta_x);
      cnt.rect_h = _max(64, cnt.rect_h + this.mouse_delta_y);
    }
  }

  /* resize to content size */
  if(opt & eImGi_Opt_AutoSize)
  {
    ImGi_Layout* lay = this.get_layout();
    cnt.rect_w = cnt.content_w + (cnt.rect_w - lay.body_w);
    cnt.rect_h = cnt.content_h + (cnt.rect_h - lay.body_h);
  }

  /* close if this is a popup window and elsewhere was clicked */
  if( opt & eImGi_Opt_PopUp && this.mouse_pressed && this.hover_root != cnt)
  {
    cnt.open = false;
  }

  this.push_clip_rect(Rect.Create(cnt.body_x, cnt.body_y, cnt.body_w, cnt.body_h));
  return eImGi_Res_Active;
}

void ImGi_Context::EndWindow()
{
  this.pop_clip_rect();
  this.end_root_container();
}

void ImGi_Context::OpenPopup(String name)
{
  ImGi_Container* cnt = this.get_container(this.GetID(name), 0);
  /* set as hover root so popup isn't closed in begin_window_ex()  */
  this.next_hover_root = cnt;
  this.hover_root = cnt;
  /* position at mouse cursor, open and bring-to-front */
  cnt.rect_x = this.mouse_pos_x;
  cnt.rect_y = this.mouse_pos_y;
  cnt.rect_w = 1; // this should be -1 and then resize to whatever are the needs
  cnt.rect_h = 1; // should be -1 too
  cnt.open = true;
  this.bring_to_front(cnt);
}

ImGi_Res ImGi_Context::BeginPopup(String name)
{
  ImGi_Opt opt = eImGi_Opt_PopUp | eImGi_Opt_AutoSize | eImGi_Opt_NoResize |
                 eImGi_Opt_NoScroll | eImGi_Opt_NoTitle | eImGi_Opt_Closed;
  return this.BeginWindow(name, 0, 0, 0, 0, opt);
}

void ImGi_Context::EndPopup()
{
  this.EndWindow();
}


// Controls -->> /////////////////////////////////////////////////////////

//// Render

/////////////////////////////////////////////////////////// <<-- Icon Specifics 

struct Icon {
  int width;
  int height;
  String string_bmp; 
};

Icon _icons[eImGi_Icon_MAX];
DynamicSprite* _icons_spr[eImGi_Icon_MAX];

// Draw a "bitmap" stored as an array of Strings
void drawPixelString(this DrawingSurface*, String str, int x, int y, int w, int h, char p, bool flipH, bool flipV)
{
  for(int i=0; i<h; i++)
  {
    for(int j=0; j<w; j++)
    {
      char c = str.Chars[i*w+j];
      if(c == p)
      {
        int px; int py;
        if(flipH)
          px = x+w-j;
        else
          px = x+j;
        if(flipV)
          py = y+h-i;
        else
          py = y+i;
          
        this.DrawPixel(px, py);
      }
    }
  }
}

void _initIconDescriptor()
{
  String arr;
    
  arr = "";
  arr = arr.Append("X      X");
  arr = arr.Append(" X    X ");
  arr = arr.Append("  X  X  ");
  arr = arr.Append("   XX   ");
  arr = arr.Append("   XX   ");
  arr = arr.Append("  X  X  ");
  arr = arr.Append(" X    X ");
  arr = arr.Append("X      X");
  
  _icons[eImGi_Icon_Close].width = 8;
  _icons[eImGi_Icon_Close].height = 8;
  _icons[eImGi_Icon_Close].string_bmp = arr;
  
  
  arr = "";
  arr = arr.Append("        ");
  arr = arr.Append("        ");
  arr = arr.Append("       X");
  arr = arr.Append(" XX   X ");
  arr = arr.Append("  XX X  ");
  arr = arr.Append("   XX   ");
  arr = arr.Append("        ");
  arr = arr.Append("        ");
  
  _icons[eImGi_Icon_Check].width = 8;
  _icons[eImGi_Icon_Check].height = 8;
  _icons[eImGi_Icon_Check].string_bmp = arr;
  
    
  arr = "";
  arr = arr.Append("XXXXXXXX");
  arr = arr.Append("XXXXXXXX");
  arr = arr.Append("X      X");
  arr = arr.Append("X      X");
  arr = arr.Append("X      X");
  arr = arr.Append("X      X");
  arr = arr.Append("X      X");
  arr = arr.Append("XXXXXXXX");
  
  _icons[eImGi_Icon_Expanded].width = 8;
  _icons[eImGi_Icon_Expanded].height = 8;
  _icons[eImGi_Icon_Expanded].string_bmp = arr;
  
  
  arr = "";
  arr = arr.Append("        ");
  arr = arr.Append("        ");
  arr = arr.Append("        ");
  arr = arr.Append("        ");
  arr = arr.Append("        ");
  arr = arr.Append("        ");
  arr = arr.Append("XXXXXXXX");
  arr = arr.Append("XXXXXXXX");
    
  _icons[eImGi_Icon_Collapsed].width = 8;
  _icons[eImGi_Icon_Collapsed].height = 8;
  _icons[eImGi_Icon_Collapsed].string_bmp = arr;
}

void _initIconDrawing()
{
  for(int i=1; i<eImGi_Icon_MAX; i++)
  {
    _icons_spr[i] = DynamicSprite.Create(_icons[i].width, _icons[i].height, true);
    DrawingSurface* surf = _icons_spr[i].GetDrawingSurface();
    surf.DrawingColor = 35953;
    surf.drawPixelString(_icons[i].string_bmp, 0, 0, _icons[i].width, _icons[i].height, 'X', false, false);
    surf.Release();
  }
}

void _fullInitIcons()
{
  _initIconDescriptor();
  _initIconDrawing();
}

/// End Icon Specifics -->> /////////////////////////////////////////////////////////

ImGi_Context _ImGi;

int _ImGi_Calculate_Command_Hash()
{
  int hn = 0;

  for(int i=0; i<_ImGi.stk_cmd_index; i++)
  {
    ImGi_Cmd* c = _ImGi.stk_cmd_items[i];
    if(c!=null)
    {
      hn = (hn ^ c.type)* 16777619;
      hn = (hn ^ c.dst_idx)* 16777619;
      hn = (hn ^ c.x)* 16777619;
      hn = (hn ^ c.y)* 16777619;
      hn = (hn ^ c.w)* 16777619;
      hn = (hn ^ c.h)* 16777619;
      hn = (hn ^ c.color)* 16777619;
      if(c.str[0] != 0) 
      {
        String s = String.Format("%s",c.str);
        for(int k=0; k<s.Length; k++) 
        {
          hn = (hn ^ s.Chars[k])* 16777619;
        }
      }      
    }
  }
  return hn;
}

// this is limited by the number of Overlays
#define MAX_CLIPS 20
struct R_Clips {
  int x;
  int y;
  int w;
  int h;
  DynamicSprite* spr;
  Overlay* ovr;
  DrawingSurface* srf;
};

R_Clips _clips[MAX_CLIPS];
int r_c_i;

void r_set_clip_rect(int r_x, int r_y, int r_w, int r_h)
{
  if(r_c_i>=0 && _clips[r_c_i].srf != null){
    _clips[r_c_i].srf.Release();
    _clips[r_c_i].srf = null;
  }
  r_c_i++;
  
  expect(r_c_i < MAX_CLIPS); // If you are here, MAX_CLIPS needs to be increased, but AGS has a MAX of 20 overlays, so we can't
  
  _clips[r_c_i].x = r_x;
  _clips[r_c_i].y = r_y;
  _clips[r_c_i].w = r_w;
  _clips[r_c_i].h = r_h;
  _clips[r_c_i].spr = DynamicSprite.Create(r_w, r_h, true);
  _clips[r_c_i].srf = _clips[r_c_i].spr.GetDrawingSurface();
}


void r_clear()
{
  r_c_i = -1;
  for(int i=0; i<MAX_CLIPS; i++) {
    if(_clips[i].ovr != null) {
      _clips[i].ovr.Remove();
      _clips[i].ovr = null;
    }
    if(_clips[i].spr != null) {
      _clips[i].spr.Delete();
      _clips[i].spr = null;
    }
  }
  
  r_set_clip_rect(0, 0, Screen.Width, Screen.Height);
}


void r_draw_rect(int r_x, int r_y, int r_w, int r_h, int color) {
  _clips[r_c_i].srf.DrawingColor = color;
  int adj_x = r_x-_clips[r_c_i].x;
  int adj_y = r_y-_clips[r_c_i].y;
  _clips[r_c_i].srf.DrawRectangle(adj_x, adj_y, adj_x+r_w, adj_y+r_h);
}

void r_draw_text(String text, int pos_x, int pos_y, int color, FontType font) {
  _clips[r_c_i].srf.DrawingColor = color;
  int adj_x = pos_x-_clips[r_c_i].x;
  int adj_y = pos_y-_clips[r_c_i].y;
  _clips[r_c_i].srf.DrawString(adj_x, adj_y, font, text);
}

void r_draw_icon(int r_x, int r_y, int r_w, int r_h, int color, int id) {
  int adj_x = r_x-_clips[r_c_i].x;
  int adj_y = r_y-_clips[r_c_i].y;
   
  // convert agscolor to tint color
  int col_r = (color & 63488) >> 11;
  int col_g = (color & 2016) >> 5;
  int col_b = (color & 31); 
  col_r = (col_r << 3) + (col_r >> 2);
  col_g = (col_g << 2) + (col_g >> 4);
  col_b = (col_b << 3) + (col_b >> 2);
    
  DynamicSprite* dynspr = DynamicSprite.CreateFromExistingSprite(_icons_spr[id].Graphic, true);
  dynspr.Tint(col_r, col_g, col_b, 100, 100);
  
  _clips[r_c_i].srf.DrawImage(adj_x, adj_y, dynspr.Graphic, 0, r_w, r_h);

}

void r_render_clips()
{
  for(int i=0; i<r_c_i+1; i++) 
  {
    if(_clips[i].srf != null) {
       DynamicSprite* tmp = DynamicSprite.CreateFromDrawingSurface(_clips[i].srf, 0, 0, _clips[i].w, _clips[i].h);
      _clips[i].srf.Release();
      _clips[i].srf = null;
      _clips[i].spr = tmp;
    }
    if(_clips[i].spr != null && _clips[i].spr.Width > 0 && _clips[i].spr.Height > 0) {
      _clips[i].ovr = Overlay.CreateGraphical(_clips[i].x, _clips[i].y, _clips[i].spr.Graphic, true);
    }
  }
}

void log_commands()
{
  /*print command list*/
  File* f = File.Open("$SAVEGAMEDIR$/command_list.log",eFileAppend);

  String dic[6];
  dic[eImGi_CmdNone] = "NULL";
  dic[eImGi_CmdJump] = "Jump";
  dic[eImGi_CmdClip] = "clip";
  dic[eImGi_CmdRect] = "rect";
  dic[eImGi_CmdText] = "text";
  dic[eImGi_CmdIcon] = "icon";


  f.WriteRawLine("NEW COMMAND LIST");
  f.WriteRawLine(String.Format("stk_cmd_index=%d\n",_ImGi.stk_cmd_index));

  for(int i=0; i<IMGI_COMMANDLIST_SIZE; i++){
    ImGi_Cmd* c = _ImGi.stk_cmd_items[i];
    if(c==null){
      f.WriteRawLine(String.Format(
        "cmd\[%d] type=%d\[----] dst_idx=%d x=%d y=%d w=%d h=%d",
        i, -1, -1, -1, -1, -1, -1));
    } else {
      f.WriteRawLine(String.Format(
        "cmd\[%d] type=%d\[%s] dst_idx=%d x=%d y=%d w=%d h=%d str=%s",
        i, c.type, dic[c.type],  c.dst_idx, c.x, c.y, c.w, c.h, c.str));
    }
  }

  f.Close();
}

void r_do_draw_command(ImGi_Cmd* cmd)
{
  switch(cmd.type)
  {
    case eImGi_CmdText: r_draw_text(String.Format("%s",cmd.str), cmd.x, cmd.y, cmd.color, cmd.font); break;
    case eImGi_CmdRect: r_draw_rect(cmd.x, cmd.y, cmd.w, cmd.h, cmd.color); break;
    case eImGi_CmdIcon: r_draw_icon(cmd.x, cmd.y, cmd.w, cmd.h, cmd.color, cmd.icon); break;
    case eImGi_CmdClip: r_set_clip_rect(cmd.x, cmd.y, cmd.w, cmd.h); break;
  }
}

void r_render()
{
  // uncomment the log below for debugging, check Save Game dir
  /// log_commands();
    
  // skip frames when rendering
  if(_ImGi._cfg_skipframes > 1 && (_ImGi.frame % _ImGi._cfg_skipframes)) return;
  
  // skip render if hashes match
  int command_hash = _ImGi_Calculate_Command_Hash();
  if(command_hash == _ImGi.previous_command_hash) return;
  _ImGi.previous_command_hash = command_hash;
  
  
  // things changed so we will clear and re-render
  r_clear();
  ImGi_Cmd* cmd;
  for(int i=0; i<_ImGi.stk_cmd_index; )
  {
    cmd = _ImGi.stk_cmd_items[i];
    if(cmd == null || cmd.type == -1) break;
    if(cmd.type == eImGi_CmdJump) {
      i = cmd.dst_idx;
      continue;
    }
    
    r_do_draw_command(cmd);
    i++;
  }

  r_render_clips();
}

//// HACKS
// These are things that I will want to remove eventually once other problems are solved
// But I need this module workin NOW because I am using it.
void _init_hacks() 
{
  _ImGi._cfg_skipframes = 0;
  if(Screen.Width * Screen.Height > 500000) _ImGi._cfg_skipframes = 2;
  if(Screen.Width * Screen.Height > 800000) _ImGi._cfg_skipframes = 3;
  if(Screen.Width * Screen.Height > 1300000) _ImGi._cfg_skipframes = 4;
  
}

//// AGS Connections

void game_start()
{
  _fullInitIcons();
  SetGameOption(OPT_MOUSEWHEEL, 1);
  unclipped_rect = Rect.Create(0, 0, UNCLIPPED_RECT_W, UNCLIPPED_RECT_H);

  _ImGi.Init();
  _init_hacks();
}

void on_event (EventType event, int data)
{
  if(event == eEventLeaveRoom) 
  {
    // make sure no Overlay is left behind!
    r_clear();
  }
}

ImGi_Mouse_Button btn_click;
void on_mouse_click(MouseButton button)
{ 
  btn_click = eImGi_Mouse_Left*(button==eMouseLeft) +
        eImGi_Mouse_Right*(button==eMouseRight) +
        eImGi_Mouse_Middle*(button==eMouseMiddle);

  if(button == eMouseWheelNorth){
    _ImGi.scroll_delta_x += -16;
    _ImGi.scroll_delta_y += -16;
  } else if(button == eMouseWheelSouth){
    _ImGi.scroll_delta_x += 16;
    _ImGi.scroll_delta_y += 16;
  }
  
  // prevent clicks from passing through visible containers
  // hover_root holds the container the mouse is over, null means nothing
  if(_ImGi.hover_root) ClaimEvent(); 
}

void on_key_press (eKeyCode keycode)
{
  _ImGi.key_pressed = keycode;
  _ImGi.key_down = keycode;
  
  if(keycode == eKeyBackspace ||
     keycode == eKeyDelete || 
     keycode == eKeyReturn ) return;
   
  
  if(_ImGi.number_edit && _IsKeycodeNumeric(keycode))
  {
    // number edit
    _ImGi.input_text = _ImGi.input_text.AppendChar(keycode);    
  }
  else
  {   
    // text edit
    if(!_IsShiftKeyPressed() && (keycode >= eKeyA && keycode <= eKeyZ))
    {  
      keycode |= 32; // this only works for ascii but should hold until we get utf8 ags
    }
    _ImGi.input_text = _ImGi.input_text.AppendChar(keycode);
  }
  
  // this means something is capturing keyboard events, so we can Claim it
  if(_ImGi.focus) ClaimEvent();
}

void repeatedly_execute_always()
{
  ImGi_Mouse_Button btn = 0;
  btn = eImGi_Mouse_Left*Mouse.IsButtonDown(eMouseLeft) +
        eImGi_Mouse_Right*Mouse.IsButtonDown(eMouseRight) +
        eImGi_Mouse_Middle*Mouse.IsButtonDown(eMouseMiddle);

  _ImGi.mouse_down = btn;
  _ImGi.mouse_pressed = btn_click;
  _ImGi.mouse_pos_x = mouse.x;
  _ImGi.mouse_pos_y = mouse.y;
  //ImGi.process_frame();
  btn_click = 0;
}

// Public Interface

static void ImGi::Begin() { _ImGi.Begin(); }
static void ImGi::End() { 
  _ImGi.End();   
  r_render();
}

// Layout
static void ImGi::LayoutRow(int items, int widths[], int height) {
  _ImGi.LayoutRow(items, widths, height);
}
  
// Controls
static ImGi_Res ImGi::BeginWindow(String title, int x, int y, int width, int height, ImGi_Opt opt) {
  return _ImGi.BeginWindow(title, x, y, width, height, opt);
}

static void ImGi::EndWindow() { _ImGi.EndWindow(); } 

static void ImGi::OpenWindow(String title) {
  ImGi_ID id = _ImGi.GetID(title);
  ImGi_Container* cnt =_ImGi.get_container(id, 0);
  if(cnt == null || !(cnt.open)) cnt.open = true;
}
  
/// NOT WORKING YET! 
// import static void OpenPopup(String name);

/// NOT WORKING YET!
// import static ImGi_Res BeginPopup(String name);

/// NOT WORKING YET!
// import static void EndPopup();

// static void ImGi::OpenPopup(String name) { _ImGi.OpenPopup(name); }
// static ImGi_Res ImGi::BeginPopup(String name) { return _ImGi.BeginPopup(name); }
// static void ImGi::EndPopup(){ _ImGi.EndPopup(); }

static void ImGi::Text(String text) { _ImGi.Text(text); }
static String ImGi::TextBox(String label, String buf, int bufsz, ImGi_Result* res, ImGi_Opt opt)
{
  return _ImGi.TextBox(label, res, buf, bufsz, opt);  
}

static ImGi_Res ImGi::Number(String label, ImGi_Real* value, String format, float step, ImGi_Opt opt)
{

  if(String.IsNullOrEmpty(format))
  {
    return _ImGi.Number(label, value, IMGI_SLIDER_FMT, step, opt);
  } 
  return _ImGi.Number(label, value, format, step, opt);
}

static ImGi_Res ImGi::Slider(String label, ImGi_Real* value, float low, float high, float step, ImGi_Opt opt)
{
  return _ImGi.Slider(label, value, low, high, step, opt);  
}

static void ImGi::Label(String label) { _ImGi.Label(label); }
static ImGi_Res ImGi::Button(String label, ImGi_Icon icon, ImGi_Opt opt)
{
  return _ImGi.Button(label, icon, opt);  
}

static ImGi_Res ImGi::CheckBox(String label, CheckBoxState* chkst){
  return _ImGi.CheckBox(label, chkst);
}

ImGi_Style* get_Style(static ImGi)
{ return _ImGi.style; }
void set_Style(static ImGi, ImGi_Style* value)
{ _ImGi.style = value; }

// these are fake just so we can make the config interface prettier
ImGi_Config* get_Config(static ImGi)
{ 
  return null;  
}
void set_Config(static ImGi, ImGi_Config* value)
{ 
 
}

ImGi_Cfg_SkipFrames get_SkipFrames(static ImGi_Config)
{ 
  return _ImGi._cfg_skipframes; 
}
void set_SkipFrames(static ImGi_Config, ImGi_Cfg_SkipFrames value)
{  
  _ImGi._cfg_skipframes = value; 
} �  // ImGi Module Header
//
//                   ImGi Version 0.2.2
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
  
  // Controls
  
  /// Creates a window, make sure to call a matching EndWindow() if this method return is not false.
  import static ImGi_Res BeginWindow(String title, int x, int y, int width, int height, ImGi_Opt opt = 0);
  
  /// Has to be called each time a BeginWindow is successful once all elements inside the window are listed
  import static void EndWindow();
  
  /// Opens a window that was closed
  import static void OpenWindow(String title);
     
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
  import static ImGi_Res Number(String label, ImGi_Real* value, String format = 0, float step = 0, ImGi_Opt opt = 0);
  
  /// This control is a Slider.
  import static ImGi_Res Slider(String label, ImGi_Real* value, float low, float high, float step = 0, ImGi_Opt opt = 0);  
};

// ImGi code is licensed with MIT LICENSE. Copyright (c) 2021 eri0o
// ImGi is based on microui, which is MIT licensed too. Microuis is Copyright (c) 2020 rxi �        ej��