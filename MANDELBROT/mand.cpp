#include <SDL2/SDL.h>
#include <math.h>
#include <stdio.h>

#define MAX_ITER  256
#define MAX_RADIUS 100

struct point:
{

}

int main() 
{
    SDL_Init(SDL_INIT_VIDEO);

    const int width = 1920;
    const int height = 1080;
    const float step = 0.01;

    SDL_Window *window = NULL;
    SDL_Renderer *renderer = NULL;
    SDL_CreateWindowAndRenderer(width, height, 0, &window, &renderer);
    SDL_SetWindowTitle(window, "Mandelbrot");

    SDL_Texture *texture = SDL_CreateTexture(renderer,
                                             SDL_PIXELFORMAT_ARGB8888,
                                             SDL_TEXTUREACCESS_STREAMING,
                                             width, height);

    Uint32 *pixels = (Uint32*)malloc(width * height * sizeof(Uint32));

    SDL_Event event;
    int running = 1;

    float* virtual_x = -9.6;
    float virtual_y = -5.4;
    float offset_x = 0;
    float offset_y = 0;

    float new_x, new_y, var = 0;
    float zoom = 1;    
    long int iteration = 0;

    while (running) 
    {
        for (long y = 0; y < height; y++, virtual_y += step * zoom) 
        {
            virtual_y = offset_y + (y - height/2) * step * zoom;
            for (long x = 0; x < width; x++, virtual_x += step * zoom) 
            {
                virtual_x = offset_x + (x - width/2) * step * zoom;
                iteration = 0;
                new_x = 0;
                new_y = 0;

                for(; iteration < MAX_ITER; iteration++)
                {
                    var = new_x*new_x - new_y*new_y + virtual_x;
                    new_y = 2*new_x*new_y + virtual_y;
                    new_x = var;

                    if (new_x*new_x + new_y*new_y >= MAX_RADIUS)
                        break;
                }

                // printf ("iteration = %d\n", iteration);
                // printf("virtual_x = %lf, y = %lf", virtual_x, virtual_y);

                if (iteration == MAX_ITER) 
                    pixels[y * width + x] = 0xFF000000;

                else
                {
                    int color = 0xFF000000 + (iteration << 30) + (iteration << 20) + (iteration << 10);
                    pixels[y * width + x] = color;
                }
            }
        }

        SDL_UpdateTexture(texture, NULL, pixels, width * sizeof(Uint32));

        SDL_RenderCopy(renderer, texture, NULL, NULL);
        SDL_RenderPresent(renderer);

        while(SDL_PollEvent(&event))
            if (event.type == SDL_QUIT) 
                running = 0;

        const Uint8* keys = SDL_GetKeyboardState(NULL);
        if (keys[SDL_SCANCODE_W]) offset_y -= 0.1*zoom;
        if (keys[SDL_SCANCODE_S]) offset_y += 0.1*zoom;
        if (keys[SDL_SCANCODE_A]) offset_x -= 0.1*zoom;
        if (keys[SDL_SCANCODE_D]) offset_x += 0.1*zoom;
        if (keys[SDL_SCANCODE_E]) zoom *= 1.1;
        if (keys[SDL_SCANCODE_Q]) zoom /= 1.1;
        if (keys[SDL_SCANCODE_ESCAPE]) running = 0;

    }

    free(pixels);
    SDL_DestroyTexture(texture);
    SDL_DestroyRenderer(renderer);
    SDL_DestroyWindow(window);
    SDL_Quit();
    return 0;
}