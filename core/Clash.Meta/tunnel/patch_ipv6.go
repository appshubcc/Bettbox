package tunnel

import (
	"github.com/metacubex/mihomo/component/resolver"
	C "github.com/metacubex/mihomo/constant"
)

func shouldRejectIPv6UDP(metadata *C.Metadata) bool {
	if !resolver.DisableIPv6 || metadata.Type != C.TUN {
		return false
	}
	ip := metadata.DstIP
	return ip.Is6() && !ip.Is4In6() && ip.IsGlobalUnicast() && !ip.IsPrivate()
}

func rejectIPv6UDP(packet C.PacketAdapter) {
	if rejector, ok := packet.(C.PacketRejector); ok {
		_ = rejector.Reject()
	}
	packet.Drop()
}
