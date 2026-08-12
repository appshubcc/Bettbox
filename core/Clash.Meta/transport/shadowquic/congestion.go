package shadowquic

import (
	"time"

	"github.com/metacubex/mihomo/transport/tuic/congestion"
	congestionv2 "github.com/metacubex/mihomo/transport/tuic/congestion_v2"

	"github.com/metacubex/jls-quic-go"
	jcongestion "github.com/metacubex/jls-quic-go/congestion"
	jmonotime "github.com/metacubex/jls-quic-go/monotime"
	oldcongestion "github.com/metacubex/quic-go/congestion"
	oldmonotime "github.com/metacubex/quic-go/monotime"
)

func SetCongestionController(quicConn *quic.Conn, cc string, cwnd int, profile string) {
	if cwnd == 0 {
		cwnd = 32
	}
	initialPacketSize := oldcongestion.ByteCount(quicConn.Config().InitialPacketSize)
	switch cc {
	case "cubic":
		quicConn.SetCongestionControl(newCongestionAdapter(
			congestion.NewCubicSender(initialPacketSize, false),
		))
	case "new_reno":
		quicConn.SetCongestionControl(newCongestionAdapter(
			congestion.NewCubicSender(initialPacketSize, true),
		))
	case "bbr_meta_v1":
		quicConn.SetCongestionControl(newCongestionAdapter(
			congestion.NewBBRSender(
				initialPacketSize,
				oldcongestion.ByteCount(cwnd)*congestion.InitialMaxDatagramSize,
				congestion.DefaultBBRMaxCongestionWindow*congestion.InitialMaxDatagramSize,
			),
		))
	case "bbr_meta_v2", "bbr":
		quicConn.SetCongestionControl(newCongestionAdapter(
			congestionv2.NewBbrSender(
				initialPacketSize,
				oldcongestion.ByteCount(cwnd),
				congestionv2.Profile(profile),
			),
		))
	}
}

func setBrutalCongestionController(quicConn *quic.Conn, bps uint64) {
	if bps == 0 {
		return
	}
	quicConn.SetCongestionControl(newCongestionAdapter(
		congestionv2.NewBrutalSender(bps),
	))
}

func newCongestionAdapter(cc oldcongestion.CongestionControl) jcongestion.CongestionControl {
	return &congestionAdapter{cc: cc}
}

type congestionAdapter struct {
	cc oldcongestion.CongestionControl
}

func (a *congestionAdapter) SetRTTStatsProvider(provider jcongestion.RTTStatsProvider) {
	a.cc.SetRTTStatsProvider(rttStatsProviderAdapter{provider: provider})
}

func (a *congestionAdapter) TimeUntilSend(bytesInFlight jcongestion.ByteCount) jmonotime.Time {
	return jmonotime.Time(a.cc.TimeUntilSend(oldcongestion.ByteCount(bytesInFlight)))
}

func (a *congestionAdapter) HasPacingBudget(now jmonotime.Time) bool {
	return a.cc.HasPacingBudget(oldmonotime.Time(now))
}

func (a *congestionAdapter) OnPacketSent(sentTime jmonotime.Time, bytesInFlight jcongestion.ByteCount, packetNumber jcongestion.PacketNumber, bytes jcongestion.ByteCount, isRetransmittable bool) {
	a.cc.OnPacketSent(
		oldmonotime.Time(sentTime),
		oldcongestion.ByteCount(bytesInFlight),
		oldcongestion.PacketNumber(packetNumber),
		oldcongestion.ByteCount(bytes),
		isRetransmittable,
	)
}

func (a *congestionAdapter) CanSend(bytesInFlight jcongestion.ByteCount) bool {
	return a.cc.CanSend(oldcongestion.ByteCount(bytesInFlight))
}

func (a *congestionAdapter) MaybeExitSlowStart() {
	a.cc.MaybeExitSlowStart()
}

func (a *congestionAdapter) OnPacketAcked(number jcongestion.PacketNumber, ackedBytes jcongestion.ByteCount, priorInFlight jcongestion.ByteCount, eventTime jmonotime.Time) {
	a.cc.OnPacketAcked(
		oldcongestion.PacketNumber(number),
		oldcongestion.ByteCount(ackedBytes),
		oldcongestion.ByteCount(priorInFlight),
		oldmonotime.Time(eventTime),
	)
}

func (a *congestionAdapter) OnCongestionEvent(number jcongestion.PacketNumber, lostBytes jcongestion.ByteCount, priorInFlight jcongestion.ByteCount) {
	a.cc.OnCongestionEvent(
		oldcongestion.PacketNumber(number),
		oldcongestion.ByteCount(lostBytes),
		oldcongestion.ByteCount(priorInFlight),
	)
}

func (a *congestionAdapter) OnRetransmissionTimeout(packetsRetransmitted bool) {
	a.cc.OnRetransmissionTimeout(packetsRetransmitted)
}

func (a *congestionAdapter) SetMaxDatagramSize(size jcongestion.ByteCount) {
	a.cc.SetMaxDatagramSize(oldcongestion.ByteCount(size))
}

func (a *congestionAdapter) InSlowStart() bool {
	return a.cc.InSlowStart()
}

func (a *congestionAdapter) InRecovery() bool {
	return a.cc.InRecovery()
}

func (a *congestionAdapter) GetCongestionWindow() jcongestion.ByteCount {
	return jcongestion.ByteCount(a.cc.GetCongestionWindow())
}

func (a *congestionAdapter) OnCongestionEventEx(priorInFlight jcongestion.ByteCount, eventTime jmonotime.Time, ackedPackets []jcongestion.AckedPacketInfo, lostPackets []jcongestion.LostPacketInfo) {
	ex, ok := a.cc.(oldcongestion.CongestionControlEx)
	if !ok {
		return
	}
	ex.OnCongestionEventEx(
		oldcongestion.ByteCount(priorInFlight),
		oldmonotime.Time(eventTime),
		adaptAckedPacketInfo(ackedPackets),
		adaptLostPacketInfo(lostPackets),
	)
}

func adaptAckedPacketInfo(packets []jcongestion.AckedPacketInfo) []oldcongestion.AckedPacketInfo {
	if len(packets) == 0 {
		return nil
	}
	adapted := make([]oldcongestion.AckedPacketInfo, len(packets))
	for i, packet := range packets {
		adapted[i] = oldcongestion.AckedPacketInfo{
			PacketNumber: oldcongestion.PacketNumber(packet.PacketNumber),
			BytesAcked:   oldcongestion.ByteCount(packet.BytesAcked),
			ReceivedTime: oldmonotime.Time(packet.ReceivedTime),
		}
	}
	return adapted
}

func adaptLostPacketInfo(packets []jcongestion.LostPacketInfo) []oldcongestion.LostPacketInfo {
	if len(packets) == 0 {
		return nil
	}
	adapted := make([]oldcongestion.LostPacketInfo, len(packets))
	for i, packet := range packets {
		adapted[i] = oldcongestion.LostPacketInfo{
			PacketNumber: oldcongestion.PacketNumber(packet.PacketNumber),
			BytesLost:    oldcongestion.ByteCount(packet.BytesLost),
		}
	}
	return adapted
}

type rttStatsProviderAdapter struct {
	provider jcongestion.RTTStatsProvider
}

func (a rttStatsProviderAdapter) MinRTT() time.Duration {
	return a.provider.MinRTT()
}

func (a rttStatsProviderAdapter) LatestRTT() time.Duration {
	return a.provider.LatestRTT()
}

func (a rttStatsProviderAdapter) SmoothedRTT() time.Duration {
	return a.provider.SmoothedRTT()
}

func (a rttStatsProviderAdapter) MeanDeviation() time.Duration {
	return a.provider.MeanDeviation()
}

func (a rttStatsProviderAdapter) MaxAckDelay() time.Duration {
	return a.provider.MaxAckDelay()
}

func (a rttStatsProviderAdapter) PTO(includeMaxAckDelay bool) time.Duration {
	return a.provider.PTO(includeMaxAckDelay)
}

func (a rttStatsProviderAdapter) UpdateRTT(sendDelta, ackDelay time.Duration) {
	a.provider.UpdateRTT(sendDelta, ackDelay)
}

func (a rttStatsProviderAdapter) SetMaxAckDelay(mad time.Duration) {
	a.provider.SetMaxAckDelay(mad)
}

func (a rttStatsProviderAdapter) SetInitialRTT(t time.Duration) {
	a.provider.SetInitialRTT(t)
}
