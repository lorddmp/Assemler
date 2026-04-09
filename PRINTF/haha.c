extern int my_printf(const char* string, ...);

int main() {
    int a = my_printf("MY PERFECT RESULT: %d, %s, %x, %o, %b, %d, %d, %c\n", -1, "hahaha", 17, 17, 17, 100, -1000, 'A');
    return 0;
}
