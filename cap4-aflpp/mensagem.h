// Mesma função do alvo.cc (Capítulo 3), com o mesmo bug proposital.
#include <cstdint>
#include <cstddef>
#include <cstring>

__attribute__((noinline))
void copiar(const uint8_t* src, size_t tamanho) {
    char conteudo[8];
    // BUG proposital: tamanho pode ser maior que 8.
    memcpy(conteudo, src, tamanho);
    asm volatile("" : : "r"(conteudo) : "memory");
}

bool lerMensagem(const uint8_t* data, size_t size) {
    if (size < 5)
        return false;
    if (memcmp(data, "FUZZ", 4) != 0)
        return false;
    uint8_t tamanho = data[4];
    if (size < 5 + tamanho)
        return false;
    if (tamanho == 0)
        return false;
    copiar(data + 5, tamanho);
    return true;
}
