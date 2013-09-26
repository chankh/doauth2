library util_test;

import '../lib/src/common/util.dart';
import 'package:unittest/unittest.dart';

final String uri = 'http://localhost:3030/test';

main() {
  group('urlEncode', () {
    test("without params", () {
      String result = urlEncode(uri, {});

      expect(result, equals(uri));
    });

    test("with 1 param", () {
      String result = urlEncode(uri, {"param1" : "value1"});

      expect(result, equals(uri + "?param1=value1"));
    });
    test("with 3 params", () {
      Map<String, String> params = {"param1" : "value1", "param2" : 2, "param3" : ""};
      String result = urlEncode(uri, params);

      expect(result, equals(uri + "?param1=value1&param2=2&param3="));
    });
  });

  group('urlDecode', () {
    test("without +", () {
      String original = "some test with !?\$%()*+=&";
      String encoded = Uri.encodeComponent(original);
      String result = urlDecode(encoded);

      expect(result, equals(original));
    });

    test("with +", () {
      String original = "some test with !?\$%()*+=&";
      String encoded = Uri.encodeComponent(original);
      String result = urlDecode(encoded + "with+");

      expect(result, equals(original + "with "));
    });
  });

  group('queryToMap', () {
    test('empty query', () {
      Map result = queryToMap('');
      expect(result, equals({}));
    });

    test('null query', () {
      Map result = queryToMap(null);
      expect(result, equals({}));
    });

    test('with 1 param', () {
      Map result = queryToMap("param1=value1");
      expect(result, hasLength(1));
      expect(result, containsPair('param1', 'value1'));
    });

    test('with 3 params', () {
      String query = "param1=value1&param2=2&param3=";
      Map result = queryToMap(query);
      expect(result, hasLength(3));
      expect(result, containsPair('param1', 'value1'));
      expect(result, containsPair('param2', '2'));
      expect(result, containsPair('param3', ''));
    });

    test('with multi value params', () {
      String query = "param1=a,b,c&param2=1=a&param3=3==c";
      Map result = queryToMap(query);
      expect(result, hasLength(3));
      expect(result, containsPair('param1', 'a,b,c'));
      expect(result, containsPair('param2', '1=a'));
      expect(result, containsPair('param3', '3==c'));
    });
  });
}