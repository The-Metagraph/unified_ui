#include <SDL3/SDL.h>
#include <stdio.h>
#include <string.h>

static void print_probe(void) {
  printf(
      "{\"host\":\"desktop_ui_sdl3_host\",\"status\":\"build_ready\",\"launch_ready\":false,"
      "\"backend\":\"compiled_sdl3_host\",\"compiled_with\":\"SDL3 %d.%d.%d\"}\n",
      SDL_MAJOR_VERSION, SDL_MINOR_VERSION, SDL_MICRO_VERSION);
}

int main(int argc, char **argv) {
  if (argc > 1 && strcmp(argv[1], "--probe") == 0) {
    print_probe();
    return 0;
  }

  if (argc > 1 && strcmp(argv[1], "--version") == 0) {
    printf("%d.%d.%d\n", SDL_MAJOR_VERSION, SDL_MINOR_VERSION, SDL_MICRO_VERSION);
    return 0;
  }

  fprintf(stderr,
          "desktop_ui_sdl3_host is built but not yet protocol-launch-ready; use --probe for diagnostics.\n");
  return 64;
}
