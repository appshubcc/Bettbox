package outboundgroup

import (
	"math"
	"time"

	C "github.com/metacubex/mihomo/constant"
)

const unmeasuredPickHold = time.Second

func (u *URLTest) forgetUnmeasuredPick() {
	u.fastSingle.ForgetAfter(unmeasuredPickHold, func(pick C.Proxy) bool {
		return pick.LastDelayForTestUrl(u.testUrl) == math.MaxUint16
	})
}

func (u *URLTest) keepDeadFastNode(proxies []C.Proxy, fast C.Proxy) C.Proxy {
	if u.fastNode == nil || fast.AliveForTestUrl(u.testUrl) {
		return nil
	}
	name := u.fastNode.Name()
	for _, proxy := range proxies {
		if proxy.Name() == name {
			return proxy
		}
	}
	return nil
}
