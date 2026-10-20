ESCAPES = {"n": "\n", "t": "\t", "\\": "\\", '"': '"'}


def desescapar(s: str) -> str:
    """Troca sequências como \\n pelo caractere correspondente.

    Levanta ValueError se encontrar um escape desconhecido.
    """
    saida = []
    i = 0
    while i < len(s):
        if s[i] == "\\":
            i += 1
            # BUG proposital: não confere se ainda existe um caractere
            # depois da barra.
            proximo = s[i]
            if proximo not in ESCAPES:
                raise ValueError(f"escape desconhecido: \\{proximo}")
            saida.append(ESCAPES[proximo])
        else:
            saida.append(s[i])
        i += 1
    return "".join(saida)
