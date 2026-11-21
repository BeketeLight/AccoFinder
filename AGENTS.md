# AccoFinder (Qt/QML client)

Qt 6.11.1 (Material style) app in C++/QML. API backend is a separate repo:
`/media/csociety/Backup1/CISociety/Node/Projects/accofinder` (Node/Express, branch `main`).

## Build

- Desktop: `cmake -S . -B /tmp/opencode/accofinder-build -DCMAKE_PREFIX_PATH=/opt/Qt/6.11.1/gcc_64 && cmake --build /tmp/opencode/accofinder-build`
- Android: `cmake --build build-android-arm64` (pre-configured; NDK 27.2, abi arm64-v8a)
- Qt installed at `/opt/Qt/6.11.1/{gcc_64,android_arm64_v8a}`.

## Key conventions

- Any new QML file must be added to the `QML_FILES` list in `CMakeLists.txt` or it won't be packaged (qrc URL unavailable at runtime).
- QML-facing property/role names keep `price`. At the JSON boundary use `rentalFee`/`bookingFee` (see `PropertyDto`/`RoomDto`).
- `AppSettings` is a non-reactive QObject singleton exposed as a context property; mirror values in QML and refresh from its change signals (`themeChanged`, `languageChanged`, `notificationPreferencesChanged`, etc.).
- Navigation goes through `ui/utils/NavigationUtils.js` (`NavUtils.push/pop`); do not reference an undefined `stackView`.
- Backend wraps responses as `{ success, message, data }`; unwrap `data` in the gateway layer.
- Branch is `dev`; do not commit unless explicitly asked. API repo is separate (`main`).

## Testing

- No automated client tests. Verify with a desktop build + offscreen run (`QT_QPA_PLATFORM=offscreen`) and check logs for QML errors.
- API tests: `cd /media/.../accofinder && npx jest <file> --runInBand`. Tests use named exports from models (stale default-import tests fail to load).