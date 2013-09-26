# doauth2

### Description

A Dart OAuth2 library for client-side (implicit) flow. A simple port from Andreas Åkre Solberg's JSO library (https://github.com/andreassolberg/jso)

### Features

* Implements OAuth2 Implicit Flow.
* Supports the `bearer` access token type.
* No server component needed.
* Can handle multiple providers at once.
* Uses *HTML 5.0 localStorage* to cache Access Tokens. You do not need to implement a storage.

### Usage/Installation

Add this dependency to your pubspec.yaml

```
  dependencies:
    doauth2: any
```

### Web applications

Import the library in your dart application

```
  import "package:doauth2/doauth2.dart" as doauth2;
```

Initialize the OAuth2 provider configuration with your parameters

```
String clientId = '<your-client-id>';
String redirectUri = '<your-redirect-uri>';
String authorization = '<your-authorization-endpoint-uri>';
doauth2.Config c = new doauth2.Config(clientId, redirectUri, authorization);
doauth2.configure({'provider1': c});
```

Once your have configured a provider, you can use the `auth` method to send the authentication request.

```
doauth2.auth({'oauth_provider': 'provider1', 'oauth_allowia' : true, 'oauth_scopes': ['read', 'write']});
```

When you have received an access token, it will be stored in the local storage automatically.


### Disclaimer

No guarantees about the security or functionality of this libary

### Licenses

Copyright (c) 2013 KH Chan

Licensed under the The GNU Lesser General Public License, Version 2.1 (LGPL-2.1)
and Version 3.0 (LGPL-3.0); meaning that you can select which of these two
versions depending on your needs. This library can be used free of charge for
both non-commercial and commercial projects. You may obtain a copy of the
License at

- http://opensource.org/licenses/lgpl-2.1
- http://opensource.org/licenses/LGPL-3.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS, WITHOUT
WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the
License for the specific language governing permissions and limitations under
the License.
