import 'dart:io';

extension ListCookieOps on List<Cookie> {
  String? getValue(String key) {
    for (Cookie cookie in this) {
      if (cookie.name == key) {
        return cookie.value;
      }
    }
    return null;
  }

  String toCookieStr() => map((cookie) => "${cookie.name}=${cookie.value}").join("; ");
}

List<Cookie> resolveCookiesFromArray(List<String> cookies) {
  return cookies.map(Cookie.fromSetCookieValue).where((item) => item.value.isNotEmpty).toList();
}

// 实现BKN
int bkn(String pSkey) {
  // 计算bkn

  int t = 5381;
  int n = 0;
  int o = pSkey.length;

  while (n < o) {
    t += (t << 5) + pSkey.codeUnitAt(n);
    n += 1;
  }

  return t & 2147483647;
}

// 实现PTQRToken
int ptqrToken(String qrsig) {
  // 计算ptqrtoken
  int n = qrsig.length;
  int i = 0;
  int e = 0;

  while (n > i) {
    e += (e << 5) + qrsig.codeUnitAt(i);
    i += 1;
  }

  return e & 2147483647;
}
