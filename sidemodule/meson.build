project(
    'sidemodule',
    'cpp',
    default_options: ['cpp_std=c++11'],
)

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
            '-DEMSCRIPTEN=1',
            '-sSIDE_MODULE',
        ],
        link_args: [
            '-sEXPORT_ALL=1',
            '-sWASM=1',
            '-sSIDE_MODULE',
        ],
        # pic: true,
        install: true,
        name_suffix: 'wasm',
        install_dir: 'web',
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
        # => prefix/lib/sidemodule.lib
    )
endif
