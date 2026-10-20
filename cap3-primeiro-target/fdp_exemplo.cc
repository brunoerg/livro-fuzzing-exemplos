// Capítulo 3.5: entradas estruturadas com FuzzedDataProvider.
// CadastrarUsuario é um stub só para o exemplo compilar; troque pela sua função.
#include <cstdint>
#include <cstddef>
#include <string>
#include <fuzzer/FuzzedDataProvider.h>

static void CadastrarUsuario(const std::string& nome, int idade, bool ativo) {
  (void)nome; (void)idade; (void)ativo;
}

extern "C" int LLVMFuzzerTestOneInput(const uint8_t* data, size_t size) {
  FuzzedDataProvider fdp(data, size);
  int idade = fdp.ConsumeIntegralInRange<int>(0, 130);
  bool ativo = fdp.ConsumeBool();
  std::string nome = fdp.ConsumeRandomLengthString(64);
  CadastrarUsuario(nome, idade, ativo);
  return 0;
}
