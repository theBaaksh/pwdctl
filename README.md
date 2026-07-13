# YunoLock

Experimental password manager.

## Authentication screen MVP

Qt/QML desktop prototype with a generated anime-style background, emotional mascot states, and playful unlock feedback.

## Build configuration

The project uses CMake presets for shared build modes.

Use one of these presets in Qt Creator:

- `core-tests` - build and run pwdctl core tests without GUI or Qt.
- `local-app-release` - build and run the YunoLock GUI with a local Qt path.

To enable the GUI preset, copy `CMakeUserPresets.json.example` to
`CMakeUserPresets.json` and set `CMAKE_PREFIX_PATH` to your Qt installation.

The temporary demo unlock password is `sakura`.

Core test commands:

```bash
cmake --preset core-tests
cmake --build --preset core-tests
ctest --preset core-tests
```

GUI build commands after creating local presets:

```bash
cmake --preset local-app-release
cmake --build --preset local-app-release
```
