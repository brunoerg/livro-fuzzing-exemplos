/// Uma conta com cheque especial: permite sacar até 100 além do saldo.
pub struct Conta {
    saldo: u32,
}

impl Conta {
    pub fn new() -> Self {
        Conta { saldo: 0 }
    }

    pub fn depositar(&mut self, valor: u32) {
        self.saldo = self.saldo.saturating_add(valor);
    }

    pub fn sacar(&mut self, valor: u32) -> bool {
        // BUG proposital: o limite permite um saldo negativo,
        // mas o saldo é um inteiro sem sinal (u32).
        if valor > self.saldo.saturating_add(100) {
            return false;
        }
        self.saldo -= valor;
        true
    }

    pub fn saldo(&self) -> u32 {
        self.saldo
    }
}
