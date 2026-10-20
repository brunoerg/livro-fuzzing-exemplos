// Um programa comum: lê a mensagem de um arquivo passado na linha de comando.
#include <cstdio>
#include "mensagem.h"

int main(int argc, char** argv) {
    if (argc < 2)
        return 1;
    FILE* f = fopen(argv[1], "rb");
    if (!f)
        return 1;
    uint8_t buf[4096];
    size_t n = fread(buf, 1, sizeof(buf), f);
    fclose(f);
    lerMensagem(buf, n);
    return 0;
}
