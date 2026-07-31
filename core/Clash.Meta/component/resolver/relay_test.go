package resolver

import (
	"bytes"
	"net"
	"testing"

	D "github.com/miekg/dns"
	"github.com/stretchr/testify/require"
)

func TestPackDnsMessageCopiesReallocatedBuffer(t *testing.T) {
	query := new(D.Msg)
	query.SetQuestion("large.example.", D.TypeA)

	response := new(D.Msg)
	response.SetReply(query)
	for i := 0; i < 110; i++ {
		response.Answer = append(response.Answer, &D.A{
			Hdr: D.RR_Header{
				Name:   "large.example.",
				Rrtype: D.TypeA,
				Class:  D.ClassINET,
				Ttl:    60,
			},
			A: net.IPv4(192, 0, 2, byte(i+1)),
		})
	}
	response.Compress = true

	target := bytes.Repeat([]byte{0xa5}, SafeDnsPacketSize)
	reallocated, err := response.PackBuffer(target)
	require.NoError(t, err)
	require.NotEmpty(t, reallocated)
	require.LessOrEqual(t, len(reallocated), len(target))
	require.False(t, &reallocated[0] == &target[0], "fixture must force PackBuffer to reallocate")
	for i := range target {
		target[i] = 0xa5
	}

	data, err := packDnsMessage(response, target)
	require.NoError(t, err)
	require.NotEmpty(t, data)
	require.LessOrEqual(t, len(data), len(target))
	require.True(t, &data[0] == &target[0])

	decoded := new(D.Msg)
	require.NoError(t, decoded.Unpack(data))
	require.Len(t, decoded.Answer, len(response.Answer))
}
