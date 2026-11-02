import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'dart:ui';

import 'package:bett_box/common/common.dart';
import 'package:bett_box/enum/enum.dart';
import 'package:bett_box/models/models.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:bett_box/l10n/l10n.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter/services.dart';
import 'package:lpinyin/lpinyin.dart';

enum IpCategory { tun, lan, public }

typedef _DefaultRoute = ({String gateway, String interfaceName});

final _virtualInterfaceRegExp = RegExp(
  'tun|tap|vpn|ppp|meta|clash|${RegExp.escape(tunDeviceName)}',
  caseSensitive: false,
);

final _bridgeInterfaceRegExp = RegExp(
  r'^(docker|veth|br-|vmnet|vboxnet|virbr|awdl|llw|bridge|zt|tailscale|wg)',
  caseSensitive: false,
);

class Utils {
  Color? getDelayColor(int? delay) {
    if (delay == null) return null;
    if (delay < 0) return Colors.red;
    if (delay < 600) return Colors.green;
    return const Color(0xFFC57F0A);
  }

  String countryCodeToEmoji(String countryCode) {
    final String code = countryCode.toUpperCase();
    if (!RegExp(r'^[A-Z]{2}$').hasMatch(code)) {
      return countryCode;
    }
    final int firstLetter = code.codeUnitAt(0) - 0x41 + 0x1F1E6;
    final int secondLetter = code.codeUnitAt(1) - 0x41 + 0x1F1E6;
    return String.fromCharCode(firstLetter) + String.fromCharCode(secondLetter);
  }

  static const Map<String, String> _regionToCountryCodeMap = {
    'HKG': 'HK',
    'HKD': 'HK',
    'HONGKONG': 'HK',
    'EASTASIA': 'HK',
    'MFM': 'MO',
    'MAC': 'MO',
    'MOP': 'MO',
    'MACAU': 'MO',
    'TPE': 'TW',
    'TSA': 'TW',
    'KHH': 'TW',
    'TXG': 'TW',
    'TWN': 'TW',
    'NTW': 'TW',
    'TWD': 'TW',
    'TAIPEI': 'TW',
    'TAIWAN': 'TW',
    'ROC': 'TW',
    'NRT': 'JP',
    'HND': 'JP',
    'KIX': 'JP',
    'ITM': 'JP',
    'FUK': 'JP',
    'NGO': 'JP',
    'CTS': 'JP',
    'OKA': 'JP',
    'SDJ': 'JP',
    'HIJ': 'JP',
    'KMQ': 'JP',
    'KOJ': 'JP',
    'FSZ': 'JP',
    'KIJ': 'JP',
    'JPN': 'JP',
    'JPY': 'JP',
    'JAPAN': 'JP',
    'JAPANEAST': 'JP',
    'JAPANWEST': 'JP',
    'TOKYO': 'JP',
    'OSAKA': 'JP',
    'ICN': 'KR',
    'GMP': 'KR',
    'PUS': 'KR',
    'CJU': 'KR',
    'TAE': 'KR',
    'KOR': 'KR',
    'KRW': 'KR',
    'KOREA': 'KR',
    'KOREACENTRAL': 'KR',
    'KOREASOUTH': 'KR',
    'SEOUL': 'KR',
    'SIN': 'SG',
    'SGP': 'SG',
    'SGD': 'SG',
    'SINGAPORE': 'SG',
    'SOUTHEASTASIA': 'SG',
    'KUL': 'MY',
    'JHB': 'MY',
    'BKI': 'MY',
    'KCH': 'MY',
    'PEN': 'MY',
    'MYS': 'MY',
    'MYR': 'MY',
    'THA': 'TH',
    'THB': 'TH',
    'VNM': 'VN',
    'VND': 'VN',
    'IDN': 'ID',
    'IDR': 'ID',
    'PHP': 'PH',
    'GBR': 'GB',
    'GBP': 'GB',
    'DEU': 'DE',
    'EUR': 'EU',
    'CAD': 'CA',
    'AUD': 'AU',
    'CNY': 'CN',
    'MALAYSIA': 'MY',
    'BKK': 'TH',
    'DMK': 'TH',
    'CNX': 'TH',
    'HKT': 'TH',
    'THAILAND': 'TH',
    'HAN': 'VN',
    'SGN': 'VN',
    'DAD': 'VN',
    'VIETNAM': 'VN',
    'MNL': 'PH',
    'CEB': 'PH',
    'CRK': 'PH',
    'PHILIPPINES': 'PH',
    'CGK': 'ID',
    'DPS': 'ID',
    'SUB': 'ID',
    'INDONESIA': 'ID',
    'BOM': 'IN',
    'DEL': 'IN',
    'BLR': 'IN',
    'MAA': 'IN',
    'HYD': 'IN',
    'CCU': 'IN',
    'AMD': 'IN',
    'COK': 'IN',
    'PNQ': 'IN',
    'JAI': 'IN',
    'NAG': 'IN',
    'PAT': 'IN',
    'INDIA': 'IN',
    'CENTRALINDIA': 'IN',
    'SOUTHINDIA': 'IN',
    'WESTINDIA': 'IN',
    'MUMBAI': 'IN',
    'PEK': 'CN',
    'PKX': 'CN',
    'PVG': 'CN',
    'SHA': 'CN',
    'CAN': 'CN',
    'SZX': 'CN',
    'CTU': 'CN',
    'TFU': 'CN',
    'CKG': 'CN',
    'WUH': 'CN',
    'XIY': 'CN',
    'HGH': 'CN',
    'NKG': 'CN',
    'CGO': 'CN',
    'TAO': 'CN',
    'CSX': 'CN',
    'XMN': 'CN',
    'KMG': 'CN',
    'URC': 'CN',
    'TSN': 'CN',
    'DLC': 'CN',
    'SHE': 'CN',
    'CHN': 'CN',
    'CHINA': 'CN',
    'SYD': 'AU',
    'MEL': 'AU',
    'BNE': 'AU',
    'PER': 'AU',
    'ADL': 'AU',
    'CBR': 'AU',
    'HBA': 'AU',
    'DRW': 'AU',
    'CNS': 'AU',
    'OOL': 'AU',
    'AUSTRALIA': 'AU',
    'AUSTRALIAEAST': 'AU',
    'AUSTRALIASOUTHEAST': 'AU',
    'AUSTRALIACENTRAL': 'AU',
    'SYDNEY': 'AU',
    'MELBOURNE': 'AU',
    'AKL': 'NZ',
    'WLG': 'NZ',
    'CHC': 'NZ',
    'NEWZEALAND': 'NZ',
    'LAX': 'US',
    'SFO': 'US',
    'SJC': 'US',
    'SAN': 'US',
    'OAK': 'US',
    'SMF': 'US',
    'BUR': 'US',
    'ONT': 'US',
    'SEA': 'US',
    'PDX': 'US',
    'DFW': 'US',
    'IAH': 'US',
    'AUS': 'US',
    'SAT': 'US',
    'DAL': 'US',
    'HOU': 'US',
    'JFK': 'US',
    'EWR': 'US',
    'LGA': 'US',
    'BUF': 'US',
    'ORD': 'US',
    'MDW': 'US',
    'ATL': 'US',
    'MIA': 'US',
    'MCO': 'US',
    'TPA': 'US',
    'FLL': 'US',
    'JAX': 'US',
    'IAD': 'US',
    'DCA': 'US',
    'BOS': 'US',
    'DEN': 'US',
    'PHX': 'US',
    'LAS': 'US',
    'RNO': 'US',
    'PHL': 'US',
    'PIT': 'US',
    'DTW': 'US',
    'MSP': 'US',
    'CLE': 'US',
    'CMH': 'US',
    'CVG': 'US',
    'CLT': 'US',
    'RDU': 'US',
    'BNA': 'US',
    'MEM': 'US',
    'SLC': 'US',
    'STL': 'US',
    'MCI': 'US',
    'IND': 'US',
    'MKE': 'US',
    'OKC': 'US',
    'TUL': 'US',
    'SDF': 'US',
    'MSY': 'US',
    'ANC': 'US',
    'HNL': 'US',
    'OGG': 'US',
    'OMA': 'US',
    'BOI': 'US',
    'BHM': 'US',
    'USA': 'US',
    'USD': 'US',
    'EASTUS': 'US',
    'EASTUS2': 'US',
    'WESTUS': 'US',
    'WESTUS2': 'US',
    'WESTUS3': 'US',
    'CENTRALUS': 'US',
    'NORTHCENTRALUS': 'US',
    'SOUTHCENTRALUS': 'US',
    'WESTCENTRALUS': 'US',
    'YYZ': 'CA',
    'YVR': 'CA',
    'YUL': 'CA',
    'YYC': 'CA',
    'YEG': 'CA',
    'YOW': 'CA',
    'YWG': 'CA',
    'YHZ': 'CA',
    'CANADA': 'CA',
    'CANADACENTRAL': 'CA',
    'CANADAEAST': 'CA',
    'LHR': 'GB',
    'LGW': 'GB',
    'LCY': 'GB',
    'STN': 'GB',
    'LTN': 'GB',
    'MAN': 'GB',
    'EDI': 'GB',
    'BHX': 'GB',
    'GLA': 'GB',
    'BRS': 'GB',
    'NCL': 'GB',
    'UK': 'GB',
    'UKSOUTH': 'GB',
    'UKWEST': 'GB',
    'LONDON': 'GB',
    'FRA': 'DE',
    'MUC': 'DE',
    'BER': 'DE',
    'TXL': 'DE',
    'HAM': 'DE',
    'DUS': 'DE',
    'STR': 'DE',
    'CGN': 'DE',
    'LEJ': 'DE',
    'NUE': 'DE',
    'HAJ': 'DE',
    'GERMANY': 'DE',
    'GERMANYWESTCENTRAL': 'DE',
    'GERMANYNORTH': 'DE',
    'FRANKFURT': 'DE',
    'CDG': 'FR',
    'ORY': 'FR',
    'MRS': 'FR',
    'LYS': 'FR',
    'NCE': 'FR',
    'TLS': 'FR',
    'BOD': 'FR',
    'FRANCE': 'FR',
    'FRANCECENTRAL': 'FR',
    'FRANCESOUTH': 'FR',
    'PARIS': 'FR',
    'AMS': 'NL',
    'RTM': 'NL',
    'NETHERLANDS': 'NL',
    'WESTEUROPE': 'NL',
    'AMSTERDAM': 'NL',
    'DUB': 'IE',
    'ORK': 'IE',
    'IRELAND': 'IE',
    'NORTHEUROPE': 'IE',
    'ZRH': 'CH',
    'GVA': 'CH',
    'BSL': 'CH',
    'SWITZERLAND': 'CH',
    'SWITZERLANDNORTH': 'CH',
    'SWITZERLANDWEST': 'CH',
    'ZURICH': 'CH',
    'ARN': 'SE',
    'BMA': 'SE',
    'GOT': 'SE',
    'MMX': 'SE',
    'SWEDEN': 'SE',
    'SWEDENCENTRAL': 'SE',
    'STOCKHOLM': 'SE',
    'OSL': 'NO',
    'BGO': 'NO',
    'SVG': 'NO',
    'NORWAY': 'NO',
    'NORWAYEAST': 'NO',
    'NORWAYWEST': 'NO',
    'CPH': 'DK',
    'BLL': 'DK',
    'DENMARK': 'DK',
    'HEL': 'FI',
    'FINLAND': 'FI',
    'KEF': 'IS',
    'ICELAND': 'IS',
    'MXP': 'IT',
    'LIN': 'IT',
    'FCO': 'IT',
    'CIA': 'IT',
    'BLQ': 'IT',
    'NAP': 'IT',
    'VCE': 'IT',
    'ITALY': 'IT',
    'ITALYNORTH': 'IT',
    'MILAN': 'IT',
    'MAD': 'ES',
    'BCN': 'ES',
    'VLC': 'ES',
    'AGP': 'ES',
    'SVQ': 'ES',
    'BIO': 'ES',
    'SPAIN': 'ES',
    'SPAINCENTRAL': 'ES',
    'MADRID': 'ES',
    'LIS': 'PT',
    'OPO': 'PT',
    'FAO': 'PT',
    'PORTUGAL': 'PT',
    'BRU': 'BE',
    'BELGIUM': 'BE',
    'VIE': 'AT',
    'AUSTRIA': 'AT',
    'WAW': 'PL',
    'KRK': 'PL',
    'GDN': 'PL',
    'WRO': 'PL',
    'POLAND': 'PL',
    'POLANDCENTRAL': 'PL',
    'WARSAW': 'PL',
    'PRG': 'CZ',
    'CZECH': 'CZ',
    'BUD': 'HU',
    'HUNGARY': 'HU',
    'OTP': 'RO',
    'CLJ': 'RO',
    'ROMANIA': 'RO',
    'ATH': 'GR',
    'SKG': 'GR',
    'GREECE': 'GR',
    'IST': 'TR',
    'SAW': 'TR',
    'ESB': 'TR',
    'AYT': 'TR',
    'ADB': 'TR',
    'TURKEY': 'TR',
    'TURKIYE': 'TR',
    'KBP': 'UA',
    'IEV': 'UA',
    'ODS': 'UA',
    'UKRAINE': 'UA',
    'SVO': 'RU',
    'DME': 'RU',
    'VKO': 'RU',
    'LED': 'RU',
    'OVB': 'RU',
    'SVX': 'RU',
    'RUS': 'RU',
    'RUSSIA': 'RU',
    'MSQ': 'BY',
    'BELARUS': 'BY',
    'SOF': 'BG',
    'ZAG': 'HR',
    'BTS': 'SK',
    'LJU': 'SI',
    'TLL': 'EE',
    'RIX': 'LV',
    'VNO': 'LT',
    'BEG': 'RS',
    'LCA': 'CY',
    'LUX': 'LU',
    'DXB': 'AE',
    'AUH': 'AE',
    'DWC': 'AE',
    'SHJ': 'AE',
    'UAE': 'AE',
    'UAENORTH': 'AE',
    'UAECENTRAL': 'AE',
    'DUBAI': 'AE',
    'RUH': 'SA',
    'JED': 'SA',
    'DMM': 'SA',
    'SAUDI': 'SA',
    'DOH': 'QA',
    'QATAR': 'QA',
    'TLV': 'IL',
    'ISRAEL': 'IL',
    'ISRAELCENTRAL': 'IL',
    'BAH': 'BH',
    'MCT': 'OM',
    'KWI': 'KW',
    'AMM': 'JO',
    'CAI': 'EG',
    'EGYPT': 'EG',
    'JNB': 'ZA',
    'CPT': 'ZA',
    'DUR': 'ZA',
    'SOUTHAFRICA': 'ZA',
    'SOUTHAFRICANORTH': 'ZA',
    'SOUTHAFRICAWEST': 'ZA',
    'NBO': 'KE',
    'LOS': 'NG',
    'ABV': 'NG',
    'CMN': 'MA',
    'MEX': 'MX',
    'GDL': 'MX',
    'MTY': 'MX',
    'QRO': 'MX',
    'CUN': 'MX',
    'TIJ': 'MX',
    'MEXICO': 'MX',
    'MEXICOCENTRAL': 'MX',
    'GRU': 'BR',
    'GIG': 'BR',
    'BSB': 'BR',
    'CGH': 'BR',
    'SDU': 'BR',
    'CNF': 'BR',
    'POA': 'BR',
    'REC': 'BR',
    'SSA': 'BR',
    'CWB': 'BR',
    'FOR': 'BR',
    'BRAZIL': 'BR',
    'BRAZILSOUTH': 'BR',
    'BRAZILSOUTHEAST': 'BR',
    'EZE': 'AR',
    'AEP': 'AR',
    'COR': 'AR',
    'ARGENTINA': 'AR',
    'SCL': 'CL',
    'CHILE': 'CL',
    'CHILECENTRAL': 'CL',
    'BOG': 'CO',
    'COLOMBIA': 'CO',
    'LIM': 'PE',
    'PERU': 'PE',
    'PTY': 'PA',
    'PANAMA': 'PA',
  };

  String normalizeRegion(String region) {
    final clean = region.trim().toUpperCase();
    final mapped = _regionToCountryCodeMap[clean];
    if (mapped != null) {
      return mapped;
    }
    if (clean.length == 2 && RegExp(r'^[A-Z]{2}$').hasMatch(clean)) {
      return clean;
    }
    return region;
  }

  bool isTunIp(String ip, [InternetAddress? parsedAddress]) {
    final address = parsedAddress ?? InternetAddress.tryParse(ip.trim());
    if (address == null) return false;
    if (address.type == InternetAddressType.IPv4) {
      final raw = address.rawAddress;
      final p0 = raw[0];
      final p1 = raw[1];
      final p2 = raw[2];
      if (p0 == 198 && p1 == 51 && p2 == 100) return true;
      if (p0 == 198 && (p1 == 18 || p1 == 19)) return true;
    } else if (address.type == InternetAddressType.IPv6) {
      final clean = ip.trim().toLowerCase();
      if (clean.startsWith('fdfe:dcba:9876:')) return true;
    }
    return false;
  }

  IpCategory classifyIp(String ip) {
    final clean = ip.trim();
    final address = InternetAddress.tryParse(clean);
    if (address == null) return IpCategory.public;
    if (isTunIp(clean, address)) {
      return IpCategory.tun;
    }
    if (isPrivateOrReservedIp(clean, address)) {
      return IpCategory.lan;
    }
    return IpCategory.public;
  }

  bool isPrivateOrReservedIp(String ip, [InternetAddress? parsedAddress]) {
    final address = parsedAddress ?? InternetAddress.tryParse(ip.trim());
    if (address == null) return false;

    if (address.isLoopback || address.isLinkLocal || address.isMulticast) {
      return true;
    }

    if (address.type == InternetAddressType.IPv4) {
      final raw = address.rawAddress;
      final p0 = raw[0];
      final p1 = raw[1];
      final p2 = raw[2];

      if (p0 == 0) return true;
      if (p0 == 10) return true;
      if (p0 == 100 && (p1 >= 64 && p1 <= 127)) return true;
      if (p0 == 127) return true;
      if (p0 == 169 && p1 == 254) return true;
      if (p0 == 172 && (p1 >= 16 && p1 <= 31)) return true;
      if (p0 == 192 && p1 == 0 && p2 == 0) return true;
      if (p0 == 192 && p1 == 0 && p2 == 2) return true;
      if (p0 == 192 && p1 == 88 && p2 == 99) return true;
      if (p0 == 192 && p1 == 168) return true;
      if (p0 == 198 && (p1 == 18 || p1 == 19)) return true;
      if (p0 == 198 && p1 == 51 && p2 == 100) return true;
      if (p0 == 203 && p1 == 0 && p2 == 113) return true;
      if (p0 >= 224 && p0 <= 239) return true;
      if (p0 >= 240) return true;
    } else if (address.type == InternetAddressType.IPv6) {
      final clean = ip.trim().toLowerCase();
      if (clean == '::1' || clean == '::') return true;
      if (clean.startsWith('fe8') ||
          clean.startsWith('fe9') ||
          clean.startsWith('fea') ||
          clean.startsWith('feb')) {
        return true;
      }
      if (clean.startsWith('fc') || clean.startsWith('fd')) {
        return true;
      }
      if (clean.startsWith('ff')) {
        return true;
      }
      if (clean.startsWith('2001:db8:')) {
        return true;
      }
    }

    return false;
  }

  String get id {
    final timestamp = DateTime.now().microsecondsSinceEpoch;
    final random = Random();
    final randomStr = String.fromCharCodes(
      List.generate(8, (_) => random.nextInt(26) + 97),
    );
    return '$timestamp$randomStr';
  }

  String getDateStringLast2(int value) {
    var valueRaw = '0$value';
    return valueRaw.substring(valueRaw.length - 2);
  }

  String generateRandomString({int minLength = 10, int maxLength = 100}) {
    const latinChars =
        'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final random = Random();

    int length = minLength + random.nextInt(maxLength - minLength + 1);

    String result = '';
    for (int i = 0; i < length; i++) {
      if (random.nextBool()) {
        result += String.fromCharCode(
          0x4E00 + random.nextInt(0x9FA5 - 0x4E00 + 1),
        );
      } else {
        result += latinChars[random.nextInt(latinChars.length)];
      }
    }

    return result;
  }

  String get uuidV4 {
    final Random random = Random();
    final bytes = List.generate(16, (_) => random.nextInt(256));

    bytes[6] = (bytes[6] & 0x0F) | 0x40;
    bytes[8] = (bytes[8] & 0x3F) | 0x80;

    final hex = bytes
        .map((byte) => byte.toRadixString(16).padLeft(2, '0'))
        .join();

    return '${hex.substring(0, 8)}-${hex.substring(8, 12)}-${hex.substring(12, 16)}-${hex.substring(16, 20)}-${hex.substring(20, 32)}';
  }

  String getTimeDifference(DateTime dateTime) {
    var currentDateTime = DateTime.now();
    var difference = currentDateTime.difference(dateTime);
    var inHours = difference.inHours;
    var inMinutes = difference.inMinutes;
    var inSeconds = difference.inSeconds;

    return '${getDateStringLast2(inHours)}:${getDateStringLast2(inMinutes)}:${getDateStringLast2(inSeconds)}';
  }

  String getTimeText(int? timeStamp) {
    if (timeStamp == null) {
      return '00:00:00';
    }
    final diff = timeStamp / 1000;
    final inHours = (diff / 3600).floor();
    if (inHours > 99) {
      return '99:59:59';
    }
    final inMinutes = (diff / 60 % 60).floor();
    final inSeconds = (diff % 60).floor();

    return '${getDateStringLast2(inHours)}:${getDateStringLast2(inMinutes)}:${getDateStringLast2(inSeconds)}';
  }

  Locale getSystemLocale() {
    final platformLocale = WidgetsBinding.instance.platformDispatcher.locale;
    final supportedLocales = AppLocalizations.delegate.supportedLocales;

    if (platformLocale.languageCode.toLowerCase() == 'zh') {
      final isTraditional =
          (platformLocale.countryCode?.toUpperCase() == 'TW') ||
          (platformLocale.countryCode?.toUpperCase() == 'HK') ||
          (platformLocale.countryCode?.toUpperCase() == 'MO') ||
          (platformLocale.scriptCode?.toLowerCase() == 'hant');
      return isTraditional
          ? const Locale('zh', 'TC')
          : const Locale('zh', 'CN');
    }

    for (final locale in supportedLocales) {
      if (locale.languageCode == platformLocale.languageCode) {
        return locale;
      }
    }

    return const Locale('zh', 'CN');
  }

  Locale? getLocaleForString(String? localString) {
    if (localString == null) return null;
    var localSplit = localString.split('_');
    if (localSplit.length == 1) {
      return Locale(localSplit[0]);
    }
    if (localSplit.length == 2) {
      return Locale(localSplit[0], localSplit[1]);
    }
    if (localSplit.length == 3) {
      return Locale.fromSubtags(
        languageCode: localSplit[0],
        scriptCode: localSplit[1],
        countryCode: localSplit[2],
      );
    }
    return null;
  }

  int sortByChar(String a, String b) {
    final length = min(a.length, b.length);
    for (var i = 0; i < length; i++) {
      final charA = a[i];
      final charB = b[i];
      if (charA != charB) {
        return charA.compareToLower(charB);
      }
    }
    return a.length.compareTo(b.length);
  }

  String getOverwriteLabel(String label) {
    final reg = RegExp(r'\((\d+)\)$');
    final matches = reg.allMatches(label);
    if (matches.isNotEmpty) {
      final match = matches.last;
      final number = int.parse(match[1] ?? '0') + 1;
      return label.replaceFirst(reg, '($number)', label.length - 3 - 1);
    } else {
      return '$label(1)';
    }
  }

  String getTrayIconPath({
    required Brightness brightness,
    bool isStart = false,
    bool invertTrayIcon = false,
  }) {
    if (system.isLinux) {
      return 'assets/images/icon.png';
    }

    if (system.isMacOS && isStart) {
      return 'assets/images/icon_black.png';
    }

    final suffix = system.isWindows ? 'ico' : 'png';

    final darkPath = !isStart
        ? 'assets/images/icon_light.$suffix'
        : 'assets/images/icon_white.$suffix';
    final lightPath = !isStart
        ? 'assets/images/icon.$suffix'
        : 'assets/images/icon_black.$suffix';

    if (invertTrayIcon) {
      return brightness == Brightness.dark ? lightPath : darkPath;
    }

    return brightness == Brightness.dark ? darkPath : lightPath;
  }

  int compareVersions(String version1, String version2) {
    List<String> v1 = version1.split('+')[0].split('.');
    List<String> v2 = version2.split('+')[0].split('.');
    int major1 = int.parse(v1[0]);
    int major2 = int.parse(v2[0]);
    if (major1 != major2) {
      return major1.compareTo(major2);
    }
    int minor1 = v1.length > 1 ? int.parse(v1[1]) : 0;
    int minor2 = v2.length > 1 ? int.parse(v2[1]) : 0;
    if (minor1 != minor2) {
      return minor1.compareTo(minor2);
    }
    int patch1 = v1.length > 2 ? int.parse(v1[2]) : 0;
    int patch2 = v2.length > 2 ? int.parse(v2[2]) : 0;
    if (patch1 != patch2) {
      return patch1.compareTo(patch2);
    }
    int build1 = version1.contains('+') ? int.parse(version1.split('+')[1]) : 0;
    int build2 = version2.contains('+') ? int.parse(version2.split('+')[1]) : 0;
    return build1.compareTo(build2);
  }

  final Map<String, String> _pinyinCache = {};

  String getPinyin(String value) {
    if (value.isEmpty) return '';
    return _pinyinCache.putIfAbsent(
      value.substring(0, 1),
      () => PinyinHelper.getFirstWordPinyin(value.substring(0, 1)),
    );
  }

  String? getFileNameForDisposition(String? disposition) {
    if (disposition == null) return null;
    final parseValue = HeaderValue.parse(disposition);
    final parameters = parseValue.parameters;
    final fileNamePointKey = parameters.keys.firstWhere(
      (key) => key == 'filename*',
      orElse: () => '',
    );
    if (fileNamePointKey.isNotEmpty) {
      final res = parameters[fileNamePointKey]?.split("''") ?? [];
      if (res.length >= 2) {
        return Uri.decodeComponent(res[1]);
      }
    }
    final fileNameKey = parameters.keys.firstWhere(
      (key) => key == 'filename',
      orElse: () => '',
    );
    if (fileNameKey.isEmpty) return null;
    return parameters[fileNameKey];
  }

  FlutterView getScreen() {
    return WidgetsBinding.instance.platformDispatcher.views.first;
  }

  List<String> parseReleaseBody(String? body) {
    if (body == null) return [];
    const pattern = r'^\s*-\s+(.+)';
    final regex = RegExp(pattern, multiLine: true);
    return regex
        .allMatches(body)
        .map((match) => match.group(1)?.trim() ?? '')
        .where(
          (item) =>
              item.isNotEmpty &&
              !item.startsWith('---') &&
              !item.startsWith(':') &&
              !item.startsWith('|') &&
              !item.startsWith('['),
        )
        .toList();
  }

  ViewMode getViewMode(double viewWidth) {
    if (viewWidth <= maxMobileWidth) return ViewMode.mobile;
    if (viewWidth <= maxLaptopWidth) return ViewMode.laptop;
    return ViewMode.desktop;
  }

  int getProxiesColumns(double viewWidth, ProxiesLayout proxiesLayout) {
    final columns = max((viewWidth / 300).ceil(), 2);
    return switch (proxiesLayout) {
      ProxiesLayout.tight => columns + 1,
      ProxiesLayout.standard => columns,
      ProxiesLayout.loose => columns - 1,
    };
  }

  int getProfilesColumns(double viewWidth) {
    return min(max((viewWidth / 320).floor(), 1), 3);
  }

  final _indexPrimary = [50, 100, 200, 300, 400, 500, 600, 700, 800, 850, 900];

  MaterialColor _createPrimarySwatch(Color color) {
    final Map<int, Color> swatch = <int, Color>{};
    final int a = color.alpha8bit;
    final int r = color.red8bit;
    final int g = color.green8bit;
    final int b = color.blue8bit;
    for (final int strength in _indexPrimary) {
      final double ds = 0.5 - strength / 1000;
      swatch[strength] = Color.fromARGB(
        a,
        r + ((ds < 0 ? r : (255 - r)) * ds).round(),
        g + ((ds < 0 ? g : (255 - g)) * ds).round(),
        b + ((ds < 0 ? b : (255 - b)) * ds).round(),
      );
    }
    swatch[50] = swatch[50]!.lighten(18);
    swatch[100] = swatch[100]!.lighten(16);
    swatch[200] = swatch[200]!.lighten(14);
    swatch[300] = swatch[300]!.lighten(10);
    swatch[400] = swatch[400]!.lighten(6);
    swatch[700] = swatch[700]!.darken(2);
    swatch[800] = swatch[800]!.darken(3);
    swatch[900] = swatch[900]!.darken(4);
    return MaterialColor(color.value32bit, swatch);
  }

  List<Color> getMaterialColorShades(Color color) {
    final swatch = _createPrimarySwatch(color);
    return <Color>[
      if (swatch[50] != null) swatch[50]!,
      if (swatch[100] != null) swatch[100]!,
      if (swatch[200] != null) swatch[200]!,
      if (swatch[300] != null) swatch[300]!,
      if (swatch[400] != null) swatch[400]!,
      if (swatch[500] != null) swatch[500]!,
      if (swatch[600] != null) swatch[600]!,
      if (swatch[700] != null) swatch[700]!,
      if (swatch[800] != null) swatch[800]!,
      if (swatch[850] != null) swatch[850]!,
      if (swatch[900] != null) swatch[900]!,
    ];
  }

  String getBackupFileName() {
    return '${appName}_backup_${DateTime.now().show}.zip';
  }

  String get logFile {
    return '${appName}_${DateTime.now().show}.log';
  }

  Future<String?> getLocalIpAddress() async {
    List<NetworkInterface> interfaces =
        await NetworkInterface.list(includeLoopback: false)
          ..sort((a, b) {
            if (a.isWifi && !b.isWifi) return -1;
            if (!a.isWifi && b.isWifi) return 1;
            if (a.includesIPv4 && !b.includesIPv4) return -1;
            if (!a.includesIPv4 && b.includesIPv4) return 1;
            return 0;
          });
    for (final interface in interfaces) {
      final nameLower = interface.name.toLowerCase();
      if (nameLower.contains('tun') ||
          nameLower.contains('vpn') ||
          nameLower.contains('tap') ||
          nameLower.contains('ppp')) {
        continue;
      }
      final addresses = interface.addresses;
      if (addresses.isEmpty) {
        continue;
      }
      addresses.sort((a, b) {
        if (a.isIPv4 && !b.isIPv4) return -1;
        if (!a.isIPv4 && b.isIPv4) return 1;
        return 0;
      });
      return addresses.first.address;
    }
    return '';
  }

  Future<List<String>> getLocalGateways() async {
    if (system.isAndroid) {
      try {
        final gateways = await const MethodChannel(
          'service',
        ).invokeListMethod<String>('getLocalGateways');
        if (gateways != null && gateways.isNotEmpty) {
          return gateways;
        }
      } catch (_) {
        try {
          final gateways = await const MethodChannel(
            'vpn',
          ).invokeListMethod<String>('getLocalGateways');
          if (gateways != null && gateways.isNotEmpty) {
            return gateways;
          }
        } catch (_) {}
      }
    }
    final routes = await _getDefaultRoutes();
    return routes.map((route) => route.gateway).toList();
  }

  Future<List<String>> getLanAddresses() async {
    final addresses = <String>[];
    void add(String address) {
      if (address.isNotEmpty && !addresses.contains(address)) {
        addresses.add(address);
      }
    }

    try {
      final primary = (await getNetworkInfo()).ip;
      if (primary.isNotEmpty && !primary.contains(':')) add(primary);
      if (system.isAndroid) {
        final list = await const MethodChannel(
          'service',
        ).invokeListMethod<String>('getLocalIpAddresses');
        for (final address in list ?? const <String>[]) {
          add(address);
        }
        return addresses;
      }
      for (final address in await getInterfaceIPv4Addresses()) {
        add(address);
      }
    } catch (_) {}
    return addresses;
  }

  Future<List<String>> getInterfaceIPv4Addresses() async {
    final interfaces = await NetworkInterface.list(includeLoopback: false);
    return [
      for (final interface in interfaces)
        if (!_virtualInterfaceRegExp.hasMatch(interface.name) &&
            !_bridgeInterfaceRegExp.hasMatch(interface.name))
          for (final address in interface.addresses)
            if (address.isIPv4 && !address.isLinkLocal) address.address,
    ];
  }

  Future<NetworkInfo> getNetworkInfo() async {
    try {
      if (system.isAndroid) {
        final info = await const MethodChannel(
          'service',
        ).invokeMapMethod<String, Object?>('getNetworkInfo');
        return info == null ? const NetworkInfo() : NetworkInfo.fromJson(info);
      }
      final routes = await _getDefaultRoutes();
      final route = routes
          .where(
            (route) =>
                route.gateway != '0.0.0.0' &&
                !_virtualInterfaceRegExp.hasMatch(route.interfaceName),
          )
          .firstOrNull;
      final interfaces = await NetworkInterface.list(includeLoopback: false);
      final matchedInterface = interfaces
          .where((interface) => interface.name == route?.interfaceName)
          .firstOrNull;
      final Iterable<InternetAddress> addresses =
          matchedInterface?.addresses.where(
            (address) => !address.isLinkLocal,
          ) ??
          const <InternetAddress>[];
      final address =
          addresses.where((address) => address.isIPv4).firstOrNull ??
          addresses.firstOrNull;
      return NetworkInfo(
        type: await _getConnectivityType(),
        interfaceName: route?.interfaceName ?? '',
        ip: address?.address ?? await getLocalIpAddress() ?? '',
        gateway: route?.gateway ?? '',
        dns: await _getSystemDns(),
      );
    } catch (_) {
      return const NetworkInfo();
    }
  }

  Future<bool> isCellularNetwork() async {
    return await _getConnectivityType() == 'Cellular';
  }

  Future<String> _getConnectivityType() async {
    try {
      final results = await Connectivity().checkConnectivity();
      if (results.contains(ConnectivityResult.wifi)) return 'Wi-Fi';
      if (results.contains(ConnectivityResult.ethernet)) return 'Ethernet';
      if (results.contains(ConnectivityResult.mobile)) return 'Cellular';
    } catch (_) {}
    return '';
  }

  Future<List<String>> _getSystemDns() async {
    if (Platform.isMacOS) {
      return await MacOS().systemDns ?? [];
    }
    if (Platform.isWindows) {
      return _getWindowsDns();
    }
    if (Platform.isLinux) {
      return _getLinuxDns();
    }
    return [];
  }

  Future<List<String>> _getWindowsDns() async {
    try {
      final result = await Process.run('powershell', [
        '-NoProfile',
        '-Command',
        r'$route = Get-NetRoute -DestinationPrefix "0.0.0.0/0" | Where-Object { $_.InterfaceAlias -notmatch "(?i)(tun|tap|wintun|meta|clash|vpn)" -and $_.NextHop -ne "0.0.0.0" } | Sort-Object RouteMetric | Select-Object -First 1; if ($route) { (Get-DnsClientServerAddress -InterfaceIndex $route.InterfaceIndex -AddressFamily IPv4).ServerAddresses } else { (Get-DnsClientServerAddress -AddressFamily IPv4).ServerAddresses }',
      ]);
      if (result.exitCode != 0) return [];
      final lines = result.stdout.toString().split('\n');
      final servers = <String>[];
      for (final line in lines) {
        final server = line.trim();
        if (server.isEmpty) continue;
        if (!RegExp(r'^\d{1,3}(\.\d{1,3}){3}$').hasMatch(server)) continue;
        if (server.startsWith('198.18.') || server == '127.0.0.1') continue;
        servers.add(server);
      }
      return servers.toSet().toList();
    } catch (_) {
      return [];
    }
  }

  Future<List<String>> _getLinuxDns() async {
    try {
      final file = File('/etc/resolv.conf');
      if (!await file.exists()) return [];
      final lines = await file.readAsLines();
      final servers = <String>[];
      for (final line in lines) {
        final trimmed = line.trim();
        if (trimmed.startsWith('nameserver ')) {
          final server = trimmed.substring('nameserver '.length).trim();
          if (server.isNotEmpty &&
              !server.startsWith('198.18.') &&
              server != '127.0.0.1') {
            servers.add(server);
          }
        }
      }
      return servers.toSet().toList();
    } catch (_) {
      return [];
    }
  }

  Future<List<_DefaultRoute>> _getDefaultRoutes() async {
    if (Platform.isLinux) {
      return _getLinuxDefaultRoutes();
    }
    if (Platform.isMacOS) {
      return _getMacOSDefaultRoutes();
    }
    if (Platform.isWindows) {
      return _getWindowsDefaultRoutes();
    }
    return [];
  }

  Future<List<_DefaultRoute>> _getLinuxDefaultRoutes() async {
    try {
      final routeFile = File('/proc/net/route');
      if (!await routeFile.exists()) return [];

      final lines = await routeFile.readAsLines();
      final routes = <({_DefaultRoute route, int metric})>[];
      // Header: Iface Destination Gateway Flags RefCnt Use Metric Mask ...
      for (final line in lines.skip(1)) {
        final parts = line.trim().split(RegExp(r'\s+'));
        if (parts.length < 3) continue;
        if (parts[1] != '00000000') continue; // default route destination
        final gwHex = parts[2];
        if (gwHex == '00000000') continue; // no gateway
        // /proc/net/route stores IPv4 in little-endian hex
        final bytes = [
          int.parse(gwHex.substring(6, 8), radix: 16),
          int.parse(gwHex.substring(4, 6), radix: 16),
          int.parse(gwHex.substring(2, 4), radix: 16),
          int.parse(gwHex.substring(0, 2), radix: 16),
        ];
        routes.add((
          route: (gateway: bytes.join('.'), interfaceName: parts[0]),
          metric: int.tryParse(parts.elementAtOrNull(6) ?? '') ?? 0,
        ));
      }
      routes.sort((a, b) => a.metric.compareTo(b.metric));
      return routes.map((e) => e.route).toList();
    } catch (e) {
      commonPrint.warn('Smart Auto Stop: Linux gateway error: $e');
      return [];
    }
  }

  Future<List<_DefaultRoute>> _getMacOSDefaultRoutes() async {
    try {
      final result = await Process.run('route', ['-n', 'get', 'default']);
      if (result.exitCode != 0) return [];

      var gateway = '';
      var interfaceName = '';
      for (final line in result.stdout.toString().split('\n')) {
        final trimmed = line.trim();
        if (trimmed.startsWith('gateway:')) {
          gateway = trimmed.substring('gateway:'.length).trim();
        } else if (trimmed.startsWith('interface:')) {
          interfaceName = trimmed.substring('interface:'.length).trim();
        }
      }
      // Exclude IPv6/link-local gateways
      if (gateway.isEmpty || gateway.contains(':')) return [];
      return [(gateway: gateway, interfaceName: interfaceName)];
    } catch (e) {
      commonPrint.warn('Smart Auto Stop: macOS gateway error: $e');
      return [];
    }
  }

  Future<List<_DefaultRoute>> _getWindowsDefaultRoutes() async {
    try {
      final result = await Process.run('powershell', [
        '-NoProfile',
        '-Command',
        r"Get-NetRoute -DestinationPrefix '0.0.0.0/0' "
            r'| Sort-Object RouteMetric '
            r'| ForEach-Object { "$($_.NextHop)|$($_.InterfaceAlias)" }',
      ]);
      if (result.exitCode != 0) return [];

      final routes = <_DefaultRoute>[];
      for (final line in result.stdout.toString().split('\n')) {
        final parts = line.trim().split('|');
        final gateway = parts.first;
        if (gateway.isEmpty) continue;
        if (!RegExp(r'^\d{1,3}(\.\d{1,3}){3}$').hasMatch(gateway)) continue;
        routes.add((gateway: gateway, interfaceName: parts.skip(1).join('|')));
      }
      return routes;
    } catch (e) {
      commonPrint.warn('Smart Auto Stop: Windows gateway error: $e');
      return [];
    }
  }

  SingleActivator controlSingleActivator(LogicalKeyboardKey trigger) {
    final control = system.isMacOS ? false : true;
    return SingleActivator(trigger, control: control, meta: !control);
  }

  FutureOr<T> handleWatch<T>(Function function) async {
    if (kDebugMode) {
      final stopwatch = Stopwatch()..start();
      final res = await function();
      stopwatch.stop();
      commonPrint.debug('Time：${stopwatch.elapsedMilliseconds} ms');
      return res;
    }
    return await function();
  }

  String generateSecret() {
    const groups = [
      'ABCDEFGHJKLMNPQRSTUVWXYZ',
      'abcdefghijkmnpqrstuvwxyz',
      '23456789',
      '!@*-_~',
    ];
    final random = Random.secure();
    final all = groups.join();
    String pick(String chars) => chars[random.nextInt(chars.length)];
    final chars = [
      for (final group in groups) pick(group),
      for (var i = groups.length; i < 10; i++) pick(all),
    ]..shuffle(random);
    return chars.join();
  }

  String patchYamlConfig(String content) {
    if (!content.contains('\t')) return content;
    return content.replaceAllMapped(
      RegExp(r'^[ \t]*\t[ \t]*', multiLine: true),
      (match) => match.group(0)!.replaceAll('\t', '  '),
    );
  }

  String patchValidateConfig(String content) {
    final patched = patchYamlConfig(content);
    final regExp = RegExp(
      r'^(\s*geodata-mode\s*:\s*)(true|\x27true\x27|\x22true\x22)(.*)$',
      multiLine: true,
      caseSensitive: false,
    );
    return patched.replaceAllMapped(regExp, (match) {
      return '${match.group(1)}false${match.group(3)}';
    });
  }

  String encryptSecret(String raw) {
    if (raw.isEmpty) return raw;
    const salt = 'Bettbox';
    final step1 = base64.encode(utf8.encode(raw));
    final step2 = base64.encode(utf8.encode('$salt:$step1'));
    return 'ENC~$step2';
  }

  String decryptSecret(String text) {
    if (!text.startsWith('ENC~')) return text;
    try {
      const salt = 'Bettbox';
      final cipher = text.substring(4);
      final salted = utf8.decode(base64.decode(cipher));
      if (salted.startsWith('$salt:')) {
        final step1 = salted.substring(salt.length + 1);
        return utf8.decode(base64.decode(step1));
      }
      return text;
    } catch (_) {
      return text;
    }
  }
}

final utils = Utils();
