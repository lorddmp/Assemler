extern int my_printf(const char* string, ...);

int main() {
    int a = my_printf("%c, %s, %x, %o, %b, %d", 'A', "hahaha", 17, 17, 17, 100 + 200);
    return 0;
}
