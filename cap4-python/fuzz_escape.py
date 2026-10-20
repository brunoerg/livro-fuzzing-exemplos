import sys

import atheris

with atheris.instrument_imports():
    from escape import desescapar


def TestOneInput(data: bytes) -> None:
    fdp = atheris.FuzzedDataProvider(data)
    texto = fdp.ConsumeUnicodeNoSurrogates(256)
    try:
        desescapar(texto)
    except ValueError:
        pass  # erro documentado: entrada inválida, não é bug


atheris.Setup(sys.argv, TestOneInput)
atheris.Fuzz()
