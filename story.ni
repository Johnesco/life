"Conway's Game of Life" by "John Googol"

The story headline is "A Cellular Automaton".
The story genre is "Simulation".
The release number is 1.
The story creation year is 2026.
The story description is "Conway's Game of Life -- a cellular automaton simulator running inside Inform 7 / Glulx."

Part 1 - Startup

The Void is a room.

When play begins:
	start the simulation.

To start the simulation: (- LifeMain(); -).

Part 2 - Constants

Include (-

Constant LIFE_W = 40;
Constant LIFE_H = 20;
Constant LIFE_CELLS = 800;
Constant LIFE_ROWS = 22;

Constant LIFE_EV_TIMER   = 1;
Constant LIFE_EV_CHAR    = 2;
Constant LIFE_EV_ARRANGE = 5;

Constant LIFE_STY_NORMAL = 0;
Constant LIFE_STY_USER1  = 9;

Constant LIFE_WINTYPE_GRID = 4;
Constant LIFE_WINMETHOD    = 18;

Constant LIFE_HINT_TEXTCOLOR = 3;
Constant LIFE_HINT_BACKCOLOR = 4;
Constant LIFE_HINT_REVERSE   = 5;

Constant LIFE_KEY_LEFT  = $fffffffe;
Constant LIFE_KEY_RIGHT = $fffffffd;
Constant LIFE_KEY_UP    = $fffffffc;
Constant LIFE_KEY_DOWN  = $fffffffb;

Constant LIFE_END = $7fffffff;

-).

Part 3 - Data

Include (-

Array life_grid --> LIFE_CELLS;
Array life_next --> LIFE_CELLS;

Global life_cx  = 20;
Global life_cy  = 10;
Global life_run = 0;
Global life_gen = 0;
Global life_pop = 0;
Global life_spd = 200;
Global life_gwin = 0;

Array pat1 -->
  1 0  2 1  0 2  1 2  2 2
  LIFE_END;

Array pat2 -->
  0 0  0 1  0 2
  LIFE_END;

Array pat3 -->
  2 0  3 0  4 0    8 0  9 0  10 0
  0 2  5 2  7 2    12 2
  0 3  5 3  7 3    12 3
  0 4  5 4  7 4    12 4
  2 5  3 5  4 5    8 5  9 5  10 5
  2 7  3 7  4 7    8 7  9 7  10 7
  0 8  5 8  7 8    12 8
  0 9  5 9  7 9    12 9
  0 10  5 10  7 10  12 10
  2 12  3 12  4 12  8 12  9 12  10 12
  LIFE_END;

Array pat4 -->
  1 0  2 0  0 1  1 1  1 2
  LIFE_END;

Array pat5 -->
  0 4  0 5  1 4  1 5
  10 4  10 5  10 6
  11 3  11 7
  12 2  12 8
  13 2  13 8
  14 5
  15 3  15 7
  16 4  16 5  16 6
  17 5
  20 2  20 3  20 4
  21 2  21 3  21 4
  22 1  22 5
  24 0  24 1  24 5  24 6
  34 2  34 3  35 2  35 3
  LIFE_END;

-).

Part 4 - Helper Functions

Include (-

[ LifeClear i;
  for (i = 0: i < LIFE_CELLS: i++) life_grid-->i = 0;
  life_gen = 0;
  life_pop = 0;
];

[ LifeCountPop i n;
  n = 0;
  for (i = 0: i < LIFE_CELLS: i++)
    if (life_grid-->i) n++;
  return n;
];

[ LifeLoadPreset num  arr ox oy i px py;
  LifeClear();
  switch (num) {
    1: arr = pat1; ox = LIFE_W / 2 - 1; oy = LIFE_H / 2 - 1;
    2: arr = pat2; ox = LIFE_W / 2;     oy = LIFE_H / 2 - 1;
    3: arr = pat3; ox = LIFE_W / 2 - 6; oy = LIFE_H / 2 - 6;
    4: arr = pat4; ox = LIFE_W / 2 - 1; oy = LIFE_H / 2 - 1;
    5: arr = pat5; ox = 2;              oy = LIFE_H / 2 - 5;
    default: return;
  }
  i = 0;
  while (arr-->i ~= LIFE_END) {
    px = arr-->i + ox;
    py = arr-->(i + 1) + oy;
    if (px >= 0 && px < LIFE_W && py >= 0 && py < LIFE_H)
      life_grid-->(py * LIFE_W + px) = 1;
    i = i + 2;
  }
  life_pop = LifeCountPop();
];

[ LifeNeighbors gx gy  n nx ny;
  n = 0;
  for (ny = gy - 1: ny <= gy + 1: ny++) {
    if (ny >= 0 && ny < LIFE_H) {
      for (nx = gx - 1: nx <= gx + 1: nx++) {
        if (nx >= 0 && nx < LIFE_W) {
          if (~~(nx == gx && ny == gy)) {
            if (life_grid-->(ny * LIFE_W + nx)) n++;
          }
        }
      }
    }
  }
  return n;
];

[ LifeStep  x y nb;
  for (y = 0: y < LIFE_H: y++) {
    for (x = 0: x < LIFE_W: x++) {
      nb = LifeNeighbors(x, y);
      if (life_grid-->(y * LIFE_W + x)) {
        if (nb == 2 || nb == 3)
          life_next-->(y * LIFE_W + x) = 1;
        else
          life_next-->(y * LIFE_W + x) = 0;
      } else {
        if (nb == 3)
          life_next-->(y * LIFE_W + x) = 1;
        else
          life_next-->(y * LIFE_W + x) = 0;
      }
    }
  }
  for (x = 0: x < LIFE_CELLS: x++)
    life_grid-->x = life_next-->x;
  life_gen++;
  life_pop = LifeCountPop();
];

-).

Part 5 - Rendering and Main

Include (-

[ LifeRender  x y cell;
  glk_set_window(life_gwin);
  glk_window_clear(life_gwin);

  glk_window_move_cursor(life_gwin, 0, 0);
  glk_set_style(LIFE_STY_NORMAL);
  print "Gen: ", life_gen, "  Pop: ", life_pop,
    "  Speed: ", life_spd, "ms  ";
  if (life_run) print "[RUNNING]";
  else print "[PAUSED] ";

  for (y = 0: y < LIFE_H: y++) {
    glk_window_move_cursor(life_gwin, 0, y + 1);
    for (x = 0: x < LIFE_W: x++) {
      cell = life_grid-->(y * LIFE_W + x);
      if (x == life_cx && y == life_cy)
        glk_set_style(LIFE_STY_USER1);
      else
        glk_set_style(LIFE_STY_NORMAL);
      if (cell) glk_put_char_uni($2588);
      else glk_put_char_uni(32);
    }
  }

  glk_window_move_cursor(life_gwin, 0, LIFE_H + 1);
  glk_set_style(LIFE_STY_NORMAL);
  print "Arrows/WASD:Move  Space:Toggle  R/P:Run/Pause  N:Step  C:Clear  1-5:Preset  Q:Quit";
];

[ LifeHandleKey ch;
  switch (ch) {
    'w', 'W', LIFE_KEY_UP:
      if (life_cy > 0) life_cy--;
    'a', 'A', LIFE_KEY_LEFT:
      if (life_cx > 0) life_cx--;
    's', 'S', LIFE_KEY_DOWN:
      if (life_cy < LIFE_H - 1) life_cy++;
    'd', 'D', LIFE_KEY_RIGHT:
      if (life_cx < LIFE_W - 1) life_cx++;
    ' ':
      if (life_grid-->(life_cy * LIFE_W + life_cx))
        life_grid-->(life_cy * LIFE_W + life_cx) = 0;
      else
        life_grid-->(life_cy * LIFE_W + life_cx) = 1;
      life_pop = LifeCountPop();
    'r', 'R':
      life_run = 1;
      glk_request_timer_events(life_spd);
    'p', 'P':
      life_run = 0;
      glk_request_timer_events(0);
    'n', 'N':
      if (~~life_run) LifeStep();
    'c', 'C':
      LifeClear();
      life_run = 0;
      glk_request_timer_events(0);
    '1': LifeLoadPreset(1);
    '2': LifeLoadPreset(2);
    '3': LifeLoadPreset(3);
    '4': LifeLoadPreset(4);
    '5': LifeLoadPreset(5);
    '+', '=':
      if (life_spd > 50) life_spd = life_spd - 50;
      if (life_run) glk_request_timer_events(life_spd);
    '-', '_':
      if (life_spd < 1000) life_spd = life_spd + 50;
      if (life_run) glk_request_timer_events(life_spd);
    'q', 'Q':
      glk_set_window(gg_mainwin);
      new_line;
      print "Thanks for playing!";
      new_line;
      @quit;
  }
  LifeRender();
];

[ LifeMain;
  if (gg_statuswin) {
    glk_window_close(gg_statuswin, 0);
    gg_statuswin = 0;
  }

  glk_stylehint_set(LIFE_WINTYPE_GRID, LIFE_STY_NORMAL,
    LIFE_HINT_TEXTCOLOR, $00FF00);
  glk_stylehint_set(LIFE_WINTYPE_GRID, LIFE_STY_NORMAL,
    LIFE_HINT_BACKCOLOR, $000000);
  glk_stylehint_set(LIFE_WINTYPE_GRID, LIFE_STY_USER1,
    LIFE_HINT_REVERSE, 1);

  life_gwin = glk_window_open(gg_mainwin,
    LIFE_WINMETHOD, LIFE_ROWS, LIFE_WINTYPE_GRID, 0);

  LifeClear();
  LifeLoadPreset(1);
  LifeRender();

  glk_set_window(gg_mainwin);
  new_line;
  print "=== Conway's Game of Life ===";
  new_line;
  print "Running inside Inform 7 / Glulx.";
  new_line; new_line;
  print "CONTROLS:";
  new_line;
  print "  Arrows or WASD  Move cursor";
  new_line;
  print "  SPACE            Toggle cell";
  new_line;
  print "  R                Run simulation";
  new_line;
  print "  P                Pause";
  new_line;
  print "  N                Step one generation";
  new_line;
  print "  C                Clear grid";
  new_line;
  print "  1-5              Load preset pattern";
  new_line;
  print "  + or -           Adjust speed";
  new_line;
  print "  Q                Quit";
  new_line; new_line;
  print "PRESETS:";
  new_line;
  print "  1  Glider        Spaceship";
  new_line;
  print "  2  Blinker       Period-2 oscillator";
  new_line;
  print "  3  Pulsar        Period-3 oscillator";
  new_line;
  print "  4  R-pentomino   Chaotic methuselah";
  new_line;
  print "  5  Glider Gun    Infinite growth";
  new_line;

  glk_request_char_event(gg_mainwin);
  while (1) {
    glk_select(gg_event);
    switch (gg_event-->0) {
      LIFE_EV_TIMER:
        LifeStep();
        LifeRender();
      LIFE_EV_CHAR:
        LifeHandleKey(gg_event-->2);
        glk_request_char_event(gg_mainwin);
      LIFE_EV_ARRANGE:
        LifeRender();
    }
  }
];

-).
