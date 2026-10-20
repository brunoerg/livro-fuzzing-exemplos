# Ambiente para rodar os exemplos do livro sem instalar nada na sua máquina.
# Traz clang/libFuzzer, AFL++ (com o modo QEMU), Go e Atheris.
#
#   docker build -t livro-fuzzing .
#   docker run --rm -it -v "$PWD:/exemplos" livro-fuzzing
#   # dentro do container:
#   make test test-go test-python test-aflpp
#
# O exemplo em Rust (make test-rust) precisa do Rust nightly e roda fora do Docker.

# Imagem oficial do AFL++ 5.03c (Ubuntu 24.04, clang 20), fixada pelo digest.
FROM aflplusplus/aflplusplus@sha256:07ae19760b62d785e71d42a56a267b6e1c7ca1effea6ed3694d0a469bebe5c3c

RUN apt-get update \
 && apt-get install -y --no-install-recommends golang-go zlib1g-dev make \
 && rm -rf /var/lib/apt/lists/*

RUN pip3 install --no-cache-dir atheris==3.1.0

# O afl-fuzz reclama da configuração de CPU e de core dumps dentro de containers.
ENV AFL_SKIP_CPUFREQ=1 \
    AFL_I_DONT_CARE_ABOUT_MISSING_CRASHES=1

WORKDIR /exemplos
CMD ["bash"]
