# LearnOpenGl Examples(zig)

**Unofficial** cross platform examples for [learnopengl.com](https://learnopengl.com/)

- forked from https://github.com/zeromake/learnopengl-examples
- written in Zig.
- shader dialect GLSL v450
- runs on OSX, Linux, Windows and web (emscripten) from the same source
- uses [Sokol-zig libraries](https://github.com/floooh/sokol-zig) for cross platform support

## Building

`Zig-0.13.0`

### How to Build

```bash
> zig build
```

#### WASM Build

```bash
# ubuntu ok
# windows failed
> zig build -Dtarget=wasm32-emscripten
```
