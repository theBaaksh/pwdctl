# YunoLock

Experimental password manager.

## Authentication screen MVP

Qt/QML desktop prototype with a generated anime-style background, emotional mascot states, and playful unlock feedback.

Build with Qt 6.5.3:

```bash
cmake -S . -B build-qt653-cxx17 -DCMAKE_PREFIX_PATH=/opt/Qt/6.5.3/gcc_64
cmake --build build-qt653-cxx17
./build-qt653-cxx17/yunolock
```

The temporary demo unlock password is `sakura`.
