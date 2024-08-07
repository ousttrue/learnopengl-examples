project('sidemodule', 'cpp')

executable(
    'sidemodule',
    [
        'ozz_wrap.cpp',
        'src/mesh.cc',
        'src/ozz_base.cc',
        'src/ozz_animation.cc',
    ],
    include_directories: include_directories('include'),
    cpp_args: [
        '-DDLL_EXPORTS',
        # '--no-entry',
        # '-sWASM=1',
        '-sSIDE_MODULE=1',
    ],
    install: true,
)
