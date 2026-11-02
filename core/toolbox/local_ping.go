package toolbox

import (
	"cmp"
	"context"
	"crypto/rand"
	"encoding/binary"
	"encoding/json"
	"errors"
	"net"
	"net/netip"
	"slices"
	"sync"
	"syscall"
	"time"

	"github.com/metacubex/mihomo/component/dialer"
	"github.com/metacubex/mihomo/component/resolver"
)

const (
	localPingICMP = "icmp"
	localPingTCP  = "tcp"
	localPingUDP  = "udp"

	localPingMaxCount    = 9999
	localPingMinInterval = 100
	localPingMaxInterval = 10000
	localPingMaxSize     = 65000
	localPingWait        = 3 * time.Second

	localPingPhaseResolving = "resolving"
	localPingPhaseRunning   = "running"
	localPingPhaseDone      = "done"

	localPingStatusOK          = "ok"
	localPingStatusClosed      = "closed"
	localPingStatusTimeout     = "timeout"
	localPingStatusUnreachable = "unreachable"
	localPingStatusError       = "error"

	localPingErrorInvalid = "invalid"
	localPingErrorResolve = "resolve"
	localPingErrorDenied  = "denied"
	localPingErrorNetwork = "network"
)

type LocalPingParams struct {
	Target   string `json:"target"`
	Protocol string `json:"protocol"`
	Port     int    `json:"port"`
	Count    int    `json:"count"`
	Interval int    `json:"interval"`
	Size     int    `json:"size"`
}

type LocalPingReply struct {
	Seq    int     `json:"seq"`
	Status string  `json:"status"`
	RTT    float64 `json:"rtt"`
	TTL    int     `json:"ttl"`
	Bytes  int     `json:"bytes"`
}

type LocalPingState struct {
	Session  int              `json:"session"`
	Phase    string           `json:"phase"`
	Target   string           `json:"target"`
	Address  string           `json:"address"`
	Protocol string           `json:"protocol"`
	Port     int              `json:"port"`
	Size     int              `json:"size"`
	Count    int              `json:"count"`
	Interval int              `json:"interval"`
	Sent     int              `json:"sent"`
	Elapsed  float64          `json:"elapsed"`
	Reply    *LocalPingReply  `json:"reply,omitempty"`
	Replies  []LocalPingReply `json:"replies,omitempty"`
	Error    string           `json:"error"`
}

type localPingProber interface {
	ping(ctx context.Context, seq int) LocalPingReply
	close()
}

var (
	localPingLock   sync.Mutex
	localPingCancel context.CancelFunc
	localPingSerial int
)

func normalizeLocalPingParams(params LocalPingParams) LocalPingParams {
	switch params.Protocol {
	case localPingTCP, localPingUDP:
	default:
		params.Protocol = localPingICMP
	}
	if params.Protocol == localPingICMP || params.Port <= 0 || params.Port > 65535 {
		params.Port = 0
	}
	if params.Port == 0 {
		switch params.Protocol {
		case localPingTCP:
			params.Port = 443
		case localPingUDP:
			params.Port = 53
		}
	}
	if params.Count <= 0 {
		params.Count = 10
	}
	if params.Count > localPingMaxCount {
		params.Count = localPingMaxCount
	}
	if params.Interval <= 0 {
		params.Interval = 1000
	}
	if params.Interval < localPingMinInterval {
		params.Interval = localPingMinInterval
	}
	if params.Interval > localPingMaxInterval {
		params.Interval = localPingMaxInterval
	}
	if params.Size < 0 {
		params.Size = 0
	}
	if params.Size > localPingMaxSize {
		params.Size = localPingMaxSize
	}
	switch {
	case params.Protocol == localPingTCP:
		params.Size = 0
	case params.Protocol == localPingUDP && params.Port == 53:
		params.Size = len(localPingDNSQuery(0))
	}
	return params
}

func localPingPayload(size int) []byte {
	payload := make([]byte, size)
	_, _ = rand.Read(payload)
	return payload
}

func localPingDNSQuery(id uint16) []byte {
	query := []byte{0, 0, 0x01, 0x00, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 2, 0, 1}
	binary.BigEndian.PutUint16(query, id)
	return query
}

func localPingErrno(err error) syscall.Errno {
	var errno syscall.Errno
	if errors.As(err, &errno) {
		return errno
	}
	return 0
}

func localPingStatus(err error) string {
	if err == nil {
		return localPingStatusOK
	}
	var netErr net.Error
	if errors.Is(err, context.DeadlineExceeded) || (errors.As(err, &netErr) && netErr.Timeout()) {
		return localPingStatusTimeout
	}
	switch localPingErrno(err) {
	case syscall.ECONNREFUSED, syscall.ECONNRESET, 10054, 10061:
		return localPingStatusClosed
	case syscall.EHOSTUNREACH, syscall.ENETUNREACH, 10051, 10065:
		return localPingStatusUnreachable
	}
	return localPingStatusError
}

func localPingDenied(err error) bool {
	switch localPingErrno(err) {
	case syscall.EACCES, syscall.EPERM, 10013:
		return true
	}
	return false
}

func localPingDialer(dst netip.Addr, started *time.Time) *net.Dialer {
	control := dialer.ICMPControl(dst)
	return &net.Dialer{Control: func(network, address string, c syscall.RawConn) error {
		if err := control(network, address, c); err != nil {
			return err
		}
		if started != nil {
			*started = time.Now()
		}
		return nil
	}}
}

func localPingMillis(d time.Duration) float64 {
	return float64(d.Microseconds()) / 1000
}

type localTCPProber struct {
	addr netip.AddrPort
}

func (p *localTCPProber) ping(ctx context.Context, seq int) LocalPingReply {
	var started time.Time
	conn, err := localPingDialer(p.addr.Addr(), &started).DialContext(ctx, "tcp", p.addr.String())
	end := time.Now()
	if conn != nil {
		if tcp, ok := conn.(*net.TCPConn); ok {
			_ = tcp.SetLinger(0)
		}
		_ = conn.Close()
	}
	reply := LocalPingReply{Seq: seq, Status: localPingStatus(err)}
	if (reply.Status == localPingStatusOK || reply.Status == localPingStatusClosed) && !started.IsZero() {
		reply.RTT = localPingMillis(end.Sub(started))
	}
	return reply
}

func (p *localTCPProber) close() {}

type localUDPProber struct {
	addr    netip.AddrPort
	payload []byte
	dns     bool
}

func (p *localUDPProber) ping(ctx context.Context, seq int) LocalPingReply {
	reply := LocalPingReply{Seq: seq}
	conn, err := localPingDialer(p.addr.Addr(), nil).DialContext(ctx, "udp", p.addr.String())
	if err != nil {
		reply.Status = localPingStatus(err)
		return reply
	}
	defer conn.Close()
	finished := make(chan struct{})
	defer close(finished)
	go func() {
		select {
		case <-ctx.Done():
			_ = conn.SetDeadline(time.Now())
		case <-finished:
		}
	}()
	payload := p.payload
	var id uint16
	if p.dns {
		var random [2]byte
		_, _ = rand.Read(random[:])
		id = binary.BigEndian.Uint16(random[:])
		payload = localPingDNSQuery(id)
	}
	buf := make([]byte, 4096)
	start := time.Now()
	if _, err = conn.Write(payload); err != nil {
		reply.Status = localPingStatus(err)
		return reply
	}
	for {
		n, err := conn.Read(buf)
		end := time.Now()
		if err != nil {
			if ctx.Err() == context.DeadlineExceeded {
				err = context.DeadlineExceeded
			}
			reply.Status = localPingStatus(err)
			if reply.Status == localPingStatusClosed {
				reply.RTT = localPingMillis(end.Sub(start))
			}
			return reply
		}
		if p.dns && (n < 12 || binary.BigEndian.Uint16(buf) != id || buf[2]&0x80 == 0) {
			continue
		}
		reply.Status = localPingStatusOK
		reply.RTT = localPingMillis(end.Sub(start))
		reply.Bytes = n
		return reply
	}
}

func (p *localUDPProber) close() {}

func localPingResolve(ctx context.Context, target string) (netip.Addr, string) {
	host, ip, ok := parseRouteTarget(target)
	if !ok {
		return netip.Addr{}, localPingErrorInvalid
	}
	if ip.IsValid() {
		return ip, ""
	}
	resolveCtx, cancel := context.WithTimeout(ctx, 5*time.Second)
	defer cancel()
	addr, err := resolver.ResolveIPWithResolver(resolveCtx, host, resolver.DirectHostResolver)
	if err != nil {
		return netip.Addr{}, localPingErrorResolve
	}
	return addr.Unmap(), ""
}

func newLocalPingProber(params LocalPingParams, addr netip.Addr) (localPingProber, string) {
	switch params.Protocol {
	case localPingTCP:
		return &localTCPProber{addr: netip.AddrPortFrom(addr, uint16(params.Port))}, ""
	case localPingUDP:
		return &localUDPProber{
			addr:    netip.AddrPortFrom(addr, uint16(params.Port)),
			payload: localPingPayload(params.Size),
			dns:     params.Port == 53,
		}, ""
	}
	prober, err := newLocalICMPProber(addr, localPingPayload(params.Size))
	if err != nil {
		if localPingDenied(err) {
			return nil, localPingErrorDenied
		}
		return nil, localPingErrorNetwork
	}
	return prober, ""
}

func runLocalPing(ctx context.Context, session int, params LocalPingParams, notify func(LocalPingState)) LocalPingState {
	params = normalizeLocalPingParams(params)
	state := LocalPingState{
		Session:  session,
		Phase:    localPingPhaseResolving,
		Target:   params.Target,
		Protocol: params.Protocol,
		Port:     params.Port,
		Size:     params.Size,
		Count:    params.Count,
		Interval: params.Interval,
	}
	if params.Protocol == localPingICMP {
		state.Port = 0
	}
	if notify == nil {
		notify = func(LocalPingState) {}
	}
	notify(state)
	addr, code := localPingResolve(ctx, params.Target)
	if code == "" {
		state.Address = addr.String()
	}
	var prober localPingProber
	if code == "" {
		prober, code = newLocalPingProber(params, addr)
	}
	if code != "" {
		state.Phase = localPingPhaseDone
		state.Error = code
		return state
	}
	defer prober.close()

	state.Phase = localPingPhaseRunning
	state.Replies = make([]LocalPingReply, 0, params.Count)
	start := time.Now()
	notify(state)

	results := make(chan LocalPingReply, params.Count)
	launches := make(chan int)
	scheduled := make(chan struct{})
	go func() {
		defer close(scheduled)
		interval := time.Duration(params.Interval) * time.Millisecond
		timer := time.NewTimer(time.Hour)
		defer timer.Stop()
		for seq := 1; seq <= params.Count; seq++ {
			if seq > 1 {
				if !timer.Stop() {
					select {
					case <-timer.C:
					default:
					}
				}
				timer.Reset(time.Until(start.Add(time.Duration(seq-1) * interval)))
				select {
				case <-ctx.Done():
					return
				case <-timer.C:
				}
			}
			select {
			case <-ctx.Done():
				return
			case launches <- seq:
			}
			go func(seq int) {
				probeCtx, cancel := context.WithTimeout(ctx, localPingWait)
				reply := prober.ping(probeCtx, seq)
				cancel()
				results <- reply
			}(seq)
		}
	}()

	publish := func(reply *LocalPingReply) {
		state.Elapsed = time.Since(start).Seconds()
		snapshot := state
		snapshot.Replies = nil
		snapshot.Reply = reply
		notify(snapshot)
	}
	pending := 0
	scheduling := scheduled
collect:
	for scheduling != nil || pending > 0 {
		select {
		case <-ctx.Done():
			break collect
		case seq := <-launches:
			state.Sent = seq
			pending++
			publish(nil)
		case <-scheduling:
			scheduling = nil
		case reply := <-results:
			pending--
			state.Replies = append(state.Replies, reply)
			publish(&reply)
		}
	}

	slices.SortFunc(state.Replies, func(a, b LocalPingReply) int { return cmp.Compare(a.Seq, b.Seq) })
	state.Sent = len(state.Replies)
	state.Phase = localPingPhaseDone
	state.Elapsed = time.Since(start).Seconds()
	return state
}

func HandleStartLocalPing(paramsString string) string {
	params := LocalPingParams{}
	_ = json.Unmarshal([]byte(paramsString), &params)
	ctx, cancel := context.WithCancel(context.Background())
	localPingLock.Lock()
	if localPingCancel != nil {
		localPingCancel()
	}
	localPingCancel = cancel
	localPingSerial++
	serial := localPingSerial
	localPingLock.Unlock()
	defer func() {
		localPingLock.Lock()
		if localPingSerial == serial {
			localPingCancel = nil
		}
		localPingLock.Unlock()
		cancel()
	}()
	state := runLocalPing(ctx, serial, params, func(state LocalPingState) {
		notify(MessageLocalPing, state)
	})
	data, _ := json.Marshal(state)
	return string(data)
}

func HandleCancelLocalPing() bool {
	localPingLock.Lock()
	defer localPingLock.Unlock()
	if localPingCancel != nil {
		localPingCancel()
		localPingCancel = nil
	}
	return true
}
