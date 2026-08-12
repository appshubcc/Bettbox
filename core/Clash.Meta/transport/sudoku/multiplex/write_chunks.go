package multiplex

import "io"

func writeAllChunks(w io.Writer, chunks ...[]byte) error {
	for _, chunk := range chunks {
		if _, err := w.Write(chunk); err != nil {
			return err
		}
	}
	return nil
}
