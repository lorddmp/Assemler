#include <SDL2/SDL.h>
#include <math.h>

#define MAX_ITER  256
#define MAX_RADIUS 4

int main() 
{
    SDL_Init(SDL_INIT_VIDEO);

    int width = 1980;
    int height = 1080;

    SDL_Window *window = NULL;
    SDL_Renderer *renderer = NULL;
    SDL_CreateWindowAndRenderer(width, height, 0, &window, &renderer);
    SDL_SetWindowTitle(window, "x < y : красный, иначе синий");

    SDL_Texture *texture = SDL_CreateTexture(renderer,
                                             SDL_PIXELFORMAT_ARGB8888,
                                             SDL_TEXTUREACCESS_STREAMING,
                                             width, height);

    Uint32 *pixels = (Uint32*)malloc(width * height * sizeof(Uint32));

    SDL_Event event;
    int running = 1;

    long virtual_x = -540;
    long virtual_y = -980;

    int new_x, new_y = 0;
    int iteration = 0, var = 0;
    

    while (running) 
    {
        for (long y = 0; y < height; y++, virtual_y++) 
        {
            for (long x = 0; x < width; x++, virtual_x++) 
            {
                iteration = 0;
                new_x = virtual_x;
                new_y = virtual_y;

                for(; iteration < MAX_ITER; iteration++)
                {
                    var = new_x*new_x - new_y*new_y;
                    new_y = 2*new_x*new_y;
                    new_x = var;

                    if (new_x*new_x + new_y*new_y >= MAX_RADIUS)
                        break;
                }

                if (iteration == MAX_ITER) 
                    pixels[y * width + x] = 0xFF000000;
                else
                {
                    int r = (iteration * 255) / MAX_ITER;
                    int b = 255 - r;
                    int color = 0xFF000000 | (r << 16) | (0 << 8) | b;
                    pixels[y * width + x] = color;
                }
            }
        }

        SDL_UpdateTexture(texture, NULL, pixels, width * sizeof(Uint32));

        SDL_RenderCopy(renderer, texture, NULL, NULL);
        SDL_RenderPresent(renderer);

        while (SDL_PollEvent(&event))
            if (event.type == SDL_QUIT) 
                running = 0;

        const Uint8* keys = SDL_GetKeyboardState(NULL);
        if (keys[SDL_SCANCODE_W]) virtual_y -= 100;
        if (keys[SDL_SCANCODE_S]) virtual_y += 100;
        if (keys[SDL_SCANCODE_A]) virtual_x += 100;
        if (keys[SDL_SCANCODE_D]) virtual_x -= 100;
        if (keys[SDL_SCANCODE_ESCAPE]) running = 0;

        }

    free(pixels);
    SDL_DestroyTexture(texture);
    SDL_DestroyRenderer(renderer);
    SDL_DestroyWindow(window);
    SDL_Quit();
    return 0;
}