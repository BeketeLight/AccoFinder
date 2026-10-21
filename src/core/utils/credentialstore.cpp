#include "credentialstore.h"

#include <QByteArray>
#include <QCoreApplication>
#include <QDir>
#include <QFile>
#include <QFileDevice>
#include <QLibrary>
#include <QLibraryInfo>
#include <QRandomGenerator>
#include <QSaveFile>
#include <QStandardPaths>
#include <QStringList>

#include <memory>

namespace {

// ── Payload layout ─────────────────────────────────────────────────────────
//   "AFCM" | version | nonce (12 bytes) | ciphertext | GCM tag (16 bytes)
// The header is fed to the cipher as additional data, so a payload cannot be
// re-labelled or truncated without the tag check failing.
constexpr char kMagic[] = "AFCM";
constexpr quint8 kVersion = 1;
constexpr int kHeaderSize = 5;   // magic + version
constexpr int kNonceSize = 12;
constexpr int kTagSize = 16;
constexpr int kKeySize = 32;     // AES-256

// EVP control codes from OpenSSL's public API. They are plain integers and
// identical in OpenSSL 1.1.x and 3.x, so they can be used without depending
// on the OpenSSL headers — the library is resolved at run time.
constexpr int kCtrlAeadSetIvLen = 0x9;
constexpr int kCtrlAeadGetTag = 0x10;
constexpr int kCtrlAeadSetTag = 0x11;

// OpenSSL's own types are opaque here: the library is never included, so the
// few entry points we need are declared with void pointers instead.
using CtxNewFn = void *(*)();
using CtxFreeFn = void (*)(void *);
using CipherFn = const void *(*)();
using InitFn = int (*)(void *, const void *, void *,
                       const unsigned char *, const unsigned char *);
using UpdateFn = int (*)(void *, unsigned char *, int *,
                         const unsigned char *, int);
using FinalFn = int (*)(void *, unsigned char *, int *);
using CtrlFn = int (*)(void *, int, int, void *);

struct Crypto
{
    // Kept alive for the whole process: the resolved symbols stay valid only
    // while the library is loaded.
    std::unique_ptr<QLibrary> library;
    CtxNewFn ctxNew = nullptr;
    CtxFreeFn ctxFree = nullptr;
    CipherFn aes256Gcm = nullptr;
    InitFn encryptInit = nullptr;
    InitFn decryptInit = nullptr;
    UpdateFn encryptUpdate = nullptr;
    UpdateFn decryptUpdate = nullptr;
    FinalFn encryptFinal = nullptr;
    FinalFn decryptFinal = nullptr;
    CtrlFn ctrl = nullptr;
    bool ready = false;
};

template <typename Fn>
bool bind(Fn &target, QLibrary &library, const char *symbol)
{
    target = reinterpret_cast<Fn>(library.resolve(symbol));
    return target != nullptr;
}

bool bindAll(Crypto &crypto, QLibrary &library)
{
    const bool bound =
        bind(crypto.ctxNew, library, "EVP_CIPHER_CTX_new")
        && bind(crypto.ctxFree, library, "EVP_CIPHER_CTX_free")
        && bind(crypto.aes256Gcm, library, "EVP_aes_256_gcm")
        && bind(crypto.encryptInit, library, "EVP_EncryptInit_ex")
        && bind(crypto.decryptInit, library, "EVP_DecryptInit_ex")
        && bind(crypto.encryptUpdate, library, "EVP_EncryptUpdate")
        && bind(crypto.decryptUpdate, library, "EVP_DecryptUpdate")
        && bind(crypto.encryptFinal, library, "EVP_EncryptFinal_ex")
        && bind(crypto.decryptFinal, library, "EVP_DecryptFinal_ex")
        && bind(crypto.ctrl, library, "EVP_CIPHER_CTX_ctrl");

    crypto.ready = bound;
    return bound;
}

// Every directory that may hold a shared library on this platform. On Android
// the app's own native library directory is where the bundled OpenSSL lands,
// so it is searched explicitly rather than relying on the system paths.
QStringList librarySearchPaths()
{
    QStringList paths = QCoreApplication::libraryPaths();

    const QString qtLibPath = QLibraryInfo::path(QLibraryInfo::LibrariesPath);
    if (!qtLibPath.isEmpty() && !paths.contains(qtLibPath))
        paths.append(qtLibPath);

    const QString appDir = QCoreApplication::applicationDirPath();
    if (!appDir.isEmpty() && !paths.contains(appDir))
        paths.prepend(appDir);

    return paths;
}

Crypto &crypto()
{
    static Crypto instance = []() {
        Crypto resolved;

        // The usual system sonames first, then the names the bundled Android
        // OpenSSL uses (libcrypto_3.so / libcrypto_1_1.so).
        QStringList candidates = {
            QStringLiteral("libcrypto.so.3"),
            QStringLiteral("libcrypto.so.1.1"),
            QStringLiteral("libcrypto.so"),
            QStringLiteral("libcrypto_3.so"),
            QStringLiteral("libcrypto_1_1.so"),
        };

        // Then anything that looks like libcrypto in the directories the
        // platform keeps its libraries in, so a differently named build is
        // still found.
        for (const QString &dir : librarySearchPaths()) {
            const QStringList entries = QDir(dir).entryList(
                {QStringLiteral("libcrypto*.so*")}, QDir::Files);
            for (const QString &entry : entries)
                candidates << QDir(dir).absoluteFilePath(entry);
        }

        for (const QString &candidate : candidates) {
            auto library = std::make_unique<QLibrary>(candidate);
            if (!library->load())
                continue;

            Crypto probe;
            if (!bindAll(probe, *library))
                continue;

            probe.library = std::move(library);
            resolved = std::move(probe);
            qDebug() << "[CredentialStore] using crypto backend" << candidate;
            break;
        }

        if (!resolved.ready)
            qWarning() << "[CredentialStore] no usable crypto backend found";

        return resolved;
    }();

    return instance;
}

QByteArray randomBytes(int size)
{
    QByteArray bytes(size, '\0');
    QRandomGenerator *generator = QRandomGenerator::system();
    for (int i = 0; i < size; ++i)
        bytes[i] = static_cast<char>(generator->generate() & 0xFF);
    return bytes;
}

QString keyFilePath()
{
    const QString directory =
        QStandardPaths::writableLocation(QStandardPaths::AppDataLocation);
    if (directory.isEmpty())
        return QString();
    return QDir(directory).filePath(QStringLiteral("remembered-credentials.key"));
}

// Reads the per-install key, creating it on first use. The key deliberately
// lives outside the settings file: the two are then stored in separate
// private directories, so a copy of the settings alone is not enough to
// recover the secret.
bool loadOrCreateKey(QByteArray &key)
{
    const QString path = keyFilePath();
    if (path.isEmpty())
        return false;

    QFile existing(path);
    if (existing.exists() && existing.open(QIODevice::ReadOnly)) {
        const QByteArray stored = existing.readAll();
        if (stored.size() == kKeySize) {
            key = stored;
            return true;
        }
        // A truncated or foreign key file is replaced rather than trusted.
    }

    key = randomBytes(kKeySize);

    QSaveFile out(path);
    if (!out.open(QIODevice::WriteOnly))
        return false;
    if (out.write(key) != kKeySize) {
        out.cancelWriting();
        return false;
    }
    if (!out.commit())
        return false;

    QFile::setPermissions(path, QFileDevice::ReadOwner | QFileDevice::WriteOwner);
    return true;
}

} // namespace

bool CredentialStore::isAvailable()
{
    return crypto().ready;
}

QString CredentialStore::encrypt(const QString &plainText)
{
    Crypto &c = crypto();
    if (!c.ready)
        return QString();

    QByteArray key;
    if (!loadOrCreateKey(key))
        return QString();

    const QByteArray plain = plainText.toUtf8();
    const QByteArray nonce = randomBytes(kNonceSize);

    // The header is authenticated as additional data, so the version cannot be
    // swapped on a stored payload.
    QByteArray header(kMagic, 4);
    header.append(static_cast<char>(kVersion));

    void *context = c.ctxNew();
    if (!context)
        return QString();

    QByteArray cipherText;
    QByteArray tag(kTagSize, '\0');
    bool ok = false;

    int length = 0;
    if (c.encryptInit(context, c.aes256Gcm(), nullptr,
                      reinterpret_cast<const unsigned char *>(key.constData()),
                      reinterpret_cast<const unsigned char *>(nonce.constData())) == 1
        && c.ctrl(context, kCtrlAeadSetIvLen, kNonceSize, nullptr) == 1
        && c.encryptUpdate(context, nullptr, &length,
                          reinterpret_cast<const unsigned char *>(header.constData()),
                          header.size()) == 1) {

        // The buffer has to hold the whole plaintext plus one extra block.
        QByteArray buffer(plain.size() + 32, '\0');
        int written = 0;
        if (c.encryptUpdate(context,
                            reinterpret_cast<unsigned char *>(buffer.data()), &written,
                            reinterpret_cast<const unsigned char *>(plain.constData()),
                            plain.size()) == 1) {
            int finalLength = 0;
            if (c.encryptFinal(context,
                               reinterpret_cast<unsigned char *>(buffer.data()) + written,
                               &finalLength) == 1) {
                cipherText = buffer.left(written + finalLength);
                if (c.ctrl(context, kCtrlAeadGetTag, kTagSize, tag.data()) == 1)
                    ok = true;
            }
        }
    }

    c.ctxFree(context);

    if (!ok) {
        qWarning() << "[CredentialStore] encryption failed";
        return QString();
    }

    QByteArray payload;
    payload.append(header);
    payload.append(nonce);
    payload.append(cipherText);
    payload.append(tag);

    return QString::fromLatin1(payload.toBase64());
}

QString CredentialStore::decrypt(const QString &payload)
{
    Crypto &c = crypto();
    if (!c.ready)
        return QString();

    const QByteArray raw = QByteArray::fromBase64(payload.toLatin1());
    if (raw.size() < kHeaderSize + kNonceSize + kTagSize)
        return QString();
    if (!raw.startsWith(QByteArray(kMagic, 4)))
        return QString();
    if (static_cast<quint8>(raw.at(4)) != kVersion)
        return QString();

    QByteArray key;
    if (!loadOrCreateKey(key))
        return QString();

    const QByteArray header = raw.left(kHeaderSize);
    const QByteArray nonce = raw.mid(kHeaderSize, kNonceSize);
    const QByteArray cipherText =
        raw.mid(kHeaderSize + kNonceSize,
                raw.size() - kHeaderSize - kNonceSize - kTagSize);
    const QByteArray tag = raw.right(kTagSize);

    void *context = c.ctxNew();
    if (!context)
        return QString();

    QByteArray plain;
    bool ok = false;

    int length = 0;
    if (c.decryptInit(context, c.aes256Gcm(), nullptr,
                      reinterpret_cast<const unsigned char *>(key.constData()),
                      reinterpret_cast<const unsigned char *>(nonce.constData())) == 1
        && c.ctrl(context, kCtrlAeadSetIvLen, kNonceSize, nullptr) == 1
        && c.decryptUpdate(context, nullptr, &length,
                           reinterpret_cast<const unsigned char *>(header.constData()),
                           header.size()) == 1) {

        QByteArray buffer(cipherText.size() + 32, '\0');
        int written = 0;
        if (c.decryptUpdate(context,
                            reinterpret_cast<unsigned char *>(buffer.data()), &written,
                            reinterpret_cast<const unsigned char *>(cipherText.constData()),
                            cipherText.size()) == 1) {
            // The expected tag has to be in place before the final call, which
            // is where GCM verifies it.
            if (c.ctrl(context, kCtrlAeadSetTag, kTagSize, const_cast<char *>(tag.constData())) == 1) {
                int finalLength = 0;
                if (c.decryptFinal(context,
                                   reinterpret_cast<unsigned char *>(buffer.data()) + written,
                                   &finalLength) == 1) {
                    plain = buffer.left(written + finalLength);
                    ok = true;
                }
            }
        }
    }

    c.ctxFree(context);

    if (!ok) {
        qWarning() << "[CredentialStore] decryption failed";
        return QString();
    }

    return QString::fromUtf8(plain);
}
