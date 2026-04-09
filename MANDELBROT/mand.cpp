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

    const float help_mas[8] = {0, 1, 2, 3, 4, 5, 6, 7};
    unsigned char mask_flag = 0;

    float offset_x = 0;
    float offset_y = 0;

    float zoom = 1;    

    while (running) 
    {
        for (long y = 0; y < height; y++) 
        {
            float virtual_y = offset_y + (y - height/2) * step * zoom;
            __m256 vect_virt_y = _mm256_set1_ps(virtual_y);

            for (long x = 0; x < width; x += 8) 
            {
                float virtual_x = offset_x + (x - width/2) * step * zoom;
                __m256 vect_virt_x = _mm256_set1_ps(virtual_x);
                __m256 vect_help_mas = _mm256_loadu_ps(help_mas);
                __m256 vect_const_mas = _mm256_set1_ps(step*zoom);
                vect_help_mas = _mm256_mul_ps(vect_help_mas, vect_const_mas);
                vect_virt_x = _mm256_add_ps(vect_virt_x, vect_help_mas);

                mask_flag = 0;
                __m256 new_x = _mm256_set1_ps(0);
                __m256 new_y = _mm256_set1_ps(0);
                // __m256 iteration = _mm256_set1_ps(0);
                int iteration[8] = {};

                for (int iter_counter = 0; mask_flag != 255 && iter_counter < 256; iter_counter++)
                {
                    __m256 old_x = new_x;
                    __m256 old_y = new_y;
                    new_x = _mm256_add_ps(_mm256_sub_ps(_mm256_mul_ps(old_x, old_x), _mm256_mul_ps(old_y, old_y)), vect_virt_x);     //new_x[i]*new_x[i] - new_y[i]*new_y[i] + virtual_x[i];
                    new_y = _mm256_add_ps(_mm256_mul_ps(_mm256_mul_ps(_mm256_set1_ps(2), old_x), old_y), vect_virt_y);                                      //2*new_x[i]*new_y[i] + virtual_y[i];

                    int mask = _mm256_movemask_ps(_mm256_cmp_ps(_mm256_add_ps(_mm256_mul_ps(new_x, new_x), _mm256_mul_ps(new_y, new_y)), _mm256_set1_ps(MAX_RADIUS), _CMP_GE_OQ));

                    for (int i = 0; i < 8; i++)
                    {
                        if ( !(mask_flag & (1 << i)) && ((mask >> i) & 1) ) 
                        {
                            mask_flag |= (1 << i);
                            iteration[i] = iter_counter;
                        }
                    }
                }

                for (int i = 0; i < 8; i++) 
                {
                    if (iteration[i] == 0) 
                        iteration[i] = MAX_ITER;
                    // printf ("%d) iteration = %d\n", i, iteration[i]);
                }


                // printf("virtual_x = %lf, y = %lf", virtual_x, virtual_y);
                for (int i = 0; i < 8; i++)
                {
                    if (iteration[i] == MAX_ITER) 
                        pixels[y * width + (x + (int)help_mas[i])] = 0xFF000000;

                    else
                    {
                        int color = 0xFF000000 | (iteration[i] << 30) | (iteration[i] << 20) | (iteration[i] << 10);
                        pixels[y  * width + (x + (int)help_mas[i])] = color;
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