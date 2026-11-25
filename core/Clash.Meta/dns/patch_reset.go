package dns

func (r *Resolver) resetClients() {
	if len(r.transports) > 0 {
		for _, c := range r.transports {
			c.ResetConnection()
		}
		return
	}
	for _, c := range r.main {
		c.ResetConnection()
	}
	for _, c := range r.fallback {
		c.ResetConnection()
	}
}
