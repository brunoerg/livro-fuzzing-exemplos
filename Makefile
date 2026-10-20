# Exemplos do livro "Fuzzing: Conceitos e Prática".
#
#   make          compila todos os exemplos
#   make test     compila e confirma que cada fuzzer encontra o bug esperado
#   make clean    apaga binários, corpus e crashes
#   make test-rust confirma que o exemplo em Rust (Arbitrary) acha o bug
#                 (requer Rust nightly e cargo-fuzz; não roda no Docker)
#   make test-go     confirma que o exemplo em Go (round-trip) acha o bug
#   make test-python confirma que o exemplo em Python (Atheris) acha o bug
#                 (requer `pip install atheris`)
#   make test-aflpp  confirma que o AFL++ acha o bug no harness, no programa
#                 em persistent mode e no binário sem instrumentação (QEMU)
#                 (requer AFL++)
#
# Requer clang com libFuzzer (no Ubuntu: apt install clang libclang-rt-dev zlib1g-dev).
# O Dockerfile na raiz do repositório traz tudo, menos o Rust:
#   make test test-go test-python test-aflpp

CXX      := clang++
FUZZ     := -g -O1 -fsanitize=fuzzer,address
OUT      := build

BINS := $(OUT)/alvo $(OUT)/fdp_exemplo \
        $(OUT)/compressed_sem_mutator $(OUT)/compressed_com_mutator \
        $(OUT)/pacote_com_macro $(OUT)/pacote_sem_macro

all: $(BINS)

$(OUT):
	mkdir -p $(OUT)

$(OUT)/alvo: cap3-primeiro-target/alvo.cc | $(OUT)
	$(CXX) $(FUZZ) $< -o $@

$(OUT)/fdp_exemplo: cap3-primeiro-target/fdp_exemplo.cc | $(OUT)
	$(CXX) $(FUZZ) $< -o $@

$(OUT)/compressed_sem_mutator: cap2-custom-mutator/CompressedTest.cpp | $(OUT)
	$(CXX) $(FUZZ) $< -lz -o $@

$(OUT)/compressed_com_mutator: cap2-custom-mutator/CompressedTest.cpp | $(OUT)
	$(CXX) $(FUZZ) -DCUSTOM_MUTATOR $< -lz -o $@

$(OUT)/pacote_com_macro: cap6-checksum/pacote.cc | $(OUT)
	$(CXX) $(FUZZ) -DFUZZING_BUILD_MODE_UNSAFE_FOR_PRODUCTION $< -lz -o $@

$(OUT)/pacote_sem_macro: cap6-checksum/pacote.cc | $(OUT)
	$(CXX) $(FUZZ) $< -lz -o $@

# Cada teste roda o fuzzer por no máximo 60 s e espera um crash (código de saída != 0).
test: all
	@echo "== alvo.cc deve achar um stack-buffer-overflow"
	@cd $(OUT) && ! ./alvo -max_total_time=60 -artifact_prefix=alvo- > alvo.log 2>&1 \
		&& grep -q "stack-buffer-overflow" alvo.log && echo "ok"
	@echo "== fdp_exemplo deve rodar sem crash por 5 s"
	@cd $(OUT) && ./fdp_exemplo -max_total_time=5 > fdp.log 2>&1 && echo "ok"
	@echo "== custom mutator deve achar o crash do CompressedTest"
	@cd $(OUT) && ! ./compressed_com_mutator -max_total_time=60 -artifact_prefix=compressed- > compressed.log 2>&1 \
		&& grep -q "deadly signal" compressed.log && echo "ok"
	@echo "== checksum: com a macro de fuzzing, deve achar o overflow"
	@cd $(OUT) && ! ./pacote_com_macro -max_total_time=60 -artifact_prefix=pacote- > pacote_com.log 2>&1 \
		&& grep -q "stack-buffer-overflow" pacote_com.log && echo "ok"
	@echo "== checksum: sem a macro, não deve passar do CRC em 20 s"
	@cd $(OUT) && ./pacote_sem_macro -max_total_time=20 > pacote_sem.log 2>&1 && echo "ok"

# Exemplo em Rust: requer `rustup toolchain install nightly` e `cargo install cargo-fuzz`.
test-rust:
	@echo "== cap2-arbitrary deve achar o 'subtract with overflow'"
	@cd cap2-arbitrary && ! cargo +nightly fuzz run operacoes -- -max_total_time=60 > ../$(OUT)/arbitrary.log 2>&1 \
		&& grep -q "attempt to subtract with overflow" ../$(OUT)/arbitrary.log && echo "ok"

# Exemplo em Go: requer Go 1.18 ou mais novo.
test-go: | $(OUT)
	@echo "== cap4-go deve achar a falha no round-trip"
	@rm -rf cap4-go/testdata
	@cd cap4-go && ! go test -fuzz=FuzzRoundTrip -fuzztime=60s > ../$(OUT)/go.log 2>&1 \
		&& grep -q "Failing input written" ../$(OUT)/go.log && echo "ok"
	@rm -rf cap4-go/testdata

# Exemplo em Python: requer `pip install atheris`.
test-python: | $(OUT)
	@echo "== cap4-python deve achar o IndexError"
	@cd cap4-python && ! python3 fuzz_escape.py -max_total_time=60 -artifact_prefix=../$(OUT)/python- > ../$(OUT)/python.log 2>&1 \
		&& grep -q "IndexError" ../$(OUT)/python.log && echo "ok"

# Exemplos do AFL++ (Seção 4.2). Cada campanha roda por 30 s e deve salvar um crash.
AFL_ENV := AFL_SKIP_CPUFREQ=1 AFL_I_DONT_CARE_ABOUT_MISSING_CRASHES=1 AFL_NO_UI=1
test-aflpp: | $(OUT)
	@echo "== AFL++ deve achar o overflow nas quatro variantes"
	@cd cap4-aflpp && AFL_USE_ASAN=1 afl-clang-fast++ -g -fsanitize=fuzzer ../cap3-primeiro-target/alvo.cc -o ../$(OUT)/alvo_afl
	@cd cap4-aflpp && AFL_USE_ASAN=1 afl-clang-fast++ -g leitor.cc -o ../$(OUT)/leitor
	@cd cap4-aflpp && AFL_USE_ASAN=1 afl-clang-fast++ -g leitor_persistente.cc -o ../$(OUT)/leitor_persistente
	@cd cap4-aflpp && g++ -O1 leitor.cc -o ../$(OUT)/leitor_sem_instrumentacao
	@for v in "alvo:./alvo_afl" "leitor:./leitor @@" "persistente:./leitor_persistente" "qemu:-Q ./leitor_sem_instrumentacao @@"; do \
		n=$${v%%:*}; cmd=$${v#*:}; rm -rf $(OUT)/afl_$$n; \
		case "$$cmd" in -Q*) q=-Q; cmd=$${cmd#-Q };; *) q=;; esac; \
		(cd $(OUT) && $(AFL_ENV) afl-fuzz $$q -i ../cap4-aflpp/seeds -o afl_$$n -V 30 -- $$cmd > afl_$$n.log 2>&1); \
		if ls $(OUT)/afl_$$n/default/crashes/id* > /dev/null 2>&1; then echo "ok ($$n)"; else echo "FALHOU ($$n)"; exit 1; fi; \
	done

clean:
	rm -rf $(OUT) cap2-arbitrary/fuzz/artifacts cap2-arbitrary/fuzz/corpus \
		cap4-go/testdata cap4-python/__pycache__

.PHONY: all test test-rust test-go test-python test-aflpp clean
