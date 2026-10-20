// Package moeda converte valores em centavos para texto ("12,34") e de volta.
package moeda

import (
	"errors"
	"fmt"
	"strconv"
	"strings"
)

// FormatarCentavos converte 1234 em "12,34".
func FormatarCentavos(c int64) string {
	// BUG proposital: %d não completa com zero à esquerda,
	// então 1205 vira "12,5" em vez de "12,05".
	return fmt.Sprintf("%d,%d", c/100, c%100)
}

// LerCentavos converte "12,34" em 1234 e "12,5" em 1250.
func LerCentavos(s string) (int64, error) {
	reais, centavos, ok := strings.Cut(s, ",")
	if !ok {
		return 0, errors.New("valor sem vírgula")
	}
	r, err := strconv.ParseInt(reais, 10, 64)
	if err != nil {
		return 0, err
	}
	if len(centavos) < 1 || len(centavos) > 2 {
		return 0, errors.New("centavos precisam ter 1 ou 2 dígitos")
	}
	c, err := strconv.ParseUint(centavos, 10, 64)
	if err != nil {
		return 0, err
	}
	if len(centavos) == 1 {
		c *= 10 // "12,5" é o mesmo que "12,50"
	}
	return r*100 + int64(c), nil
}
