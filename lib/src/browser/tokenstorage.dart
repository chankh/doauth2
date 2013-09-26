part of doauth2;

class TokenStorage {

  /// saveState stores an object with an Identifier.
  /// In the state object, we put the request object, plus these parameters:
  /// - restoreHash
  /// - providerID
  /// - scopes
  void saveState(state, obj) {
    window.localStorage["state-" + state] = json.stringify(obj);
  }

  /// getState()  returns the state object, but also removes it.
  getState(state) {
    var stateKey = "state-"+state;
    var obj = json.parse(window.localStorage[stateKey]);
    window.localStorage.remove(stateKey);
    return obj;
  }

  /// Checks if a token, has includes a specific scope. If token has no scope
  /// at all, false is returned.
  bool hasScope(Map token, String scope) {
    var i;
    if (!token.containsKey('scopes')) return false;
    for (int i = 0; i < token['scopes'].length; i++) {
      if (token['scopes'][i] == scope) return true;
    }
    return false;
  }

  /// Takes an array of tokens, and removes the ones that are expired, and the
  /// ones that do not meet a scopes requirement.
  List<Map> filterTokens(List<Map> tokens, {List scopes}) {
    List result = [];
    double now = epoch();
    bool useThis;

    if (scopes == null) scopes = [];

    for (int i = 0; i < tokens.length; i++) {
      useThis = true;

      // Filter out expired tokens. Tokens that is expired in 1 second from now.
      if (tokens[i].containsKey('expires') && tokens[i]['expires'] < (now+1)) useThis = false;

      // folter out this token if not all scope requirements are met.
      for (int j = 0; j < scopes.length; j++) {
        if (!hasScope(tokens[i], scopes[j])) useThis = false;
      }

      if (useThis) result.add(tokens[i]);
    }

    return result;
  }

  /// saveTokens() stores a list of tokens for a provider.
  ///
  /// Usually the tokens stored are a plain Access token plus:
  /// expires : time that the token expires
  /// providerID: the provider of the access token?
  /// scopes: an array with the scopes (not string)
  void saveTokens(String provider, tokens) {
    window.localStorage["tokens-" + provider] = json.stringify(tokens);
  }

  List<Map<String, dynamic>> getTokens(String provider) {
    var tokens = window.localStorage["tokens-" + provider];
    if (tokens == null) {
      tokens = [];
    }
    else {
      tokens = json.parse(tokens);
    }

    return tokens;
  }

  void wipeTokens(String provider) {
    window.localStorage.remove("tokens-" + provider);
  }

  /// Save a single token for a provider.
  /// This also cleans up expired tokens for the same provider.
  void saveToken(String provider, Map token) {
    List tokens = getTokens(provider);
    tokens = filterTokens(tokens);
    tokens.add(token);
    saveTokens(provider, tokens);
  }

  /// Get a token if exists for a provider with a set of scopes.
  /// The scopes parameter is OPTIONAL.
  Map<String, dynamic> getToken(String provider, { List<String> scopes }) {
    List tokens = getTokens(provider);
    tokens = filterTokens(tokens, scopes: scopes);
    if (tokens.length < 1) return null;
    return tokens[0];
  }

}