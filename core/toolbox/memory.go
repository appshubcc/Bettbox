package toolbox

import (
	"runtime"
	"runtime/debug"
	"sync"
	"time"
)

const toolMemoryReleaseDelay = 2 * time.Second

var (
	toolMemoryLock  sync.Mutex
	toolMemoryTimer *time.Timer
)

func releaseToolMemory() {
	toolMemoryLock.Lock()
	defer toolMemoryLock.Unlock()
	if toolMemoryTimer != nil {
		toolMemoryTimer.Stop()
	}
	toolMemoryTimer = time.AfterFunc(toolMemoryReleaseDelay, func() {
		toolMemoryLock.Lock()
		toolMemoryTimer = nil
		toolMemoryLock.Unlock()
		runtime.GC()
		debug.FreeOSMemory()
	})
}
