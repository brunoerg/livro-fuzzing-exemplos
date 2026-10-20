package moeda

import "testing"

func FuzzRoundTrip(f *testing.F) {
	f.Add(int64(1234)) // seed
	f.Fuzz(func(t *testing.T, c int64) {
		texto := FormatarCentavos(c)
		volta, err := LerCentavos(texto)
		if err != nil {
			t.Fatalf("LerCentavos(%q): %v", texto, err)
		}
		if volta != c {
			t.Fatalf("%d -> %q -> %d", c, texto, volta)
		}
	})
}
