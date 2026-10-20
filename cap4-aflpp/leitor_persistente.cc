// O mesmo programa em persistent mode: muitas entradas por processo.
#include <unistd.h>
#include "mensagem.h"

__AFL_FUZZ_INIT();

int main() {
    __AFL_INIT();
    unsigned char* buf = __AFL_FUZZ_TESTCASE_BUF;
    while (__AFL_LOOP(10000)) {
        int len = __AFL_FUZZ_TESTCASE_LEN;
        lerMensagem(buf, len);
    }
    return 0;
}
