#ifndef CREDENTIALSTORE_H
#define CREDENTIALSTORE_H

#include <QString>

// Protects short secrets (currently the remembered sign-in password) before
// they are written to local settings.
//
// The secret is encrypted with AES-256-GCM under a random key that is created
// once per install. The key lives in its own file inside the app's private
// data directory rather than in the settings file, so dumping the settings on
// its own does not yield a usable credential. The GCM tag means a payload that
// was edited or truncated is rejected instead of silently decrypting to
// garbage.
//
// OpenSSL is resolved at run time rather than linked at build time. The app
// already ships OpenSSL for Android's TLS stack, so loading that same library
// keeps a second copy of it out of the process — a statically linked copy
// would clash with the one Qt's TLS plugin loads.
//
// If no crypto backend can be found the store refuses to protect anything:
// callers must never fall back to writing the secret in the clear.
class CredentialStore
{
public:
    // True when a secret can actually be protected on this platform.
    static bool isAvailable();

    // Returns the encrypted form of plainText, or an empty string when the
    // value could not be protected.
    static QString encrypt(const QString &plainText);

    // Returns the original text for a payload produced by encrypt(), or an
    // empty string when the payload is missing, malformed, was tampered with,
    // or the key is no longer available.
    static QString decrypt(const QString &payload);
};

#endif // CREDENTIALSTORE_H
