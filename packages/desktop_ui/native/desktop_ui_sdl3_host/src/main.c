#define SDL_MAIN_USE_CALLBACKS 1
#include <SDL3/SDL.h>
#include <SDL3/SDL_main.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#define MAX_WINDOWS 16
#define MAX_DRAWS 512
#define MAX_LINE 2048

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
  int x;
  int y;
  int width;
  int height;
  int clip;
  char bg[64];
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
static void apply_draw_color(SDL_Renderer *renderer, const char *bg, const char *draw_kind);
static void render_window(dui_frame *frame, int window_index);
static void destroy_frame_windows(dui_frame *frame);
static void print_probe(void);

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
      char attrs[16][2][256];
      int count = parse_attrs(line + 7, attrs, 16);

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
      char attrs[24][2][256];
      int count = parse_attrs(line + 5, attrs, 24);

      copy_attr(draw->window_id, sizeof(draw->window_id), attrs, count, "window_id",
                "window:desktop-ui");
      copy_attr(draw->draw_kind, sizeof(draw->draw_kind), attrs, count, "draw_kind",
                "widget_placeholder");
      copy_attr(draw->kind, sizeof(draw->kind), attrs, count, "kind", "widget");
      copy_attr(draw->bg, sizeof(draw->bg), attrs, count, "bg", "canvas");
      draw->x = int_attr(attrs, count, "x", 0);
      draw->y = int_attr(attrs, count, "y", 0);
      draw->width = int_attr(attrs, count, "width", 240);
      draw->height = int_attr(attrs, count, "height", 48);
      draw->clip = int_attr(attrs, count, "clip", 0);
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

static void apply_draw_color(SDL_Renderer *renderer, const char *bg, const char *draw_kind) {
  if (strcmp(draw_kind, "window_chrome") == 0) {
    SDL_SetRenderDrawColor(renderer, 46, 51, 64, 255);
  } else if (strcmp(draw_kind, "layer_surface") == 0) {
    SDL_SetRenderDrawColor(renderer, 66, 74, 96, 255);
  } else if (strcmp(draw_kind, "viewport_region") == 0) {
    SDL_SetRenderDrawColor(renderer, 53, 95, 140, 255);
  } else if (bg != NULL && strcmp(bg, "panel") == 0) {
    SDL_SetRenderDrawColor(renderer, 76, 84, 102, 255);
  } else if (bg != NULL && strcmp(bg, "surface") == 0) {
    SDL_SetRenderDrawColor(renderer, 90, 98, 118, 255);
  } else if (bg != NULL && strcmp(bg, "accent") == 0) {
    SDL_SetRenderDrawColor(renderer, 70, 132, 247, 255);
  } else {
    SDL_SetRenderDrawColor(renderer, 114, 123, 145, 255);
  }
}

static void render_window(dui_frame *frame, int window_index) {
  dui_window *window = &frame->windows[window_index];
  SDL_SetRenderDrawColor(window->renderer, 28, 32, 43, 255);
  SDL_RenderClear(window->renderer);

  for (int i = 0; i < frame->draw_count; i++) {
    dui_draw *draw = &frame->draws[i];
    if (strcmp(draw->window_id, window->window_id) != 0) {
      continue;
    }

    SDL_FRect rect = {(float)draw->x, (float)draw->y, (float)draw->width, (float)draw->height};
    SDL_Rect clip = {draw->x, draw->y, draw->width, draw->height};

    if (draw->clip) {
      SDL_SetRenderClipRect(window->renderer, &clip);
    } else {
      SDL_SetRenderClipRect(window->renderer, NULL);
    }

    apply_draw_color(window->renderer, draw->bg, draw->draw_kind);
    SDL_RenderFillRect(window->renderer, &rect);

    SDL_SetRenderDrawColor(window->renderer, 220, 227, 242, 255);
    SDL_RenderRect(window->renderer, &rect);
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
