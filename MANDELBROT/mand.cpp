#include <SDL2/SDL.h>
#include <immintrin.h>
#include <math.h>
#include <stdio.h>
#include <string.h>

#define MAX_ITER  256
#define MAX_RADIUS 100


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

    const int help_mas[8] = {0, 1, 2, 3, 4, 5, 6, 7};
    float virtual_x[8] = {};
    float virtual_y[8] = {};
    float new_x[8] = {};
    float new_y[8] = {};
    int iteration[8] = {};
    unsigned char mas_flag = 0;

    float offset_x = 0;
    float offset_y = 0;

    float var = 0;
    float zoom = 1;    

    while (running) 
    {
        for (long y = 0; y < height; y++) 
        {
            for (int i = 0; i < 8; i++)
                virtual_y[i] = offset_y + (y - height/2) * step * zoom;

            for (long x = 0; x < width; x += 8) 
            {
                for (int i = 0; i < 8; i++)
                    virtual_x[i] = offset_x + (x + help_mas[i] - width/2) * step * zoom;

                mas_flag = 0;
                memset(iteration, 0, 8*sizeof(int));
                memset(new_x, 0, 8*sizeof(float));
                memset(new_y, 0, 8*sizeof(float));

                for(int iter_counter = 0; mas_flag != 255 && iter_counter < 256; iter_counter++)
                {
                    for (int i = 0; i < 8; i++)
                    {
                        if (mas_flag & (1 << (7 - i)))
                            continue;

                        var = new_x[i]*new_x[i] - new_y[i]*new_y[i] + virtual_x[i];
                        new_y[i] = 2*new_x[i]*new_y[i] + virtual_y[i];
                        new_x[i] = var;

                        if (new_x[i]*new_x[i] + new_y[i]*new_y[i] >= MAX_RADIUS)
                        {
                            mas_flag += (1 << (7 - i));
                            iteration[i] = iter_counter;
                        }
                    }
                }

                for (int i = 0; i < 8; i++) 
                    if (iteration[i] == 0) 
                        iteration[i] = MAX_ITER;


                // printf ("iteration = %d\n", iteration);
                // printf("virtual_x = %lf, y = %lf", virtual_x, virtual_y);
                for (int i = 0; i < 8; i++)
                {
                    if (iteration[i] == MAX_ITER) 
                        pixels[y * width + (x + help_mas[i])] = 0xFF000000;

                    else
                    {
                        int color = 0xFF000000 + (iteration[i] << 30) + (iteration[i] << 20) + (iteration[i] << 10);
                        pixels[y  * width + (x + help_mas[i])] = color;
                    }

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