import 'package:bett_box/common/tailscale.dart';
import 'package:bett_box/models/models.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('entries classify and normalize', () {
    expect(tailscaleCidr('100.101.102.103'), '100.101.102.103/32');
    expect(tailscaleCidr('192.168.1.5/24'), '192.168.1.0/24');
    expect(tailscaleCidr('fd7a:115c:a1e0::1/48'), 'fd7a:115c:a1e0::/48');
    expect(tailscaleCidr('10.0.0.0/33'), isNull);
    expect(tailscaleCidr('ts.net'), isNull);
    expect(tailscaleDomain('+.Example.com'), 'example.com');
    expect(tailscaleDomain('*.corp.internal'), 'corp.internal');
    expect(tailscaleDomain('10.0.0.1'), isNull);
    expect(tailscaleDomain('bad domain'), isNull);
    expect(isValidTailscaleEntry('a/b'), isFalse);
  });

  test('rules and dns policy', () {
    expect(tailscaleRules(defaultTailscaleRoutes, 'Tailscale'), [
      'IP-CIDR,100.64.0.0/10,Tailscale,no-resolve',
      'IP-CIDR6,fd7a:115c:a1e0::/48,Tailscale,no-resolve',
      'DOMAIN-SUFFIX,ts.net,Tailscale',
    ]);
    expect(tailscaleNameserverPolicy(defaultTailscaleRoutes, 'Tailscale'), {
      '+.ts.net': 'tailscale://Tailscale',
    });
    expect(tailscaleRouteCidrs(['1.1.1.1', '1.1.1.1/32', 'x.com']), [
      '1.1.1.1/32',
    ]);
    expect(tailscaleRoutesCover(['example.com'], 'hs.example.com'), isTrue);
    expect(tailscaleRoutesCover(['example.com'], 'example.com'), isTrue);
    expect(tailscaleRoutesCover(['example.com'], 'badexample.com'), isFalse);
    expect(
      tailscaleRoutesCover(['10.0.0.0/8'], 'controlplane.tailscale.com'),
      isFalse,
    );
  });

  test('tailnet DNS entries', () {
    expect(parseTailscaleDns('corp.example.com=10.1.0.53'), (
      domain: 'corp.example.com',
      server: '10.1.0.53',
    ));
    expect(parseTailscaleDns('+.home.arpa = fd00::53')?.server, '[fd00::53]');
    expect(
      parseTailscaleDns('x.com=tls://dns.corp:853')?.server,
      'tls://dns.corp:853',
    );
    expect(parseTailscaleDns('x.com'), isNull);
    expect(parseTailscaleDns('x.com=10.0.0.1#Other'), isNull);
    expect(parseTailscaleDns('x.com=a=b'), isNull);
    // Plain DNS needs an IP: hostnames resolve outside the tailnet.
    expect(parseTailscaleDns('x.com=pihole.tail1234.ts.net'), isNull);
    expect(parseTailscaleDns('x.com=tcp://dns.corp'), isNull);
    expect(parseTailscaleDns('x.com=htps://dns.corp'), isNull);
    expect(tailscaleDnsDomains(['corp.example.com=10.1.0.53', 'bad']), [
      'corp.example.com',
    ]);
    expect(
      tailscaleNameserverPolicy(
        ['ts.net', 'corp.example.com'],
        'Tailscale',
        dns: [
          'corp.example.com=10.1.0.53',
          'home.arpa=[fd00::53]:53',
          'lan=udp://192.168.1.1',
        ],
        udp: false,
      ),
      {
        '+.ts.net': 'tailscale://Tailscale',
        '+.corp.example.com': ['tcp://10.1.0.53#Tailscale'],
        '+.home.arpa': ['tcp://[fd00::53]:53#Tailscale'],
        '+.lan': ['tcp://192.168.1.1#Tailscale'],
      },
    );
  });

  test('tailnet DNS domains route only answers in tailnet ranges', () {
    expect(
      tailscaleRules(
        ['10.1.0.0/16', 'example.com'],
        'T',
        dns: ['corp.example.com=10.1.0.53', 'example.com=10.1.0.53'],
        except: 'hs.example.com',
      ),
      [
        'IP-CIDR,10.1.0.0/16,T,no-resolve',
        'AND,((DOMAIN-SUFFIX,example.com),(NOT,((DOMAIN,hs.example.com)))),T',
        'AND,((DOMAIN-SUFFIX,corp.example.com),(OR,((IP-CIDR,10.1.0.0/16),'
            '(IP-CIDR,100.64.0.0/10),(IP-CIDR6,fd7a:115c:a1e0::/48)))),T',
      ],
    );
  });

  test('subtractCidrs carves routes out of an exclude list', () {
    expect(subtractCidrs(['10.0.0.0/8'], ['10.0.0.0/8']), isEmpty);
    expect(subtractCidrs(['10.0.0.0/8'], ['192.168.0.0/16']), ['10.0.0.0/8']);
    expect(subtractCidrs(['10.0.0.0/8', 'fd00::/8'], []), [
      '10.0.0.0/8',
      'fd00::/8',
    ]);
    expect(subtractCidrs(['192.168.0.0/16'], ['192.168.0.0/17']), [
      '192.168.128.0/17',
    ]);
    final carved = subtractCidrs(['fd00::/8'], ['fd7a:115c:a1e0::/48']);
    expect(carved, hasLength(40));
    expect(carved, isNot(contains('fd00::/8')));
    // Nothing left in the carve-out still covers the tailnet range.
    expect(subtractCidrs(carved, ['fd7a:115c:a1e0::/48']), carved);
    expect(subtractCidrs(['fd7a:115c:a1e0::/48'], carved), [
      'fd7a:115c:a1e0::/48',
    ]);
  });

  test('retired node state dirs', () {
    const kept = TailscaleNetwork(id: 'a');
    const reset = TailscaleNetwork(id: 'b', stateKey: 'k');
    expect(kept.stateDir, 'bettbox-tailscale/a');
    expect(reset.stateDir, 'bettbox-tailscale/b-k');
    final props = const TailscaleProps(
      networks: [kept],
      retiredDirs: ['bettbox-tailscale/c'],
    ).retire([kept, reset]);
    expect(props.retiredDirs, ['bettbox-tailscale/c', 'bettbox-tailscale/b-k']);
  });

  test('core state dirs match by their last segment', () {
    expect(
      isTailscaleStateDir(
        '/home/u/bettbox-tailscale/b-k',
        'bettbox-tailscale/b-k',
      ),
      isTrue,
    );
    expect(
      isTailscaleStateDir(
        r'C:\Bettbox\bettbox-tailscale\a',
        'bettbox-tailscale/a',
      ),
      isTrue,
    );
    expect(
      isTailscaleStateDir('/x/bettbox-tailscale/a', 'bettbox-tailscale/a-k'),
      isFalse,
    );
    expect(isTailscaleStateDir('', 'bettbox-tailscale/a'), isFalse);
  });
}
