library doauth2;

import 'dart:html';
import 'package:json/json.dart' as json;
import 'package:logging/logging.dart';
import 'src/common/util.dart';

part 'src/browser/tokenstorage.dart';

class Config {
  String clientId;

  String redirectUri;

  String authorization;

  String scope;

  String permanentScope;

  bool isDefault = false;

  int defaultLifetime = -1;

  Config(this.clientId, this.redirectUri, this.authorization);
}

Map<String, Config> _configs;

int defaultLifetime = 3600;

Map _options = { "debug" : false };

TokenStorage _tokenStorage = new TokenStorage();

List internalStates = [];

final Logger log = new Logger('doauth2');

void _setOptions(Map opts) {
  if (opts == null || opts.isEmpty) return;

  _options.addAll(opts);
  log.info('Applied options: ' + _options.toString());
}


_checkForToken(String providerId, { String url, callback }) {
  var atoken;
  String h = window.location.hash;
  double now = epoch();
  Map state;
  Config config;

  log.fine("checkForToken(" + providerId + ")");

  // If a url is provided
  if (url != null && url.isNotEmpty) {
    int hashIndex = url.indexOf('#');
    if (hashIndex == -1) return null;
    h = url.substring(hashIndex);
  }

  // Start with checking if there is a token in the hash
  if (h.length < 2) return null;
  if (h.indexOf('access_token') == -1) return null;
  h = h.substring(1);
  atoken = queryToMap(h);

  if (atoken.containsKey('state')) {
    state = _tokenStorage.getState(atoken['state']);
  } else {
    if (providerId == null || providerId.isEmpty) {
      throw "Could not get [state] and no default profile ID is provided.";
    }
    state = { 'providerId' : providerId };
  }

  if (state == null) throw "Could not retrieve state.";
  if (!state.containsKey('providerId')) throw "Could not get providerId from state";
  if (_configs[state['providerId']] == null) throw "Could not retrieve config for this provider.";
  config = _configs[state['providerId']];

  /**
   * If state was not provided, and default provider contains a scope parameter
   * we assume this is the one requested...
   */
  if (!atoken.containsKey('state') && config.scope != null) {
    state['scopes'] = config.scope;
  }

  /*
   * Decide when this token should expire.
   * Priority fallback:
   * 1. Access token expires_in
   * 2. Life time in config (may be false = permanent...)
   * 3. Specific permanent scope.
   * 4. Default library lifetime:
   */
  if (atoken.containsKey("expires_in")) {
    atoken["expires"] = now + int.parse(atoken["expires_in"], radix: 10);
  } else if (config.defaultLifetime == -1) {
    // Token is permanent.
  } else if (config.defaultLifetime > 0) {
    atoken["expires"] = now + config.defaultLifetime;
  } else if (config.permanentScope != null) {
    if (!_tokenStorage.hasScope(atoken, config.permanentScope)) {
      atoken["expires"] = now + defaultLifetime;
    }
  } else {
    atoken["expires"] = now + defaultLifetime;
  }

  /*
   * Handle scopes for this token
   */
  if (atoken.containsKey("scope")) {
    atoken["scopes"] = atoken["scope"].split(" ");
  } else if (state.containsKey("scopes")) {
    atoken["scopes"] = state["scopes"];
  }

  _tokenStorage.saveToken(state['providerId'], atoken);

  if (state.containsKey('restoreHash')) {
    window.location.hash = state['restoreHash'];
  } else {
    window.location.hash = '';
  }

  log.fine(atoken.toString());

  return atoken;
}

void _authRequest(String providerId, List<String> scopes) {
  var state;
  Map request;
  String authUrl;
  Config config;

  if (_configs[providerId] == null) throw "Could not find configuration for provider " + providerId;
  config = _configs[providerId];

  log.info("About to send an authorization request to [" + providerId + "]");
  log.fine(config.toString());

  request = { 'response_type': 'token' };

  if (config.redirectUri != null) {
    request['redirect_uri'] = config.redirectUri;
  }
  if (config.clientId != null) {
    request['client_id'] = config.clientId;
  }
  if (scopes != null && scopes.isNotEmpty) {
    request['scopes'] = scopes.join(" ");
  }

  authUrl = urlEncode(config.authorization, request);

  if (window.location.hash.isNotEmpty) {
    request['restoreHash'] = window.location.hash;
  }
  request['providerID'] = providerId;
  if (scopes != null && scopes.isNotEmpty) {
    request['scopes'] = scopes;
  }

//  log.info("Saving state [" + state + "]");
  log.info(json.stringify(request));

  _apiRedirect(authUrl);
}

String _findDefaultProvider(Map<String, Config> c) {
  String k;
  int i = 0;

  if (c == null) return null;

  for (k in c.keys) {
    i++;
    if (c[k].isDefault == true) {
      return k;
    }
  }
  if (i == 1) return k;
}

configure(Map<String, Config> c, {var opts}) {
  _configs = c;
  _setOptions(opts);
  try {
    var provider = _findDefaultProvider(c);
    log.info('doConfigure() about to check for token for this profile: ' + provider);
    return _checkForToken(provider);
  } catch (e) {
    log.log(Level.SEVERE, 'Error when retrieving token from hash.', e);
    window.location.hash = '';
  }
}

void wipe() {
  String key;
  for (key in _configs.keys) {
    _tokenStorage.wipeTokens(key);
  }
}

void _apiRedirect(url) {
  window.location.assign(url);
}

auth(Map settings) {
  String providerId = settings['oauth_provider'];
  bool allowia = settings['oauth_allowia'] || false;
  List<String> scopes = settings['oauth_scopes'];
  var token = _tokenStorage.getToken(providerId, scopes: scopes);
  Config config = _configs[providerId];

  var errorOverridden = settings['error'];

  if (token == null) {
    if (allowia) {
      log.info("Perform authrequest");
      _authRequest(providerId, scopes);
    }
  } else return token;
}

HttpRequest request(token, HttpRequest request) {
  request.setRequestHeader('Authorization', 'Bearer ' + token['access_token']);
  return request;
}

getToken(String provider) {
  return _tokenStorage.getToken(provider, scopes: []);
}