import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui';

import 'package:charset/charset.dart';
import 'package:dio/dio.dart';
import 'package:qzone/provider_decorator.dart';
import 'package:qzone/repositories/entities/entities.dart';
import 'package:qzone/repositories/models/user_model.dart';
import 'package:qzone/utils/utils.dart';

// # 全局header
final headers = {
  'authority': 'user.qzone.qq.com',
  'accept': 'text/html,application/xhtml+xml,application/xml;q=0.9,image/avif,image/webp,image/apng,*/*;q=0.8,'
      'application/signed-exchange;v=b3;q=0.7',
  'accept-language': 'zh-CN,zh;q=0.9,en;q=0.8,en-GB;q=0.7,en-US;q=0.6',
  'cache-control': 'no-cache',
  'pragma': 'no-cache',
  'sec-ch-ua': '"Not A(Brand";v="99", "Microsoft Edge";v="121", "Chromium";v="121"',
  'sec-ch-ua-mobile': '?0',
  'sec-ch-ua-platform': '"Windows"',
  'sec-fetch-dest': 'document',
  'sec-fetch-mode': 'navigate',
  'sec-fetch-site': 'none',
  'sec-fetch-user': '?1',
  'upgrade-insecure-requests': '1',
  // # Temporarily fix waf issues
  'user-agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/122.0.0.0 Safari/537.36 Edg/122.0.0.0',
};

final Dio dio = Dio();

class AppResponse<T> {
  final String message;
  final AppResponseStatus code;
  final T data;

  late final Headers headers;

  AppResponse({
    required this.message,
    required this.code,
    required this.data,
  });

  factory AppResponse.success(T data) {
    return AppResponse<T>(
      message: "success",
      code: AppResponseStatus.success,
      data: data,
    );
  }

  factory AppResponse.failed(T data) {
    return AppResponse<T>(
      message: "failed",
      code: AppResponseStatus.failed,
      data: data,
    );
  }

  factory AppResponse.buzy(T data) {
    return AppResponse<T>(
      message: "buzy",
      code: AppResponseStatus.buzy,
      data: data,
    );
  }

  factory AppResponse.expired(T data) {
    return AppResponse<T>(
      message: "expired",
      code: AppResponseStatus.expired,
      data: data,
    );
  }

  factory AppResponse.empty(T data) {
    return AppResponse<T>(
      message: "empty",
      code: AppResponseStatus.empty,
      data: data,
    );
  }

  factory AppResponse.server(T data) {
    return AppResponse<T>(
      message: "server",
      code: AppResponseStatus.server,
      data: data,
    );
  }
}

enum AppResponseStatus {
  success,
  failed,
  buzy,
  expired,
  empty,
  server,
}

enum QRCodeStatus {
  // 二维码已失效 -> 已过期
  expired("65"),
  // 二维码未失效 -> 等待扫码
  waiting("66"),
  // 二维码认证中 -> 等待结果
  scanned("67"),
  // 本次登录已被拒绝 -> 已拒绝
  reject("68"),
  // 登录成功  -> 已登录
  resolve("0");

  final String code;

  const QRCodeStatus(this.code);

  factory QRCodeStatus.fromCode(String code) {
    return QRCodeStatus.values.firstWhere(
      (element) => element.code == code,
    );
  }
}

Future<Response<Uint8List>> requestLoginQRCode() async {
  final response = await dio.get<Uint8List>(
    "https://ssl.ptlogin2.qq.com/ptqrshow?appid=549000912&e=2&l=M&s=3&d=72&v=4&t=0.8692955245720428&daid=5&pt_3rd_aid=0",
    options: Options(
      responseType: ResponseType.bytes,
    ),
  );

  return response;
}

class LoginQRCodeResponse {
  final QRCodeStatus status;

  final String? qq;
  final String? ptsigx;

  LoginQRCodeResponse({required this.status, required this.qq, required this.ptsigx});
}

Future<AppResponse<LoginQRCodeResponse>> requestLoginQRCodeStatus({
  required String qrsig,
  required String ptqrtoken,
}) async {
  final timestamp = DateTime.now().millisecondsSinceEpoch;

  final response = await dio.get<String>(
    "https://ssl.ptlogin2.qq.com/ptqrlogin",
    queryParameters: {
      "u1": "https://qzs.qq.com/qzone/v5/loginsucc.html?para=izone",
      "ptqrtoken": ptqrtoken,
      "ptredirect": "0",
      "h": "1",
      "t": "1",
      "g": "1",
      "from_ui": "1",
      "ptlang": "2052",
      "action": "0-3-$timestamp",
      "js_type": "1",
      "pt_uistyle": "40",
      "aid": "549000912",
      "daid": "5",
    },
    options: Options(
      headers: {
        "Cookie": "qrsig=$qrsig",
      },
    ),
  );

  final match = RegExp(r"ptuiCB\('(.+?)',").firstMatch(response.data!);
  final code = match?[1];
  final status = QRCodeStatus.fromCode(code!);

  String? qq;
  String? ptsigx;

  if (status == QRCodeStatus.resolve) {
    final matchUni = RegExp(r"uin=(.*?)&").firstMatch(response.data!);
    final matchPtsigx = RegExp(r"ptsigx=(.*?)&").firstMatch(response.data!);
    qq = matchUni?[1];
    ptsigx = matchPtsigx?[1];
  }

  return AppResponse.success(LoginQRCodeResponse(status: status, qq: qq, ptsigx: ptsigx))..headers = response.headers;
}

Future<AppResponse<List<Cookie>>> requestUserToken({
  required String qq,
  required String ptsigx,
  required List<Cookie> cookies,
}) async {
  final response = await dio.get<String>(
    "https://ssl.ptlogin2.qq.com/check_sig",
    queryParameters: {
      "pttype": "1",
      "uin": qq,
      "service": "ptqrlogin",
      "nodirect": "0",
      "ptsigx": ptsigx,
      "s_url": "https://qzs.qq.com/qzone/v5/loginsucc.html?para=izone",
      "f_url": "",
      "ptlang": "2052",
      "ptredirect": "100",
      "aid": "549000912",
      "daid": "5",
      "j_later": "0",
      "low_login_hour": "0",
      "regmaster": "0",
      "pt_login_type": "3",
      "pt_aid": "0",
      "pt_aaid": "16",
      "pt_light": "0",
      "pt_3rd_aid": "0"
    },
    options: Options(
      followRedirects: false,
      headers: {
        "Cookie": cookies.toCookieStr(),
      },
      validateStatus: (status) => true,
    ),
  );

  final cookiesRes = resolveCookiesFromArray(response.headers["set-cookie"] ?? []);

  return AppResponse.success(cookiesRes)..headers = response.headers;
}

Future<AppResponse<LoginUser>> requestLoginUser({
  required String gTk,
  required String qq,
  required List<Cookie> cookies,
}) async {
  final response = await dio.get<String>(
    "https://r.qzone.qq.com/fcg-bin/cgi_get_portrait.fcg",
    queryParameters: {"g_tk": gTk, "uins": qq},
    options: Options(
      headers: {
        ...headers,
        "Cookie": cookies.toCookieStr(),
      },
    ),
  );

  final match = RegExp(r"portraitCallBack\((.*?)\)").firstMatch(response.data!);
  final Map<String, dynamic> map = jsonDecode(match![1]!);
  final String nickname = map[qq][6];

  LoginUser user = LoginUser(qq: qq, nickname: nickname, cookies: cookies);

  return AppResponse.success(user)..headers = response.headers;
}

Future<AppResponse<String>> requestRawMoments({
  required LoginUser user,
  required int pages,
  required int count,
}) async {
  final response = await dio.get<String>(
    "https://user.qzone.qq.com/proxy/domain/ic2.qzone.qq.com/cgi-bin/feeds/feeds2_html_pav_all",
    queryParameters: {
      'uin': user.qq,
      'offset': pages,
      'count': count,
      'g_tk': [user.gTk, user.gTk],
      'begin_time': '0',
      'end_time': '0',
      'getappnotification': '1',
      'getnotifi': '1',
      'has_get_key': '0',
      'set': '0',
      'useutf8': '1',
      'outputhtmlfeed': '1',
      'scope': '1',
      'format': 'jsonp',
    },
    options: Options(
      headers: {
        ...headers,
        "Cookie": user.cookies.toCookieStr(),
      },
      validateStatus: (status) => true,
    ),
  );
  final text = response.data!;
  // print(text);

  '''
<!DOCTYPE html>
<html>
	<head>
		<script>
			var i = location.href;
			var v = window.btoa ? window.btoa(window.encodeURIComponent(i)) : "";
			window.location.href =
				"https://waf.tencent.com/501page.html?u=" +
				location.origin +
				"&id=06aca9717556661ee3cee1ec240d1054-1729235285642661-435-139664094562048-8531672997625596&st=03&v=" +
				v;
		</script>
	</head>
</html>
''';

  // 一般是 500 才会返回空数据
  if (text.isEmpty || response.statusCode == 500 || text.contains("<!DOCTYPE html><html><head><script>")) {
    return AppResponse.server("")..headers = response.headers;
  }

  '''
_Callback({
	"code":-3000,
	"subcode":-4001,
	"message":"need login",
	"notice":0,
	"time":1730537909,
	"tips":"0103-87"
}
);''';

  // 未登录 / Token过期
  if (text.contains("\"code\":-3000")) {
    return AppResponse.expired("")..headers = response.headers;
  }

  // 网络繁忙
  if (text.contains("\"code\":-10001")) {
    return AppResponse.buzy("")..headers = response.headers;
  }

  // 空数据
  if (text.contains("data:[undefined]")) {
    return AppResponse.empty("")..headers = response.headers;
  }

  return AppResponse.success(text)..headers = response.headers;
}

Future<AppResponse<String>> requestAvatar({
  required LoginUser user,
  required int pages,
  required int count,
}) async {
  final response = await dio.get<String>(
    "https://user.qzone.qq.com/proxy/domain/ic2.qzone.qq.com/cgi-bin/feeds/feeds2_html_pav_all",
    queryParameters: {
      'uin': user.qq,
      'offset': pages,
      'count': count,
      'g_tk': [user.gTk, user.gTk],
      'begin_time': '0',
      'end_time': '0',
      'getappnotification': '1',
      'getnotifi': '1',
      'has_get_key': '0',
      'set': '0',
      'useutf8': '1',
      'outputhtmlfeed': '1',
      'scope': '1',
      'format': 'jsonp',
    },
    options: Options(
      headers: {
        ...headers,
        "Cookie": user.cookies.toCookieStr(),
      },
    ),
  );

  '''
_Callback({
	"code":-3000,
	"subcode":-4001,
	"message":"need login",
	"notice":0,
	"time":1730537909,
	"tips":"0103-87"
}
);''';

  // 未登录 / Token过期
  final text = response.data!;
  if (text.contains("\"code\":-3000")) {
    return AppResponse.expired("")..headers = response.headers;
  }

  // 网络繁忙
  if (text.contains("\"code\":-10001")) {
    return AppResponse.buzy("")..headers = response.headers;
  }

  return AppResponse.success(text)..headers = response.headers;
}

Future<AppResponse<String>> requestRawMomentsMock({
  required LoginUser user,
  required int pages,
  required int count,
}) async {
  final data = File("test/moments/moments_$pages.txt").readAsStringSync();

  return AppResponse.success(data);
}
