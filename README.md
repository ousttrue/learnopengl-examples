# LearnOpenGl Examples

**Unofficial** cross platform examples for [learnopengl.com](https://learnopengl.com/)

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

generate glsl.zig

```bash
> zig build shaders
```

#### Web Builds

TODO:

#### Todo

- [ ] [4-5-4-sharpen](src/4-5-framebuffers/4-sharpen.c)
- [ ] [4-5-5-blur](src/4-5-framebuffers/5-blur.c)
- [ ] [4-10-1-instancing](src/4-10-instancing/1-instancing.c)
