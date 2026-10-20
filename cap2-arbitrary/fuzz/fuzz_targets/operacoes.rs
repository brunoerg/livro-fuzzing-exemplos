#![no_main]

use arbitrary::Arbitrary;
use conta::Conta;
use libfuzzer_sys::fuzz_target;

#[derive(Arbitrary, Debug)]
enum Operacao {
    Depositar(u32),
    Sacar(u32),
}

fuzz_target!(|operacoes: Vec<Operacao>| {
    let mut conta = Conta::new();
    for op in operacoes {
        match op {
            Operacao::Depositar(valor) => conta.depositar(valor),
            Operacao::Sacar(valor) => {
                conta.sacar(valor);
            }
        }
    }
});
