package tuic

func (t *PoolClient) Close() error {
	t.closeClients(false)
	t.closeClients(true)
	return nil
}

func (t *PoolClient) closeClients(udp bool) {
	clients := &t.tcpClients
	clientsMutex := &t.tcpClientsMutex
	if udp {
		clients = &t.udpClients
		clientsMutex = &t.udpClientsMutex
	}
	clientsMutex.Lock()
	defer clientsMutex.Unlock()
	for it := clients.Front(); it != nil; it = it.Next() {
		if it.Value != nil {
			it.Value.Close()
		}
	}
	clients.Init()
}
