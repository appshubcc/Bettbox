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
