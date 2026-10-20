# Fuzzing: Conceitos e Prática — exemplos

Código dos exemplos do livro *Fuzzing: Conceitos e Prática*, de Bruno Garcia. Cada pasta corresponde a um capítulo, e o `Makefile` compila os exemplos e confere que cada fuzzer encontra o bug esperado.

## Rodando com Docker (recomendado)

A imagem traz clang/libFuzzer, AFL++ (com o modo QEMU), Go e Atheris. Você não precisa instalar mais nada.

```bash
git clone https://github.com/brunoerg/livro-fuzzing-exemplos.git
cd livro-fuzzing-exemplos

docker build -t livro-fuzzing .
docker run --rm -it -v "$PWD:/exemplos" livro-fuzzing
```

Dentro do container:

```bash
make test test-go test-python test-aflpp
```

A pasta do repositório é montada em `/exemplos`, então os arquivos que o fuzzer gera (corpus, crashes) aparecem também na sua máquina. Para seguir um capítulo passo a passo, entre na pasta dele e rode os comandos do livro, por exemplo:

```bash
cd cap3-primeiro-target
clang++ -g -O1 -fsanitize=fuzzer,address alvo.cc -o fuzzer
mkdir corpus
./fuzzer corpus/
```

## Rodando sem Docker

| Para | Instale |
| --- | --- |
| C/C++ (`make test`) | `clang` com libFuzzer e zlib. No Ubuntu: `apt install clang libclang-rt-dev zlib1g-dev` |
| Go (`make test-go`) | Go 1.18 ou mais novo |
| Python (`make test-python`) | `pip install atheris` |
| AFL++ (`make test-aflpp`) | [AFL++](https://github.com/AFLplusplus/AFLplusplus), com o modo QEMU para o último teste |
| Rust (`make test-rust`) | `rustup toolchain install nightly` e `cargo install cargo-fuzz` |

O exemplo em Rust não roda no Docker: use o Rust nightly da sua máquina.

## Exemplos

| Pasta | Seção | O que o teste confere |
| --- | --- | --- |
| `cap2-custom-mutator/` | 2.3 | Com `-DCUSTOM_MUTATOR`, o libFuzzer acha o crash do `CompressedTest.cpp`; sem o mutador, não acha |
| `cap2-arbitrary/` (Rust) | 2.3 | `make test-rust`: o `cargo fuzz` acha o `attempt to subtract with overflow` |
| `cap3-primeiro-target/alvo.cc` | 3.2 a 3.4 | Acha um `stack-buffer-overflow` em `alvo.cc:11` |
| `cap3-primeiro-target/fdp_exemplo.cc` | 3.5 | Roda sem crash (exemplo de `FuzzedDataProvider`) |
| `cap3-primeiro-target/fuzz.dict` | 3.6 | Dicionário de exemplo |
| `cap4-go/` | 4.1 | `make test-go`: o round-trip falha (`1301 -> "13,1" -> 1310`) |
| `cap4-python/` | 4.1 | `make test-python`: o Atheris acha o `IndexError` |
| `cap4-aflpp/` | 4.2 | `make test-aflpp`: o AFL++ acha o overflow no harness, no programa com `@@`, em modo persistente e no modo QEMU |
| `cap6-checksum/` | 6.6 | Com `-DFUZZING_BUILD_MODE_UNSAFE_FOR_PRODUCTION`, acha o overflow escondido atrás do CRC32; sem a macro, não passa do checksum |

`make clean` apaga binários, corpus e crashes.

## Licença

O `cap2-custom-mutator/CompressedTest.cpp` é do projeto LLVM (Apache 2.0 com exceção LLVM), e o cabeçalho de licença foi mantido.
