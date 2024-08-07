project('sidemodule', 'cpp')

srcs = [
    'ozz_wrap.cpp',
    'src/mesh.cc',
    'src/ozz_base.cc',
    'src/ozz_animation.cc',
]
inc = include_directories('include')

cxx = meson.get_compiler('cpp')
if cxx.get_id() == 'emscripten'
    # wasm
    executable(
        'sidemodule',
        srcs,
        include_directories: inc,
        cpp_args: [
            '-sSIDE_MODULE=1',
        ],
        install: true,
        # => prefix/lib/sidemodule.js
        # => prefix/lib/sidemodule.wasm
    )
else
    # native
    shared_library(
        'sidemodule',
        srcs,
        include_directories: inc,
        cpp_args: [
            '-DDLL_EXPORTS',
        ],
        install: true,
        # => prefix/bin/sidemodule.dll
    )
endif
