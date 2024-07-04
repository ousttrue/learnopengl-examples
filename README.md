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

require

https://github.com/floooh/sokol-tools-bin

#### Web Builds

TODO:

#### Todo

- [x] [1-3-1-rendering](src/1-3-hello-window/1-rendering.zig)
- [x] [1-4-1-triangle](src/1-4-hello-triangle/1-triangle.zig)
- [x] [1-4-2-quad](src/1-4-hello-triangle/2-quad.zig)
- [x] [1-4-3-quad-wireframe](src/1-4-hello-triangle/3-quad-wireframe.zig)
- [x] [1-5-1-in-out](src/1-5-shaders/1-in-out.zig)
- [x] [1-5-2-uniforms](src/1-5-shaders/2-uniforms.zig)
- [x] [1-5-3-attributes](src/1-5-shaders/3-attributes.zig)
- [ ] [1-6-1-texture](src/1-6-textures/1-texture.zig)
- [ ] [1-6-2-texture-blend](src/1-6-textures/2-texture-blend.zig)
- [ ] [1-6-3-multiple-textures](src/1-6-textures/3-multiple-textures.zig)
- [ ] [1-7-1-scale-rotate](src/1-7-transformations/1-scale-rotate.zig)
- [ ] [1-7-2-rotate-translate](src/1-7-transformations/2-rotate-translate.zig)
- [ ] [1-8-1-plane](src/1-8-coordinate-systems/1-plane.zig)
- [ ] [1-8-2-cube](src/1-8-coordinate-systems/2-cube.zig)
- [ ] [1-8-3-more-cubes](src/1-8-coordinate-systems/3-more-cubes.zig)
- [ ] [1-9-1-lookat](src/1-9-camera/1-lookat.zig)
- [ ] [1-9-2-walk](src/1-9-camera/2-walk.zig)
- [ ] [1-9-3-look](src/1-9-camera/3-look.zig)
- [ ] [2-1-1-scene](src/2-1-colors/1-scene.zig)
- [ ] [2-2-1-ambient](src/2-2-basic-lighting/1-ambient.zig)
- [ ] [2-2-2-diffuse](src/2-2-basic-lighting/2-diffuse.zig)
- [ ] [2-2-3-specular](src/2-2-basic-lighting/3-specular.zig)
- [ ] [2-3-1-material](src/2-3-materials/1-material.zig)
- [ ] [2-3-2-light](src/2-3-materials/2-light.zig)
- [ ] [2-3-3-light-colors](src/2-3-materials/3-light-colors.zig)
- [ ] [2-4-1-diffuse-map](src/2-4-lighting-maps/1-diffuse-map.zig)
- [ ] [2-4-2-specular-map](src/2-4-lighting-maps/2-specular-map.zig)
- [ ] [2-5-1-directional-light](src/2-5-light-casters/1-directional-light.zig)
- [ ] [2-5-2-point-light](src/2-5-light-casters/2-point-light.zig)
- [ ] [2-5-3-spot-light](src/2-5-light-casters/3-spot-light.zig)
- [ ] [2-5-4-soft-spot-light](src/2-5-light-casters/4-soft-spot-light.zig)
- [ ] [2-6-1-combined-lights](src/2-6-multiple-lights/1-combined-lights.zig)
- [ ] [3-1-1-backpack-diffuse](src/3-1-model/1-backpack-diffuse.zig)
- [ ] [3-1-2-backpack-lights](src/3-1-model/2-backpack-lights.zig)
- [ ] [4-1-1-depth-always](src/4-1-depth-testing/1-depth-always.zig)
- [ ] [4-1-2-depth-less](src/4-1-depth-testing/2-depth-less.zig)
- [ ] [4-1-3-depth-buffer](src/4-1-depth-testing/3-depth-buffer.zig)
- [ ] [4-1-4-linear-depth-buffer](src/4-1-depth-testing/4-linear-depth-buffer.zig)
- [ ] [4-2-1-object-outlining](src/4-2-stencil-testing/1-object-outlining.zig)
- [ ] [4-3-1-grass-opaque](src/4-3-blending/1-grass-opaque.zig)
- [ ] [4-3-2-grass-transparent](src/4-3-blending/2-grass-transparent.zig)
- [ ] [4-3-3-blending](src/4-3-blending/3-blending.zig)
- [ ] [4-3-4-blending-sorted](src/4-3-blending/4-blending-sorted.zig)
- [ ] [4-4-1-cull-front](src/4-4-face-culling/1-cull-front.zig)
- [ ] [4-5-1-render-to-texture](src/4-5-framebuffers/1-render-to-texture.zig)
- [ ] [4-5-2-inversion](src/4-5-framebuffers/2-inversion.zig)
- [ ] [4-5-3-grayscale](src/4-5-framebuffers/3-grayscale.zig)
- [ ] [4-5-4-sharpen](src/4-5-framebuffers/4-sharpen.zig)
- [ ] [4-5-5-blur](src/4-5-framebuffers/5-blur.zig)
- [ ] [4-5-6-edge-detection](src/4-5-framebuffers/6-edge-detection.zig)
- [ ] [4-6-1-skybox](src/4-6-cubemaps/1-skybox.zig)
- [ ] [4-6-2-reflection-cube](src/4-6-cubemaps/2-reflection-cube.zig)
- [ ] [4-6-3-reflection-backpack](src/4-6-cubemaps/3-reflection-backpack.zig)
- [ ] [4-6-4-refraction-cube](src/4-6-cubemaps/4-refraction-cube.zig)
- [ ] [4-6-5-refraction-backpack](src/4-6-cubemaps/5-refraction-backpack.zig)
- [ ] [4-8-1-point-size](src/4-8-advanced-glsl/1-point-size.zig)
- [ ] [4-8-2-frag-coord](src/4-8-advanced-glsl/2-frag-coord.zig)
- [ ] [4-8-3-front-facing](src/4-8-advanced-glsl/3-front-facing.zig)
- [ ] [4-8-4-uniform-buffers](src/4-8-advanced-glsl/4-uniform-buffers.zig)
- [ ] [4-9-1-lines](src/4-9-geometry-shader/1-lines.zig)
- [ ] [4-9-2-houses](src/4-9-geometry-shader/2-houses.zig)
- [ ] [4-9-3-exploding-object](src/4-9-geometry-shader/3-exploding-object.zig)
- [ ] [4-9-4-visualizing-normals](src/4-9-geometry-shader/4-visualizing-normals.zig)
- [ ] [4-10-1-instancing](src/4-10-instancing/1-instancing.zig)
- [ ] [4-10-2-instanced-arrays](src/4-10-instancing/2-instanced-arrays.zig)
- [ ] [4-10-3-asteroid-field](src/4-10-instancing/3-asteroid-field.zig)
- [ ] [4-10-4-asteroid-field-instanced](src/4-10-instancing/4-asteroid-field-instanced.zig)
- [ ] [4-11-1-msaa](src/4-11-anti-aliasing/1-msaa.zig)
- [ ] [4-11-2-offscreen-msaa](src/4-11-anti-aliasing/2-offscreen-msaa.zig)
- [ ] [4-11-3-grayscale-msaa](src/4-11-anti-aliasing/3-grayscale-msaa.zig)
- [ ] [4-11-4-cubemaprt](src/4-11-anti-aliasing/4-cubemaprt.zig)
- [ ] [5-1-1-blinn-phong](src/5-1-advanced-lighting/1-blinn-phong.zig)
- [ ] [5-2-1-gamma-correction](src/5-2-gamma-correction/1-gamma-correction.zig)
- [ ] [5-3-1-mapping-depth](src/5-3-shadow-mapping/1-mapping-depth.zig)
- [ ] [5-3-2-rendering-shadows](src/5-3-shadow-mapping/2-rendering-shadows.zig)
- [ ] [5-3-3-improved-shadows](src/5-3-shadow-mapping/3-improved-shadows.zig)
- [ ] [5-4-1-omnidirectional-depth](src/5-4-point-shadows/1-omnidirectional-depth.zig)
- [ ] [5-4-2-omnidirectional-shadows](src/5-4-point-shadows/2-omnidirectional-shadows.zig)
- [ ] [5-4-3-omnidirectional-PCF](src/5-4-point-shadows/3-omnidirectional-PCF.zig)
- [ ] [5-5-1-normal-mapping](src/5-5-normal-mapping/1-normal-mapping.zig)
- [ ] [5-5-2-tangent-space](src/5-5-normal-mapping/2-tangent-space.zig)
- [ ] [5-5-3-complex-object](src/5-5-normal-mapping/3-complex-object.zig)
