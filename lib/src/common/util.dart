library util;

/// Encodes the given url and params into an URL-encoded string, includes
/// appending parameters after `?` in `name=value` format.
String urlEncode(String url, Map<String, String> params) {
  String res = url;
  var k;
  int i = 0;
  var firstSeparator = (url.indexOf("?") == -1) ? '?' : '&';
  params.forEach((k, v) => res += (i++ == 0 ? firstSeparator : '&') + Uri.encodeComponent(k.toString()) + '=' + Uri.encodeComponent(v.toString()));
  return res;
}

/// Decodes a URL-encoded string. Unlike [decodeUriComponent], this includes
/// replacing `+` with ` `.
String urlDecode(String encoded) =>
  Uri.decodeComponent(encoded.replaceAll("+", " "));

/// Converts a URL query string (or `application/x-www-form-urlencoded` body)
/// into a [Map] from parameter names to values.
///
///     queryToMap("foo=bar&baz=bang&qux");
///     //=> {"foo": "bar", "baz": "bang", "qux": ""}
Map<String, String> queryToMap(String queryString) {
  var map = {};
  if (queryString == null) return map;
  for (var pair in queryString.split("&")) {
    var split = _split1(pair, "=");
    if (split.isEmpty) continue;
    var key = urlDecode(split[0]);
    var value = urlDecode(split.length > 1 ? split[1] : "");
    map[key] = value;
  }
  return map;
}

/// Like [String.split], but only splits on the first occurrence of the pattern.
/// This will always return an array of two elements or fewer.
///
///     split1("foo,bar,baz", ","); //=> ["foo", "bar,baz"]
///     split1("foo", ","); //=> ["foo"]
///     split1("", ","); //=> []
List<String> _split1(String toSplit, String pattern) {
  if (toSplit.isEmpty) return <String>[];

  var index = toSplit.indexOf(pattern);
  if (index == -1) return [toSplit];
  return [
    toSplit.substring(0, index),
    toSplit.substring(index + pattern.length)
  ];
}


double epoch() {
  return new DateTime.now().millisecondsSinceEpoch / 1000;
}