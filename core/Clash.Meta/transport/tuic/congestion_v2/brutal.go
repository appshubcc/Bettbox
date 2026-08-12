package congestion

import (
	"time"

	"github.com/metacubex/quic-go/congestion"
	"github.com/metacubex/quic-go/monotime"
)

const (
	brutalPacketInfoSlotCount     = 5 // slot index is based on seconds, so this samples the recent 5 seconds.
	brutalMinSampleCount          = 50
	brutalMinAckRate              = 0.8
	brutalCongestionWindowFactor  = 2
	brutalInitialCongestionWindow = congestion.ByteCount(10240)
)

var _ congestion.CongestionControlEx = (*BrutalSender)(nil)

type BrutalSender struct {
	rttStats        congestion.RTTStatsProvider
	bps             congestion.ByteCount
	maxDatagramSize congestion.ByteCount
	pacer           *Pacer

	packetInfoSlots [brutalPacketInfoSlotCount]brutalPacketInfo
	ackRate         float64
}

type brutalPacketInfo struct {
	timestamp int64
	ackCount  uint64
	lossCount uint64
}

func NewBrutalSender(bps uint64) *BrutalSender {
	b := &BrutalSender{
		bps:             congestion.ByteCount(bps),
		maxDatagramSize: congestion.InitialPacketSize,
		ackRate:         1,
	}
	b.pacer = NewPacer(func() congestion.ByteCount {
		return congestion.ByteCount(float64(b.bps) / b.ackRate)
	})
	return b
}

func (b *BrutalSender) SetRTTStatsProvider(rttStats congestion.RTTStatsProvider) {
	b.rttStats = rttStats
}

func (b *BrutalSender) TimeUntilSend(bytesInFlight congestion.ByteCount) monotime.Time {
	return b.pacer.TimeUntilSend()
}

func (b *BrutalSender) HasPacingBudget(now monotime.Time) bool {
	return b.pacer.Budget(now) >= b.maxDatagramSize
}

func (b *BrutalSender) CanSend(bytesInFlight congestion.ByteCount) bool {
	return bytesInFlight <= b.GetCongestionWindow()
}

func (b *BrutalSender) GetCongestionWindow() congestion.ByteCount {
	if b.rttStats == nil {
		return brutalInitialCongestionWindow
	}
	rtt := b.rttStats.SmoothedRTT()
	if rtt <= 0 {
		return brutalInitialCongestionWindow
	}
	cwnd := congestion.ByteCount(float64(b.bps) * rtt.Seconds() * brutalCongestionWindowFactor / b.ackRate)
	if cwnd < b.maxDatagramSize {
		cwnd = b.maxDatagramSize
	}
	return cwnd
}

func (b *BrutalSender) OnPacketSent(sentTime monotime.Time, bytesInFlight congestion.ByteCount, packetNumber congestion.PacketNumber, bytes congestion.ByteCount, isRetransmittable bool) {
	b.pacer.SentPacket(sentTime, bytes)
}

func (b *BrutalSender) OnPacketAcked(number congestion.PacketNumber, ackedBytes congestion.ByteCount, priorInFlight congestion.ByteCount, eventTime monotime.Time) {
	// Brutal uses OnCongestionEventEx to update ACK rate from acked/lost packet counts.
}

func (b *BrutalSender) OnCongestionEvent(number congestion.PacketNumber, lostBytes congestion.ByteCount, priorInFlight congestion.ByteCount) {
	// Brutal uses OnCongestionEventEx to update ACK rate from acked/lost packet counts.
}

func (b *BrutalSender) OnCongestionEventEx(priorInFlight congestion.ByteCount, eventTime monotime.Time, ackedPackets []congestion.AckedPacketInfo, lostPackets []congestion.LostPacketInfo) {
	currentTimestamp := int64(time.Duration(eventTime) / time.Second)
	slot := currentTimestamp % brutalPacketInfoSlotCount
	if b.packetInfoSlots[slot].timestamp == currentTimestamp {
		b.packetInfoSlots[slot].lossCount += uint64(len(lostPackets))
		b.packetInfoSlots[slot].ackCount += uint64(len(ackedPackets))
	} else {
		b.packetInfoSlots[slot] = brutalPacketInfo{
			timestamp: currentTimestamp,
			ackCount:  uint64(len(ackedPackets)),
			lossCount: uint64(len(lostPackets)),
		}
	}
	b.updateAckRate(currentTimestamp)
}

func (b *BrutalSender) SetMaxDatagramSize(size congestion.ByteCount) {
	b.maxDatagramSize = size
	b.pacer.SetMaxDatagramSize(size)
}

func (b *BrutalSender) InSlowStart() bool {
	return false
}

func (b *BrutalSender) InRecovery() bool {
	return false
}

func (b *BrutalSender) MaybeExitSlowStart() {}

func (b *BrutalSender) OnRetransmissionTimeout(packetsRetransmitted bool) {}

func (b *BrutalSender) updateAckRate(currentTimestamp int64) {
	minTimestamp := currentTimestamp - brutalPacketInfoSlotCount
	var ackCount, lossCount uint64
	for _, info := range b.packetInfoSlots {
		if info.timestamp < minTimestamp {
			continue
		}
		ackCount += info.ackCount
		lossCount += info.lossCount
	}
	if ackCount+lossCount < brutalMinSampleCount {
		b.ackRate = 1
		return
	}
	rate := float64(ackCount) / float64(ackCount+lossCount)
	if rate < brutalMinAckRate {
		b.ackRate = brutalMinAckRate
		return
	}
	b.ackRate = rate
}
