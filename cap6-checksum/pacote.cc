// Seção 6.6: um formato em que os quatro primeiros bytes são o CRC32 do resto.
//
// Compile com -DFUZZING_BUILD_MODE_UNSAFE_FOR_PRODUCTION para desligar a
// verificação do checksum no build de fuzzing; sem a macro, o fuzzer não
// passa da verificação.
#include <cstdint>
#include <cstddef>
#include <cstring>
#include <zlib.h>

uint32_t LerU32(const uint8_t* p) {
    return p[0] | (p[1] << 8) | (p[2] << 16) | ((uint32_t)p[3] << 24);
}

__attribute__((noinline))
bool processar(const uint8_t* data, size_t size) {
    if (size < 4 || memcmp(data, "PKT", 3) != 0)
        return false;

    char conteudo[8];
    uint8_t tamanho = data[3];
    if (size < 4 + tamanho)
        return false;

    // BUG proposital:
    // tamanho pode ser maior que 8.
    memcpy(conteudo, data + 4, tamanho);

    // Impede que o compilador simplesmente elimine a operação.
    asm volatile("" : : "r"(conteudo) : "memory");
    return true;
}

bool lerPacote(const uint8_t* data, size_t size) {
    if (size < 4)
        return false;
    uint32_t esperado = LerU32(data);
#ifndef FUZZING_BUILD_MODE_UNSAFE_FOR_PRODUCTION
    if (crc32(0, data + 4, size - 4) != esperado)
        return false;
#endif
    return processar(data + 4, size - 4);
}

extern "C" int LLVMFuzzerTestOneInput(const uint8_t* data, size_t size) {
    lerPacote(data, size);
    return 0;
}
