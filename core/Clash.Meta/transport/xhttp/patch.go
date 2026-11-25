package xhttp

func (m *ReuseManager) CloseIdle() {
	if m == nil {
		return
	}
	m.mu.Lock()
	defer m.mu.Unlock()

	kept := m.entries[:0]
	for _, entry := range m.entries {
		if entry.isClosed() {
			continue
		}
		if entry.openUsage.Load() == 0 {
			entry.close()
			continue
		}
		kept = append(kept, entry)
	}
	m.entries = kept
}

func (c *Client) CloseIdle() {
	c.uploadManager.CloseIdle()
	c.downloadManager.CloseIdle()
}
