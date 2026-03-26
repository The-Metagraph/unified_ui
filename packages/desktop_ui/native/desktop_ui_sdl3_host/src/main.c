#define SDL_MAIN_USE_CALLBACKS 1
#include <SDL3/SDL.h>
#include <SDL3/SDL_main.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#define MAX_WINDOWS 16
#define MAX_DRAWS 512
#define MAX_LINE 4096

typedef struct {
  Uint8 r;
  Uint8 g;
  Uint8 b;
  Uint8 a;
} dui_color;

typedef struct {
  char window_id[128];
  char title[128];
  int x;
  int y;
  int width;
  int height;
  SDL_Window *window;
  SDL_Renderer *renderer;
} dui_window;

typedef struct {
  char window_id[128];
  char draw_kind[64];
  char kind[64];
  char family[64];
  char bg[64];
  char fg[64];
  char border[64];
  char variant[64];
  char semantic_role[64];
  char content[256];
  int x;
  int y;
  int width;
  int height;
  int clip;
  int clip_x;
  int clip_y;
  int clip_width;
  int clip_height;
  int disabled;
  int focused;
  int selected;
  int checked;
  int active;
  int open;
  int current;
  int loading;
  int child_count;
  int item_count;
  int row_count;
  int column_count;
  int series_count;
  int current_index;
  int selected_index;
  int value;
  int max_value;
  int content_length;
} dui_draw;

typedef struct {
  dui_window windows[MAX_WINDOWS];
  int window_count;
  dui_draw draws[MAX_DRAWS];
  int draw_count;
} dui_frame;

typedef struct {
  dui_frame frame;
  int linger_ms;
  Uint64 start_ticks;
  int needs_redraw;
  int shutdown_requested;
} dui_app;

static void decode_value(char *value);
static int parse_frame_script(const char *path, dui_frame *frame);
static int parse_attrs(char *line, char attrs[][2][256], int max_attrs);
static void copy_attr(char *dest, size_t dest_size, char attrs[][2][256], int count,
                      const char *key, const char *fallback);
static int int_attr(char attrs[][2][256], int count, const char *key, int fallback);
static void render_window(dui_frame *frame, int window_index);
static void destroy_frame_windows(dui_frame *frame);
static void print_probe(void);
static dui_color named_color(const char *name, Uint8 alpha);
static void use_color(SDL_Renderer *renderer, dui_color color);
static void fill_rect(SDL_Renderer *renderer, SDL_FRect rect, dui_color color);
static void stroke_rect(SDL_Renderer *renderer, SDL_FRect rect, dui_color color);
static void fill_inset_rect(SDL_Renderer *renderer, SDL_FRect rect, float inset, dui_color color);
static void draw_text_bands(SDL_Renderer *renderer, SDL_FRect rect, int content_length,
                            dui_color color, int emphasized);
static void draw_item_rows(SDL_Renderer *renderer, SDL_FRect rect, int count, int current_index,
                           int selected_index, dui_color base, dui_color highlight);
static void draw_table_grid(SDL_Renderer *renderer, SDL_FRect rect, int columns, int rows,
                            dui_color stroke, dui_color highlight);
static void draw_progress_bar(SDL_Renderer *renderer, SDL_FRect rect, int value, int max_value,
                              dui_color track, dui_color fill);
static void draw_surface_shell(SDL_Renderer *renderer, SDL_FRect rect, dui_color fill,
                               dui_color stroke, int focused, int disabled);
static void render_draw_operation(SDL_Renderer *renderer, const dui_draw *draw);

static void print_probe(void) {
  printf(
      "{\"host\":\"desktop_ui_sdl3_host\",\"status\":\"visible_frame_ready\","
      "\"launch_ready\":false,\"visible_runner_ready\":true,"
      "\"backend\":\"compiled_sdl3_host\",\"compiled_with\":\"SDL3 %d.%d.%d\"}\n",
      SDL_MAJOR_VERSION, SDL_MINOR_VERSION, SDL_MICRO_VERSION);
}

SDL_AppResult SDL_AppInit(void **appstate, int argc, char **argv) {
  dui_app *app = (dui_app *)calloc(1, sizeof(dui_app));
  const char *frame_script = NULL;
  *appstate = app;

  if (app == NULL) {
    fprintf(stderr, "unable to allocate desktop_ui SDL3 app state\n");
    return SDL_APP_FAILURE;
  }

  app->linger_ms = 1500;

  for (int i = 1; i < argc; i++) {
    if (strcmp(argv[i], "--probe") == 0) {
      print_probe();
      return SDL_APP_SUCCESS;
    }

    if (strcmp(argv[i], "--version") == 0) {
      printf("%d.%d.%d\n", SDL_MAJOR_VERSION, SDL_MINOR_VERSION, SDL_MICRO_VERSION);
      return SDL_APP_SUCCESS;
    }

    if (strcmp(argv[i], "--frame-script") == 0 && i + 1 < argc) {
      frame_script = argv[++i];
    } else if (strcmp(argv[i], "--linger-ms") == 0 && i + 1 < argc) {
      app->linger_ms = atoi(argv[++i]);
    }
  }

  if (frame_script == NULL) {
    fprintf(stderr, "usage: desktop_ui_sdl3_host --frame-script <path> [--linger-ms N]\n");
    return SDL_APP_FAILURE;
  }

  if (parse_frame_script(frame_script, &app->frame) != 0) {
    fprintf(stderr, "failed to parse frame script %s\n", frame_script);
    return SDL_APP_FAILURE;
  }

  if (!SDL_Init(SDL_INIT_VIDEO)) {
    fprintf(stderr, "SDL_Init failed: %s\n", SDL_GetError());
    return SDL_APP_FAILURE;
  }

  for (int i = 0; i < app->frame.window_count; i++) {
    dui_window *window = &app->frame.windows[i];

    if (!SDL_CreateWindowAndRenderer(window->title, window->width, window->height,
                                     SDL_WINDOW_RESIZABLE | SDL_WINDOW_HIGH_PIXEL_DENSITY,
                                     &window->window, &window->renderer)) {
      fprintf(stderr, "SDL_CreateWindowAndRenderer failed: %s\n", SDL_GetError());
      return SDL_APP_FAILURE;
    }

    SDL_SetRenderLogicalPresentation(window->renderer, window->width, window->height,
                                     SDL_LOGICAL_PRESENTATION_LETTERBOX);
    SDL_SetRenderDrawBlendMode(window->renderer, SDL_BLENDMODE_BLEND);
    SDL_SetWindowPosition(window->window, window->x, window->y);
  }

  app->start_ticks = SDL_GetTicks();
  app->needs_redraw = 1;
  app->shutdown_requested = 0;

  return SDL_APP_CONTINUE;
}

SDL_AppResult SDL_AppEvent(void *appstate, SDL_Event *event) {
  dui_app *app = (dui_app *)appstate;

  if (app == NULL) {
    return SDL_APP_FAILURE;
  }

  switch (event->type) {
  case SDL_EVENT_QUIT:
    return SDL_APP_SUCCESS;

  case SDL_EVENT_WINDOW_CLOSE_REQUESTED:
    app->shutdown_requested = 1;
    return SDL_APP_SUCCESS;

  case SDL_EVENT_WINDOW_EXPOSED:
  case SDL_EVENT_WINDOW_RESIZED:
  case SDL_EVENT_WINDOW_PIXEL_SIZE_CHANGED:
    app->needs_redraw = 1;
    break;

  default:
    break;
  }

  return SDL_APP_CONTINUE;
}

SDL_AppResult SDL_AppIterate(void *appstate) {
  dui_app *app = (dui_app *)appstate;

  if (app == NULL) {
    return SDL_APP_FAILURE;
  }

  if (app->needs_redraw) {
    for (int i = 0; i < app->frame.window_count; i++) {
      render_window(&app->frame, i);
    }
    app->needs_redraw = 0;
  }

  if (app->shutdown_requested) {
    return SDL_APP_SUCCESS;
  }

  if (app->linger_ms >= 0 && (int)(SDL_GetTicks() - app->start_ticks) >= app->linger_ms) {
    return SDL_APP_SUCCESS;
  }

  return SDL_APP_CONTINUE;
}

void SDL_AppQuit(void *appstate, SDL_AppResult result) {
  dui_app *app = (dui_app *)appstate;
  (void)result;

  if (app != NULL) {
    destroy_frame_windows(&app->frame);
    free(app);
  }

  SDL_Quit();
}

static void destroy_frame_windows(dui_frame *frame) {
  for (int i = 0; i < frame->window_count; i++) {
    if (frame->windows[i].renderer != NULL) {
      SDL_DestroyRenderer(frame->windows[i].renderer);
      frame->windows[i].renderer = NULL;
    }

    if (frame->windows[i].window != NULL) {
      SDL_DestroyWindow(frame->windows[i].window);
      frame->windows[i].window = NULL;
    }
  }
}

static int parse_frame_script(const char *path, dui_frame *frame) {
  FILE *file = fopen(path, "r");
  if (file == NULL) {
    return -1;
  }

  char line[MAX_LINE];
  while (fgets(line, sizeof(line), file) != NULL) {
    size_t length = strlen(line);
    if (length > 0 && line[length - 1] == '\n') {
      line[length - 1] = '\0';
    }

    if (strncmp(line, "WINDOW\t", 7) == 0) {
      if (frame->window_count >= MAX_WINDOWS) {
        continue;
      }

      dui_window *window = &frame->windows[frame->window_count++];
      char attrs[20][2][256];
      int count = parse_attrs(line + 7, attrs, 20);

      copy_attr(window->window_id, sizeof(window->window_id), attrs, count, "window_id",
                "window:desktop-ui");
      copy_attr(window->title, sizeof(window->title), attrs, count, "title", "DesktopUi");
      window->x = int_attr(attrs, count, "x", 64);
      window->y = int_attr(attrs, count, "y", 64);
      window->width = int_attr(attrs, count, "width", 1280);
      window->height = int_attr(attrs, count, "height", 800);
      window->window = NULL;
      window->renderer = NULL;
    } else if (strncmp(line, "DRAW\t", 5) == 0) {
      if (frame->draw_count >= MAX_DRAWS) {
        continue;
      }

      dui_draw *draw = &frame->draws[frame->draw_count++];
      char attrs[48][2][256];
      int count = parse_attrs(line + 5, attrs, 48);

      copy_attr(draw->window_id, sizeof(draw->window_id), attrs, count, "window_id",
                "window:desktop-ui");
      copy_attr(draw->draw_kind, sizeof(draw->draw_kind), attrs, count, "draw_kind",
                "container_surface");
      copy_attr(draw->kind, sizeof(draw->kind), attrs, count, "kind", "widget");
      copy_attr(draw->family, sizeof(draw->family), attrs, count, "family", "content");
      copy_attr(draw->bg, sizeof(draw->bg), attrs, count, "bg", "canvas");
      copy_attr(draw->fg, sizeof(draw->fg), attrs, count, "fg", "content");
      copy_attr(draw->border, sizeof(draw->border), attrs, count, "border", "single");
      copy_attr(draw->variant, sizeof(draw->variant), attrs, count, "variant", "default");
      copy_attr(draw->semantic_role, sizeof(draw->semantic_role), attrs, count, "semantic_role",
                "body");
      copy_attr(draw->content, sizeof(draw->content), attrs, count, "content", "widget");
      draw->x = int_attr(attrs, count, "x", 0);
      draw->y = int_attr(attrs, count, "y", 0);
      draw->width = int_attr(attrs, count, "width", 240);
      draw->height = int_attr(attrs, count, "height", 48);
      draw->clip = int_attr(attrs, count, "clip", 0);
      draw->clip_x = int_attr(attrs, count, "clip_x", draw->x);
      draw->clip_y = int_attr(attrs, count, "clip_y", draw->y);
      draw->clip_width = int_attr(attrs, count, "clip_width", draw->width);
      draw->clip_height = int_attr(attrs, count, "clip_height", draw->height);
      draw->disabled = int_attr(attrs, count, "disabled", 0);
      draw->focused = int_attr(attrs, count, "focused", 0);
      draw->selected = int_attr(attrs, count, "selected", 0);
      draw->checked = int_attr(attrs, count, "checked", 0);
      draw->active = int_attr(attrs, count, "active", 0);
      draw->open = int_attr(attrs, count, "open", 0);
      draw->current = int_attr(attrs, count, "current", 0);
      draw->loading = int_attr(attrs, count, "loading", 0);
      draw->child_count = int_attr(attrs, count, "child_count", 0);
      draw->item_count = int_attr(attrs, count, "item_count", 0);
      draw->row_count = int_attr(attrs, count, "row_count", 0);
      draw->column_count = int_attr(attrs, count, "column_count", 0);
      draw->series_count = int_attr(attrs, count, "series_count", 0);
      draw->current_index = int_attr(attrs, count, "current_index", -1);
      draw->selected_index = int_attr(attrs, count, "selected_index", -1);
      draw->value = int_attr(attrs, count, "value", 0);
      draw->max_value = int_attr(attrs, count, "max_value", 100);
      draw->content_length = int_attr(attrs, count, "content_length", (int)strlen(draw->content));
    }
  }

  fclose(file);
  return frame->window_count > 0 ? 0 : -1;
}

static int parse_attrs(char *line, char attrs[][2][256], int max_attrs) {
  int count = 0;
  char *token = strtok(line, "\t");

  while (token != NULL && count < max_attrs) {
    char *equals = strchr(token, '=');
    if (equals != NULL) {
      size_t key_len = (size_t)(equals - token);
      if (key_len >= 255) {
        key_len = 255;
      }

      strncpy(attrs[count][0], token, key_len);
      attrs[count][0][key_len] = '\0';
      strncpy(attrs[count][1], equals + 1, 255);
      attrs[count][1][255] = '\0';
      decode_value(attrs[count][1]);
      count++;
    }
    token = strtok(NULL, "\t");
  }

  return count;
}

static void copy_attr(char *dest, size_t dest_size, char attrs[][2][256], int count,
                      const char *key, const char *fallback) {
  for (int i = 0; i < count; i++) {
    if (strcmp(attrs[i][0], key) == 0) {
      strncpy(dest, attrs[i][1], dest_size - 1);
      dest[dest_size - 1] = '\0';
      return;
    }
  }

  strncpy(dest, fallback, dest_size - 1);
  dest[dest_size - 1] = '\0';
}

static int int_attr(char attrs[][2][256], int count, const char *key, int fallback) {
  for (int i = 0; i < count; i++) {
    if (strcmp(attrs[i][0], key) == 0) {
      return atoi(attrs[i][1]);
    }
  }

  return fallback;
}

static dui_color named_color(const char *name, Uint8 alpha) {
  if (name == NULL || strcmp(name, "canvas") == 0) {
    return (dui_color){28, 32, 43, alpha};
  } else if (strcmp(name, "surface") == 0 || strcmp(name, "panel") == 0) {
    return (dui_color){52, 59, 73, alpha};
  } else if (strcmp(name, "content") == 0) {
    return (dui_color){231, 236, 245, alpha};
  } else if (strcmp(name, "muted") == 0) {
    return (dui_color){156, 166, 184, alpha};
  } else if (strcmp(name, "accent") == 0) {
    return (dui_color){78, 138, 250, alpha};
  } else if (strcmp(name, "selection") == 0) {
    return (dui_color){92, 119, 204, alpha};
  } else if (strcmp(name, "focus_ring") == 0) {
    return (dui_color){255, 206, 107, alpha};
  } else if (strcmp(name, "info") == 0) {
    return (dui_color){96, 165, 250, alpha};
  } else if (strcmp(name, "success") == 0) {
    return (dui_color){74, 222, 128, alpha};
  } else if (strcmp(name, "warning") == 0) {
    return (dui_color){245, 158, 11, alpha};
  } else if (strcmp(name, "danger") == 0) {
    return (dui_color){248, 113, 113, alpha};
  }

  return (dui_color){110, 121, 142, alpha};
}

static void use_color(SDL_Renderer *renderer, dui_color color) {
  SDL_SetRenderDrawColor(renderer, color.r, color.g, color.b, color.a);
}

static void fill_rect(SDL_Renderer *renderer, SDL_FRect rect, dui_color color) {
  use_color(renderer, color);
  SDL_RenderFillRect(renderer, &rect);
}

static void stroke_rect(SDL_Renderer *renderer, SDL_FRect rect, dui_color color) {
  use_color(renderer, color);
  SDL_RenderRect(renderer, &rect);
}

static void fill_inset_rect(SDL_Renderer *renderer, SDL_FRect rect, float inset, dui_color color) {
  SDL_FRect inner = {rect.x + inset, rect.y + inset, rect.w - inset * 2.0f, rect.h - inset * 2.0f};
  if (inner.w > 0.0f && inner.h > 0.0f) {
    fill_rect(renderer, inner, color);
  }
}

static void draw_text_bands(SDL_Renderer *renderer, SDL_FRect rect, int content_length,
                            dui_color color, int emphasized) {
  int lines = 1;
  float band_height = emphasized ? 8.0f : 6.0f;
  float left = rect.x + 10.0f;
  float top = rect.y + 10.0f;

  if (content_length > 18) {
    lines = 2;
  }

  if (content_length > 48) {
    lines = 3;
  }

  use_color(renderer, color);

  for (int line = 0; line < lines; line++) {
    float width_ratio = 0.72f - (float)line * 0.12f;
    float width = SDL_max(rect.w * width_ratio, 18.0f);
    SDL_FRect band = {left, top + (float)line * (band_height + 6.0f), width, band_height};
    SDL_RenderFillRect(renderer, &band);
  }
}

static void draw_item_rows(SDL_Renderer *renderer, SDL_FRect rect, int count, int current_index,
                           int selected_index, dui_color base, dui_color highlight) {
  int rows = count > 0 ? count : 3;
  float row_height = SDL_max((rect.h - 16.0f) / (float)rows, 18.0f);

  for (int row = 0; row < rows; row++) {
    SDL_FRect band = {rect.x + 8.0f, rect.y + 8.0f + (float)row * row_height, rect.w - 16.0f,
                      row_height - 6.0f};

    if (row == current_index || row == selected_index) {
      fill_rect(renderer, band, highlight);
    } else {
      fill_rect(renderer, band, base);
    }

    draw_text_bands(renderer, band, 18 + row * 4, named_color("content", 210), 0);
  }
}

static void draw_table_grid(SDL_Renderer *renderer, SDL_FRect rect, int columns, int rows,
                            dui_color stroke, dui_color highlight) {
  int column_count = columns > 0 ? columns : 3;
  int row_count = rows > 0 ? rows : 3;
  float header_height = 28.0f;
  float cell_height = SDL_max((rect.h - header_height - 12.0f) / (float)row_count, 18.0f);
  float cell_width = SDL_max((rect.w - 12.0f) / (float)column_count, 30.0f);

  fill_rect(renderer, (SDL_FRect){rect.x + 6.0f, rect.y + 6.0f, rect.w - 12.0f, header_height},
            highlight);
  draw_text_bands(renderer,
                  (SDL_FRect){rect.x + 12.0f, rect.y + 9.0f, rect.w - 24.0f, header_height - 8.0f},
                  24, named_color("content", 230), 1);

  use_color(renderer, stroke);

  for (int column = 1; column < column_count; column++) {
    float x = rect.x + 6.0f + (float)column * cell_width;
    SDL_RenderLine(renderer, x, rect.y + 6.0f, x, rect.y + rect.h - 6.0f);
  }

  for (int row = 0; row < row_count; row++) {
    float y = rect.y + header_height + 10.0f + (float)row * cell_height;
    SDL_RenderLine(renderer, rect.x + 6.0f, y, rect.x + rect.w - 6.0f, y);
  }
}

static void draw_progress_bar(SDL_Renderer *renderer, SDL_FRect rect, int value, int max_value,
                              dui_color track, dui_color fill) {
  int safe_max = max_value > 0 ? max_value : 100;
  float ratio = SDL_clamp((float)value / (float)safe_max, 0.08f, 1.0f);
  SDL_FRect track_rect = {rect.x + 12.0f, rect.y + rect.h - 22.0f, rect.w - 24.0f, 10.0f};
  SDL_FRect fill_rect_band = {track_rect.x, track_rect.y, track_rect.w * ratio, track_rect.h};

  fill_rect(renderer, track_rect, track);
  fill_rect(renderer, fill_rect_band, fill);
}

static void draw_surface_shell(SDL_Renderer *renderer, SDL_FRect rect, dui_color fill,
                               dui_color stroke, int focused, int disabled) {
  Uint8 alpha = disabled ? 120 : fill.a;
  fill.a = alpha;
  stroke.a = disabled ? 180 : stroke.a;

  fill_rect(renderer, rect, fill);
  stroke_rect(renderer, rect, stroke);

  if (focused) {
    stroke_rect(renderer, (SDL_FRect){rect.x + 2.0f, rect.y + 2.0f, rect.w - 4.0f, rect.h - 4.0f},
                named_color("focus_ring", 255));
  }
}

static void render_draw_operation(SDL_Renderer *renderer, const dui_draw *draw) {
  SDL_FRect rect = {(float)draw->x, (float)draw->y, (float)draw->width, (float)draw->height};
  dui_color surface = named_color(draw->bg, draw->disabled ? 120 : 255);
  dui_color stroke =
      strcmp(draw->border, "focus_ring") == 0 ? named_color("focus_ring", 255)
                                               : named_color(draw->fg, 210);
  dui_color accent = named_color("accent", 245);
  dui_color selection = named_color("selection", 235);
  dui_color muted = named_color("muted", 190);
  dui_color text = named_color(draw->fg, 230);

  if (strcmp(draw->draw_kind, "window_chrome") == 0) {
    draw_surface_shell(renderer, rect, named_color("surface", 255), named_color("content", 220),
                       draw->focused, 0);
    fill_rect(renderer, (SDL_FRect){rect.x, rect.y, rect.w, 42.0f},
              named_color("canvas", 255));
    fill_rect(renderer, (SDL_FRect){rect.x + 14.0f, rect.y + 14.0f, 12.0f, 12.0f},
              named_color("danger", 220));
    fill_rect(renderer, (SDL_FRect){rect.x + 34.0f, rect.y + 14.0f, 12.0f, 12.0f},
              named_color("warning", 220));
    fill_rect(renderer, (SDL_FRect){rect.x + 54.0f, rect.y + 14.0f, 12.0f, 12.0f},
              named_color("success", 220));
    draw_text_bands(renderer, (SDL_FRect){rect.x + 88.0f, rect.y + 10.0f, rect.w - 120.0f, 20.0f},
                    draw->content_length, named_color("content", 230), 1);
    return;
  }

  if (strcmp(draw->draw_kind, "dialog_surface") == 0 ||
      strcmp(draw->draw_kind, "context_menu_surface") == 0 ||
      strcmp(draw->draw_kind, "container_surface") == 0 ||
      strcmp(draw->draw_kind, "viewport_surface") == 0 ||
      strcmp(draw->draw_kind, "split_pane_surface") == 0 ||
      strcmp(draw->draw_kind, "canvas_surface") == 0) {
    draw_surface_shell(renderer, rect, surface, stroke, draw->focused, draw->disabled);

    if (strcmp(draw->draw_kind, "split_pane_surface") == 0) {
      use_color(renderer, named_color("muted", 200));
      SDL_RenderLine(renderer, rect.x + rect.w * 0.6f, rect.y + 8.0f, rect.x + rect.w * 0.6f,
                     rect.y + rect.h - 8.0f);
    } else if (strcmp(draw->draw_kind, "viewport_surface") == 0) {
      stroke_rect(renderer,
                  (SDL_FRect){rect.x + 6.0f, rect.y + 6.0f, rect.w - 12.0f, rect.h - 12.0f},
                  named_color("selection", 210));
    } else if (strcmp(draw->draw_kind, "canvas_surface") == 0) {
      use_color(renderer, named_color("muted", 100));
      for (int line = 1; line < 4; line++) {
        float x = rect.x + (rect.w / 4.0f) * (float)line;
        float y = rect.y + (rect.h / 4.0f) * (float)line;
        SDL_RenderLine(renderer, x, rect.y + 8.0f, x, rect.y + rect.h - 8.0f);
        SDL_RenderLine(renderer, rect.x + 8.0f, y, rect.x + rect.w - 8.0f, y);
      }
    }

    if (strcmp(draw->draw_kind, "dialog_surface") == 0 ||
        strcmp(draw->draw_kind, "context_menu_surface") == 0) {
      draw_text_bands(renderer,
                      (SDL_FRect){rect.x + 14.0f, rect.y + 12.0f, rect.w - 28.0f, 18.0f},
                      draw->content_length, named_color("content", 230), 1);
    }
    return;
  }

  if (strcmp(draw->draw_kind, "overlay_surface") == 0) {
    fill_rect(renderer, rect, named_color("canvas", 120));
    return;
  }

  if (strcmp(draw->draw_kind, "text_block") == 0 || strcmp(draw->draw_kind, "label_block") == 0) {
    if (strcmp(draw->draw_kind, "label_block") == 0) {
      fill_rect(renderer, (SDL_FRect){rect.x, rect.y + 2.0f, rect.w, rect.h - 4.0f},
                named_color("surface", 110));
    }
    draw_text_bands(renderer, rect, draw->content_length, text,
                    strcmp(draw->semantic_role, "title") == 0);
    return;
  }

  if (strcmp(draw->draw_kind, "icon_block") == 0) {
    draw_surface_shell(renderer, rect, named_color("surface", 200), named_color("content", 220), 0,
                       0);
    use_color(renderer, named_color("accent", 240));
    SDL_RenderLine(renderer, rect.x + 10.0f, rect.y + 10.0f, rect.x + rect.w - 10.0f,
                   rect.y + rect.h - 10.0f);
    SDL_RenderLine(renderer, rect.x + rect.w - 10.0f, rect.y + 10.0f, rect.x + 10.0f,
                   rect.y + rect.h - 10.0f);
    return;
  }

  if (strcmp(draw->draw_kind, "image_block") == 0) {
    draw_surface_shell(renderer, rect, named_color("surface", 220), named_color("accent", 210), 0,
                       0);
    fill_inset_rect(renderer, rect, 8.0f, named_color("accent", 90));
    return;
  }

  if (strcmp(draw->draw_kind, "button_control") == 0 ||
      strcmp(draw->draw_kind, "command_control") == 0) {
    dui_color fill =
        (draw->active || strcmp(draw->variant, "filled") == 0) ? accent : named_color("surface", 235);
    dui_color border = draw->focused ? named_color("focus_ring", 255) : named_color("content", 220);

    if (draw->current || draw->selected) {
      fill = selection;
    }

    draw_surface_shell(renderer, rect, fill, border, draw->focused, draw->disabled);
    draw_text_bands(renderer,
                    (SDL_FRect){rect.x + 12.0f, rect.y + 8.0f, rect.w - 24.0f, rect.h - 16.0f},
                    draw->content_length, named_color("content", 235), 1);
    return;
  }

  if (strcmp(draw->draw_kind, "text_input_control") == 0) {
    draw_surface_shell(renderer, rect, named_color("canvas", 255),
                       draw->focused ? named_color("focus_ring", 255)
                                     : named_color("muted", 210),
                       draw->focused, draw->disabled);
    draw_text_bands(renderer,
                    (SDL_FRect){rect.x + 12.0f, rect.y + 10.0f, rect.w - 30.0f, rect.h - 18.0f},
                    draw->content_length, draw->content_length > 0 ? text : muted, 0);

    if (draw->focused) {
      fill_rect(renderer,
                (SDL_FRect){rect.x + rect.w - 16.0f, rect.y + 10.0f, 2.0f, rect.h - 20.0f},
                named_color("focus_ring", 255));
    }
    return;
  }

  if (strcmp(draw->draw_kind, "checkbox_control") == 0) {
    SDL_FRect box = {rect.x + 10.0f, rect.y + 8.0f, 18.0f, 18.0f};
    draw_surface_shell(renderer, rect, named_color("surface", 235), named_color("content", 200),
                       draw->focused, draw->disabled);
    stroke_rect(renderer, box, named_color("content", 220));

    if (draw->checked || draw->selected) {
      fill_inset_rect(renderer, box, 4.0f, named_color("accent", 240));
    }

    draw_text_bands(renderer,
                    (SDL_FRect){rect.x + 38.0f, rect.y + 8.0f, rect.w - 48.0f, rect.h - 16.0f},
                    draw->content_length, text, 0);
    return;
  }

  if (strcmp(draw->draw_kind, "tabs_surface") == 0) {
    draw_surface_shell(renderer, rect, named_color("surface", 210), named_color("content", 180), 0,
                       0);
    draw_item_rows(renderer, (SDL_FRect){rect.x + 6.0f, rect.y + 6.0f, rect.w - 12.0f, rect.h - 12.0f},
                   draw->item_count, draw->current_index, draw->selected_index,
                   named_color("canvas", 180), named_color("accent", 220));
    return;
  }

  if (strcmp(draw->draw_kind, "list_surface") == 0 || strcmp(draw->draw_kind, "menu_surface") == 0) {
    draw_surface_shell(renderer, rect, named_color("surface", 230), named_color("muted", 200), 0,
                       0);
    draw_item_rows(renderer, rect, draw->item_count, draw->current_index, draw->selected_index,
                   named_color("canvas", 160), named_color("selection", 220));
    return;
  }

  if (strcmp(draw->draw_kind, "table_surface") == 0 ||
      strcmp(draw->draw_kind, "process_monitor_surface") == 0) {
    draw_surface_shell(renderer, rect, named_color("surface", 230), named_color("muted", 210), 0,
                       0);
    draw_table_grid(renderer, rect, draw->column_count, draw->row_count,
                    named_color("muted", 150), named_color("accent", 210));
    return;
  }

  if (strcmp(draw->draw_kind, "log_viewer_surface") == 0) {
    draw_surface_shell(renderer, rect, named_color("canvas", 255), named_color("muted", 180), 0,
                       0);
    draw_item_rows(renderer, rect, draw->row_count, -1, -1, named_color("surface", 180),
                   named_color("selection", 220));
    return;
  }

  if (strcmp(draw->draw_kind, "cluster_dashboard_surface") == 0) {
    int count = draw->item_count > 0 ? draw->item_count : 2;
    float card_width = SDL_max((rect.w - 24.0f) / (float)count, 64.0f);
    draw_surface_shell(renderer, rect, named_color("surface", 235), named_color("muted", 200), 0,
                       0);

    for (int index = 0; index < count; index++) {
      SDL_FRect card = {rect.x + 8.0f + (float)index * card_width, rect.y + 18.0f, card_width - 8.0f,
                        rect.h - 28.0f};
      draw_surface_shell(renderer, card, named_color("canvas", 220), named_color("content", 180),
                         0, 0);
      fill_rect(renderer, (SDL_FRect){card.x + 8.0f, card.y + 8.0f, 12.0f, 12.0f},
                index == 0 ? named_color("success", 230) : named_color("warning", 230));
      draw_text_bands(renderer,
                      (SDL_FRect){card.x + 28.0f, card.y + 6.0f, card.w - 36.0f, card.h - 12.0f},
                      20 + index * 3, named_color("content", 230), 0);
    }
    return;
  }

  if (strcmp(draw->draw_kind, "command_palette_surface") == 0) {
    draw_surface_shell(renderer, rect, named_color("surface", 245), named_color("content", 220), 0,
                       0);
    draw_surface_shell(renderer,
                       (SDL_FRect){rect.x + 10.0f, rect.y + 10.0f, rect.w - 20.0f, 36.0f},
                       named_color("canvas", 255), named_color("muted", 200), 0, 0);
    draw_text_bands(renderer,
                    (SDL_FRect){rect.x + 18.0f, rect.y + 16.0f, rect.w - 36.0f, 20.0f},
                    draw->content_length, text, 0);
    draw_item_rows(renderer,
                   (SDL_FRect){rect.x + 10.0f, rect.y + 54.0f, rect.w - 20.0f, rect.h - 64.0f},
                   draw->item_count, draw->current_index, draw->selected_index,
                   named_color("canvas", 170), named_color("selection", 220));
    return;
  }

  if (strcmp(draw->draw_kind, "gauge_surface") == 0) {
    draw_surface_shell(renderer, rect, named_color("surface", 235), named_color("muted", 200), 0,
                       0);
    draw_text_bands(renderer,
                    (SDL_FRect){rect.x + 12.0f, rect.y + 10.0f, rect.w - 24.0f, 18.0f},
                    draw->content_length, text, 1);
    draw_progress_bar(renderer, rect, draw->value, draw->max_value, named_color("canvas", 190),
                      named_color("accent", 245));
    return;
  }

  if (strcmp(draw->draw_kind, "positioned_fragment") == 0) {
    draw_surface_shell(renderer, rect, named_color("accent", 140), named_color("content", 220), 0,
                       0);
    draw_text_bands(renderer, rect, draw->content_length, named_color("content", 235), 0);
    return;
  }

  draw_surface_shell(renderer, rect, surface, stroke, draw->focused, draw->disabled);
  draw_text_bands(renderer, rect, draw->content_length, text, 0);
}

static void render_window(dui_frame *frame, int window_index) {
  dui_window *window = &frame->windows[window_index];
  fill_rect(window->renderer, (SDL_FRect){0.0f, 0.0f, (float)window->width, (float)window->height},
            named_color("canvas", 255));

  for (int i = 0; i < frame->draw_count; i++) {
    dui_draw *draw = &frame->draws[i];
    if (strcmp(draw->window_id, window->window_id) != 0) {
      continue;
    }

    if (draw->clip) {
      SDL_Rect clip = {draw->clip_x, draw->clip_y, draw->clip_width, draw->clip_height};
      SDL_SetRenderClipRect(window->renderer, &clip);
    } else {
      SDL_SetRenderClipRect(window->renderer, NULL);
    }

    render_draw_operation(window->renderer, draw);
  }

  SDL_SetRenderClipRect(window->renderer, NULL);
  SDL_RenderPresent(window->renderer);
}

static void decode_value(char *value) {
  char *source = value;
  char *target = value;

  while (*source != '\0') {
    if (*source == '%' && source[1] != '\0' && source[2] != '\0') {
      char hex[3] = {source[1], source[2], '\0'};
      *target++ = (char)strtol(hex, NULL, 16);
      source += 3;
    } else if (*source == '+') {
      *target++ = ' ';
      source++;
    } else {
      *target++ = *source++;
    }
  }

  *target = '\0';
}
