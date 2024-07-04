const sg = @import("sokol").gfx;
//
//    #version:1# (machine generated, don't edit!)
//
//    Generated by sokol-shdc (https://github.com/floooh/sokol-tools)
//
//    Cmdline:
//        sokol-shdc -i src/1-5-shaders/3-attributes.glsl -o src/1-5-shaders/3-attributes.glsl.zig -l glsl430:metal_macos:hlsl5:glsl300es:wgsl -f sokol_zig
//
//    Overview:
//    =========
//    Shader program: 'simple':
//        Get shader desc: shd.simpleShaderDesc(sg.queryBackend());
//        Vertex shader: vs
//            Attributes:
//                ATTR_vs_position => 0
//                ATTR_vs_aColor => 1
//        Fragment shader: fs
//
pub const ATTR_vs_position = 0;
pub const ATTR_vs_aColor = 1;
//
//    #version 430
//
//    layout(location = 0) in vec3 position;
//    layout(location = 0) out vec3 ourColor;
//    layout(location = 1) in vec3 aColor;
//
//    void main()
//    {
//        gl_Position = vec4(position.x, position.y, position.z, 1.0);
//        ourColor = aColor;
//    }
//
//
const vs_source_glsl430 = [237]u8 {
    0x23,0x76,0x65,0x72,0x73,0x69,0x6f,0x6e,0x20,0x34,0x33,0x30,0x0a,0x0a,0x6c,0x61,
    0x79,0x6f,0x75,0x74,0x28,0x6c,0x6f,0x63,0x61,0x74,0x69,0x6f,0x6e,0x20,0x3d,0x20,
    0x30,0x29,0x20,0x69,0x6e,0x20,0x76,0x65,0x63,0x33,0x20,0x70,0x6f,0x73,0x69,0x74,
    0x69,0x6f,0x6e,0x3b,0x0a,0x6c,0x61,0x79,0x6f,0x75,0x74,0x28,0x6c,0x6f,0x63,0x61,
    0x74,0x69,0x6f,0x6e,0x20,0x3d,0x20,0x30,0x29,0x20,0x6f,0x75,0x74,0x20,0x76,0x65,
    0x63,0x33,0x20,0x6f,0x75,0x72,0x43,0x6f,0x6c,0x6f,0x72,0x3b,0x0a,0x6c,0x61,0x79,
    0x6f,0x75,0x74,0x28,0x6c,0x6f,0x63,0x61,0x74,0x69,0x6f,0x6e,0x20,0x3d,0x20,0x31,
    0x29,0x20,0x69,0x6e,0x20,0x76,0x65,0x63,0x33,0x20,0x61,0x43,0x6f,0x6c,0x6f,0x72,
    0x3b,0x0a,0x0a,0x76,0x6f,0x69,0x64,0x20,0x6d,0x61,0x69,0x6e,0x28,0x29,0x0a,0x7b,
    0x0a,0x20,0x20,0x20,0x20,0x67,0x6c,0x5f,0x50,0x6f,0x73,0x69,0x74,0x69,0x6f,0x6e,
    0x20,0x3d,0x20,0x76,0x65,0x63,0x34,0x28,0x70,0x6f,0x73,0x69,0x74,0x69,0x6f,0x6e,
    0x2e,0x78,0x2c,0x20,0x70,0x6f,0x73,0x69,0x74,0x69,0x6f,0x6e,0x2e,0x79,0x2c,0x20,
    0x70,0x6f,0x73,0x69,0x74,0x69,0x6f,0x6e,0x2e,0x7a,0x2c,0x20,0x31,0x2e,0x30,0x29,
    0x3b,0x0a,0x20,0x20,0x20,0x20,0x6f,0x75,0x72,0x43,0x6f,0x6c,0x6f,0x72,0x20,0x3d,
    0x20,0x61,0x43,0x6f,0x6c,0x6f,0x72,0x3b,0x0a,0x7d,0x0a,0x0a,0x00,
};
//
//    #version 430
//
//    layout(location = 0) out vec4 FragColor;
//    layout(location = 0) in vec3 ourColor;
//
//    void main()
//    {
//        FragColor = vec4(ourColor, 1.0);
//    }
//
//
const fs_source_glsl430 = [150]u8 {
    0x23,0x76,0x65,0x72,0x73,0x69,0x6f,0x6e,0x20,0x34,0x33,0x30,0x0a,0x0a,0x6c,0x61,
    0x79,0x6f,0x75,0x74,0x28,0x6c,0x6f,0x63,0x61,0x74,0x69,0x6f,0x6e,0x20,0x3d,0x20,
    0x30,0x29,0x20,0x6f,0x75,0x74,0x20,0x76,0x65,0x63,0x34,0x20,0x46,0x72,0x61,0x67,
    0x43,0x6f,0x6c,0x6f,0x72,0x3b,0x0a,0x6c,0x61,0x79,0x6f,0x75,0x74,0x28,0x6c,0x6f,
    0x63,0x61,0x74,0x69,0x6f,0x6e,0x20,0x3d,0x20,0x30,0x29,0x20,0x69,0x6e,0x20,0x76,
    0x65,0x63,0x33,0x20,0x6f,0x75,0x72,0x43,0x6f,0x6c,0x6f,0x72,0x3b,0x0a,0x0a,0x76,
    0x6f,0x69,0x64,0x20,0x6d,0x61,0x69,0x6e,0x28,0x29,0x0a,0x7b,0x0a,0x20,0x20,0x20,
    0x20,0x46,0x72,0x61,0x67,0x43,0x6f,0x6c,0x6f,0x72,0x20,0x3d,0x20,0x76,0x65,0x63,
    0x34,0x28,0x6f,0x75,0x72,0x43,0x6f,0x6c,0x6f,0x72,0x2c,0x20,0x31,0x2e,0x30,0x29,
    0x3b,0x0a,0x7d,0x0a,0x0a,0x00,
};
//
//    #version 300 es
//
//    layout(location = 0) in vec3 position;
//    out vec3 ourColor;
//    layout(location = 1) in vec3 aColor;
//
//    void main()
//    {
//        gl_Position = vec4(position.x, position.y, position.z, 1.0);
//        ourColor = aColor;
//    }
//
//
const vs_source_glsl300es = [219]u8 {
    0x23,0x76,0x65,0x72,0x73,0x69,0x6f,0x6e,0x20,0x33,0x30,0x30,0x20,0x65,0x73,0x0a,
    0x0a,0x6c,0x61,0x79,0x6f,0x75,0x74,0x28,0x6c,0x6f,0x63,0x61,0x74,0x69,0x6f,0x6e,
    0x20,0x3d,0x20,0x30,0x29,0x20,0x69,0x6e,0x20,0x76,0x65,0x63,0x33,0x20,0x70,0x6f,
    0x73,0x69,0x74,0x69,0x6f,0x6e,0x3b,0x0a,0x6f,0x75,0x74,0x20,0x76,0x65,0x63,0x33,
    0x20,0x6f,0x75,0x72,0x43,0x6f,0x6c,0x6f,0x72,0x3b,0x0a,0x6c,0x61,0x79,0x6f,0x75,
    0x74,0x28,0x6c,0x6f,0x63,0x61,0x74,0x69,0x6f,0x6e,0x20,0x3d,0x20,0x31,0x29,0x20,
    0x69,0x6e,0x20,0x76,0x65,0x63,0x33,0x20,0x61,0x43,0x6f,0x6c,0x6f,0x72,0x3b,0x0a,
    0x0a,0x76,0x6f,0x69,0x64,0x20,0x6d,0x61,0x69,0x6e,0x28,0x29,0x0a,0x7b,0x0a,0x20,
    0x20,0x20,0x20,0x67,0x6c,0x5f,0x50,0x6f,0x73,0x69,0x74,0x69,0x6f,0x6e,0x20,0x3d,
    0x20,0x76,0x65,0x63,0x34,0x28,0x70,0x6f,0x73,0x69,0x74,0x69,0x6f,0x6e,0x2e,0x78,
    0x2c,0x20,0x70,0x6f,0x73,0x69,0x74,0x69,0x6f,0x6e,0x2e,0x79,0x2c,0x20,0x70,0x6f,
    0x73,0x69,0x74,0x69,0x6f,0x6e,0x2e,0x7a,0x2c,0x20,0x31,0x2e,0x30,0x29,0x3b,0x0a,
    0x20,0x20,0x20,0x20,0x6f,0x75,0x72,0x43,0x6f,0x6c,0x6f,0x72,0x20,0x3d,0x20,0x61,
    0x43,0x6f,0x6c,0x6f,0x72,0x3b,0x0a,0x7d,0x0a,0x0a,0x00,
};
//
//    #version 300 es
//    precision mediump float;
//    precision highp int;
//
//    layout(location = 0) out highp vec4 FragColor;
//    in highp vec3 ourColor;
//
//    void main()
//    {
//        FragColor = vec4(ourColor, 1.0);
//    }
//
//
const fs_source_glsl300es = [190]u8 {
    0x23,0x76,0x65,0x72,0x73,0x69,0x6f,0x6e,0x20,0x33,0x30,0x30,0x20,0x65,0x73,0x0a,
    0x70,0x72,0x65,0x63,0x69,0x73,0x69,0x6f,0x6e,0x20,0x6d,0x65,0x64,0x69,0x75,0x6d,
    0x70,0x20,0x66,0x6c,0x6f,0x61,0x74,0x3b,0x0a,0x70,0x72,0x65,0x63,0x69,0x73,0x69,
    0x6f,0x6e,0x20,0x68,0x69,0x67,0x68,0x70,0x20,0x69,0x6e,0x74,0x3b,0x0a,0x0a,0x6c,
    0x61,0x79,0x6f,0x75,0x74,0x28,0x6c,0x6f,0x63,0x61,0x74,0x69,0x6f,0x6e,0x20,0x3d,
    0x20,0x30,0x29,0x20,0x6f,0x75,0x74,0x20,0x68,0x69,0x67,0x68,0x70,0x20,0x76,0x65,
    0x63,0x34,0x20,0x46,0x72,0x61,0x67,0x43,0x6f,0x6c,0x6f,0x72,0x3b,0x0a,0x69,0x6e,
    0x20,0x68,0x69,0x67,0x68,0x70,0x20,0x76,0x65,0x63,0x33,0x20,0x6f,0x75,0x72,0x43,
    0x6f,0x6c,0x6f,0x72,0x3b,0x0a,0x0a,0x76,0x6f,0x69,0x64,0x20,0x6d,0x61,0x69,0x6e,
    0x28,0x29,0x0a,0x7b,0x0a,0x20,0x20,0x20,0x20,0x46,0x72,0x61,0x67,0x43,0x6f,0x6c,
    0x6f,0x72,0x20,0x3d,0x20,0x76,0x65,0x63,0x34,0x28,0x6f,0x75,0x72,0x43,0x6f,0x6c,
    0x6f,0x72,0x2c,0x20,0x31,0x2e,0x30,0x29,0x3b,0x0a,0x7d,0x0a,0x0a,0x00,
};
//
//    static float4 gl_Position;
//    static float3 position;
//    static float3 ourColor;
//    static float3 aColor;
//
//    struct SPIRV_Cross_Input
//    {
//        float3 position : TEXCOORD0;
//        float3 aColor : TEXCOORD1;
//    };
//
//    struct SPIRV_Cross_Output
//    {
//        float3 ourColor : TEXCOORD0;
//        float4 gl_Position : SV_Position;
//    };
//
//    void vert_main()
//    {
//        gl_Position = float4(position.x, position.y, position.z, 1.0f);
//        ourColor = aColor;
//    }
//
//    SPIRV_Cross_Output main(SPIRV_Cross_Input stage_input)
//    {
//        position = stage_input.position;
//        aColor = stage_input.aColor;
//        vert_main();
//        SPIRV_Cross_Output stage_output;
//        stage_output.gl_Position = gl_Position;
//        stage_output.ourColor = ourColor;
//        return stage_output;
//    }
//
const vs_source_hlsl5 = [700]u8 {
    0x73,0x74,0x61,0x74,0x69,0x63,0x20,0x66,0x6c,0x6f,0x61,0x74,0x34,0x20,0x67,0x6c,
    0x5f,0x50,0x6f,0x73,0x69,0x74,0x69,0x6f,0x6e,0x3b,0x0a,0x73,0x74,0x61,0x74,0x69,
    0x63,0x20,0x66,0x6c,0x6f,0x61,0x74,0x33,0x20,0x70,0x6f,0x73,0x69,0x74,0x69,0x6f,
    0x6e,0x3b,0x0a,0x73,0x74,0x61,0x74,0x69,0x63,0x20,0x66,0x6c,0x6f,0x61,0x74,0x33,
    0x20,0x6f,0x75,0x72,0x43,0x6f,0x6c,0x6f,0x72,0x3b,0x0a,0x73,0x74,0x61,0x74,0x69,
    0x63,0x20,0x66,0x6c,0x6f,0x61,0x74,0x33,0x20,0x61,0x43,0x6f,0x6c,0x6f,0x72,0x3b,
    0x0a,0x0a,0x73,0x74,0x72,0x75,0x63,0x74,0x20,0x53,0x50,0x49,0x52,0x56,0x5f,0x43,
    0x72,0x6f,0x73,0x73,0x5f,0x49,0x6e,0x70,0x75,0x74,0x0a,0x7b,0x0a,0x20,0x20,0x20,
    0x20,0x66,0x6c,0x6f,0x61,0x74,0x33,0x20,0x70,0x6f,0x73,0x69,0x74,0x69,0x6f,0x6e,
    0x20,0x3a,0x20,0x54,0x45,0x58,0x43,0x4f,0x4f,0x52,0x44,0x30,0x3b,0x0a,0x20,0x20,
    0x20,0x20,0x66,0x6c,0x6f,0x61,0x74,0x33,0x20,0x61,0x43,0x6f,0x6c,0x6f,0x72,0x20,
    0x3a,0x20,0x54,0x45,0x58,0x43,0x4f,0x4f,0x52,0x44,0x31,0x3b,0x0a,0x7d,0x3b,0x0a,
    0x0a,0x73,0x74,0x72,0x75,0x63,0x74,0x20,0x53,0x50,0x49,0x52,0x56,0x5f,0x43,0x72,
    0x6f,0x73,0x73,0x5f,0x4f,0x75,0x74,0x70,0x75,0x74,0x0a,0x7b,0x0a,0x20,0x20,0x20,
    0x20,0x66,0x6c,0x6f,0x61,0x74,0x33,0x20,0x6f,0x75,0x72,0x43,0x6f,0x6c,0x6f,0x72,
    0x20,0x3a,0x20,0x54,0x45,0x58,0x43,0x4f,0x4f,0x52,0x44,0x30,0x3b,0x0a,0x20,0x20,
    0x20,0x20,0x66,0x6c,0x6f,0x61,0x74,0x34,0x20,0x67,0x6c,0x5f,0x50,0x6f,0x73,0x69,
    0x74,0x69,0x6f,0x6e,0x20,0x3a,0x20,0x53,0x56,0x5f,0x50,0x6f,0x73,0x69,0x74,0x69,
    0x6f,0x6e,0x3b,0x0a,0x7d,0x3b,0x0a,0x0a,0x76,0x6f,0x69,0x64,0x20,0x76,0x65,0x72,
    0x74,0x5f,0x6d,0x61,0x69,0x6e,0x28,0x29,0x0a,0x7b,0x0a,0x20,0x20,0x20,0x20,0x67,
    0x6c,0x5f,0x50,0x6f,0x73,0x69,0x74,0x69,0x6f,0x6e,0x20,0x3d,0x20,0x66,0x6c,0x6f,
    0x61,0x74,0x34,0x28,0x70,0x6f,0x73,0x69,0x74,0x69,0x6f,0x6e,0x2e,0x78,0x2c,0x20,
    0x70,0x6f,0x73,0x69,0x74,0x69,0x6f,0x6e,0x2e,0x79,0x2c,0x20,0x70,0x6f,0x73,0x69,
    0x74,0x69,0x6f,0x6e,0x2e,0x7a,0x2c,0x20,0x31,0x2e,0x30,0x66,0x29,0x3b,0x0a,0x20,
    0x20,0x20,0x20,0x6f,0x75,0x72,0x43,0x6f,0x6c,0x6f,0x72,0x20,0x3d,0x20,0x61,0x43,
    0x6f,0x6c,0x6f,0x72,0x3b,0x0a,0x7d,0x0a,0x0a,0x53,0x50,0x49,0x52,0x56,0x5f,0x43,
    0x72,0x6f,0x73,0x73,0x5f,0x4f,0x75,0x74,0x70,0x75,0x74,0x20,0x6d,0x61,0x69,0x6e,
    0x28,0x53,0x50,0x49,0x52,0x56,0x5f,0x43,0x72,0x6f,0x73,0x73,0x5f,0x49,0x6e,0x70,
    0x75,0x74,0x20,0x73,0x74,0x61,0x67,0x65,0x5f,0x69,0x6e,0x70,0x75,0x74,0x29,0x0a,
    0x7b,0x0a,0x20,0x20,0x20,0x20,0x70,0x6f,0x73,0x69,0x74,0x69,0x6f,0x6e,0x20,0x3d,
    0x20,0x73,0x74,0x61,0x67,0x65,0x5f,0x69,0x6e,0x70,0x75,0x74,0x2e,0x70,0x6f,0x73,
    0x69,0x74,0x69,0x6f,0x6e,0x3b,0x0a,0x20,0x20,0x20,0x20,0x61,0x43,0x6f,0x6c,0x6f,
    0x72,0x20,0x3d,0x20,0x73,0x74,0x61,0x67,0x65,0x5f,0x69,0x6e,0x70,0x75,0x74,0x2e,
    0x61,0x43,0x6f,0x6c,0x6f,0x72,0x3b,0x0a,0x20,0x20,0x20,0x20,0x76,0x65,0x72,0x74,
    0x5f,0x6d,0x61,0x69,0x6e,0x28,0x29,0x3b,0x0a,0x20,0x20,0x20,0x20,0x53,0x50,0x49,
    0x52,0x56,0x5f,0x43,0x72,0x6f,0x73,0x73,0x5f,0x4f,0x75,0x74,0x70,0x75,0x74,0x20,
    0x73,0x74,0x61,0x67,0x65,0x5f,0x6f,0x75,0x74,0x70,0x75,0x74,0x3b,0x0a,0x20,0x20,
    0x20,0x20,0x73,0x74,0x61,0x67,0x65,0x5f,0x6f,0x75,0x74,0x70,0x75,0x74,0x2e,0x67,
    0x6c,0x5f,0x50,0x6f,0x73,0x69,0x74,0x69,0x6f,0x6e,0x20,0x3d,0x20,0x67,0x6c,0x5f,
    0x50,0x6f,0x73,0x69,0x74,0x69,0x6f,0x6e,0x3b,0x0a,0x20,0x20,0x20,0x20,0x73,0x74,
    0x61,0x67,0x65,0x5f,0x6f,0x75,0x74,0x70,0x75,0x74,0x2e,0x6f,0x75,0x72,0x43,0x6f,
    0x6c,0x6f,0x72,0x20,0x3d,0x20,0x6f,0x75,0x72,0x43,0x6f,0x6c,0x6f,0x72,0x3b,0x0a,
    0x20,0x20,0x20,0x20,0x72,0x65,0x74,0x75,0x72,0x6e,0x20,0x73,0x74,0x61,0x67,0x65,
    0x5f,0x6f,0x75,0x74,0x70,0x75,0x74,0x3b,0x0a,0x7d,0x0a,0x00,
};
//
//    static float4 FragColor;
//    static float3 ourColor;
//
//    struct SPIRV_Cross_Input
//    {
//        float3 ourColor : TEXCOORD0;
//    };
//
//    struct SPIRV_Cross_Output
//    {
//        float4 FragColor : SV_Target0;
//    };
//
//    void frag_main()
//    {
//        FragColor = float4(ourColor, 1.0f);
//    }
//
//    SPIRV_Cross_Output main(SPIRV_Cross_Input stage_input)
//    {
//        ourColor = stage_input.ourColor;
//        frag_main();
//        SPIRV_Cross_Output stage_output;
//        stage_output.FragColor = FragColor;
//        return stage_output;
//    }
//
const fs_source_hlsl5 = [459]u8 {
    0x73,0x74,0x61,0x74,0x69,0x63,0x20,0x66,0x6c,0x6f,0x61,0x74,0x34,0x20,0x46,0x72,
    0x61,0x67,0x43,0x6f,0x6c,0x6f,0x72,0x3b,0x0a,0x73,0x74,0x61,0x74,0x69,0x63,0x20,
    0x66,0x6c,0x6f,0x61,0x74,0x33,0x20,0x6f,0x75,0x72,0x43,0x6f,0x6c,0x6f,0x72,0x3b,
    0x0a,0x0a,0x73,0x74,0x72,0x75,0x63,0x74,0x20,0x53,0x50,0x49,0x52,0x56,0x5f,0x43,
    0x72,0x6f,0x73,0x73,0x5f,0x49,0x6e,0x70,0x75,0x74,0x0a,0x7b,0x0a,0x20,0x20,0x20,
    0x20,0x66,0x6c,0x6f,0x61,0x74,0x33,0x20,0x6f,0x75,0x72,0x43,0x6f,0x6c,0x6f,0x72,
    0x20,0x3a,0x20,0x54,0x45,0x58,0x43,0x4f,0x4f,0x52,0x44,0x30,0x3b,0x0a,0x7d,0x3b,
    0x0a,0x0a,0x73,0x74,0x72,0x75,0x63,0x74,0x20,0x53,0x50,0x49,0x52,0x56,0x5f,0x43,
    0x72,0x6f,0x73,0x73,0x5f,0x4f,0x75,0x74,0x70,0x75,0x74,0x0a,0x7b,0x0a,0x20,0x20,
    0x20,0x20,0x66,0x6c,0x6f,0x61,0x74,0x34,0x20,0x46,0x72,0x61,0x67,0x43,0x6f,0x6c,
    0x6f,0x72,0x20,0x3a,0x20,0x53,0x56,0x5f,0x54,0x61,0x72,0x67,0x65,0x74,0x30,0x3b,
    0x0a,0x7d,0x3b,0x0a,0x0a,0x76,0x6f,0x69,0x64,0x20,0x66,0x72,0x61,0x67,0x5f,0x6d,
    0x61,0x69,0x6e,0x28,0x29,0x0a,0x7b,0x0a,0x20,0x20,0x20,0x20,0x46,0x72,0x61,0x67,
    0x43,0x6f,0x6c,0x6f,0x72,0x20,0x3d,0x20,0x66,0x6c,0x6f,0x61,0x74,0x34,0x28,0x6f,
    0x75,0x72,0x43,0x6f,0x6c,0x6f,0x72,0x2c,0x20,0x31,0x2e,0x30,0x66,0x29,0x3b,0x0a,
    0x7d,0x0a,0x0a,0x53,0x50,0x49,0x52,0x56,0x5f,0x43,0x72,0x6f,0x73,0x73,0x5f,0x4f,
    0x75,0x74,0x70,0x75,0x74,0x20,0x6d,0x61,0x69,0x6e,0x28,0x53,0x50,0x49,0x52,0x56,
    0x5f,0x43,0x72,0x6f,0x73,0x73,0x5f,0x49,0x6e,0x70,0x75,0x74,0x20,0x73,0x74,0x61,
    0x67,0x65,0x5f,0x69,0x6e,0x70,0x75,0x74,0x29,0x0a,0x7b,0x0a,0x20,0x20,0x20,0x20,
    0x6f,0x75,0x72,0x43,0x6f,0x6c,0x6f,0x72,0x20,0x3d,0x20,0x73,0x74,0x61,0x67,0x65,
    0x5f,0x69,0x6e,0x70,0x75,0x74,0x2e,0x6f,0x75,0x72,0x43,0x6f,0x6c,0x6f,0x72,0x3b,
    0x0a,0x20,0x20,0x20,0x20,0x66,0x72,0x61,0x67,0x5f,0x6d,0x61,0x69,0x6e,0x28,0x29,
    0x3b,0x0a,0x20,0x20,0x20,0x20,0x53,0x50,0x49,0x52,0x56,0x5f,0x43,0x72,0x6f,0x73,
    0x73,0x5f,0x4f,0x75,0x74,0x70,0x75,0x74,0x20,0x73,0x74,0x61,0x67,0x65,0x5f,0x6f,
    0x75,0x74,0x70,0x75,0x74,0x3b,0x0a,0x20,0x20,0x20,0x20,0x73,0x74,0x61,0x67,0x65,
    0x5f,0x6f,0x75,0x74,0x70,0x75,0x74,0x2e,0x46,0x72,0x61,0x67,0x43,0x6f,0x6c,0x6f,
    0x72,0x20,0x3d,0x20,0x46,0x72,0x61,0x67,0x43,0x6f,0x6c,0x6f,0x72,0x3b,0x0a,0x20,
    0x20,0x20,0x20,0x72,0x65,0x74,0x75,0x72,0x6e,0x20,0x73,0x74,0x61,0x67,0x65,0x5f,
    0x6f,0x75,0x74,0x70,0x75,0x74,0x3b,0x0a,0x7d,0x0a,0x00,
};
//
//    #include <metal_stdlib>
//    #include <simd/simd.h>
//
//    using namespace metal;
//
//    struct main0_out
//    {
//        float3 ourColor [[user(locn0)]];
//        float4 gl_Position [[position]];
//    };
//
//    struct main0_in
//    {
//        float3 position [[attribute(0)]];
//        float3 aColor [[attribute(1)]];
//    };
//
//    vertex main0_out main0(main0_in in [[stage_in]])
//    {
//        main0_out out = {};
//        out.gl_Position = float4(in.position.x, in.position.y, in.position.z, 1.0);
//        out.ourColor = in.aColor;
//        return out;
//    }
//
//
const vs_source_metal_macos = [470]u8 {
    0x23,0x69,0x6e,0x63,0x6c,0x75,0x64,0x65,0x20,0x3c,0x6d,0x65,0x74,0x61,0x6c,0x5f,
    0x73,0x74,0x64,0x6c,0x69,0x62,0x3e,0x0a,0x23,0x69,0x6e,0x63,0x6c,0x75,0x64,0x65,
    0x20,0x3c,0x73,0x69,0x6d,0x64,0x2f,0x73,0x69,0x6d,0x64,0x2e,0x68,0x3e,0x0a,0x0a,
    0x75,0x73,0x69,0x6e,0x67,0x20,0x6e,0x61,0x6d,0x65,0x73,0x70,0x61,0x63,0x65,0x20,
    0x6d,0x65,0x74,0x61,0x6c,0x3b,0x0a,0x0a,0x73,0x74,0x72,0x75,0x63,0x74,0x20,0x6d,
    0x61,0x69,0x6e,0x30,0x5f,0x6f,0x75,0x74,0x0a,0x7b,0x0a,0x20,0x20,0x20,0x20,0x66,
    0x6c,0x6f,0x61,0x74,0x33,0x20,0x6f,0x75,0x72,0x43,0x6f,0x6c,0x6f,0x72,0x20,0x5b,
    0x5b,0x75,0x73,0x65,0x72,0x28,0x6c,0x6f,0x63,0x6e,0x30,0x29,0x5d,0x5d,0x3b,0x0a,
    0x20,0x20,0x20,0x20,0x66,0x6c,0x6f,0x61,0x74,0x34,0x20,0x67,0x6c,0x5f,0x50,0x6f,
    0x73,0x69,0x74,0x69,0x6f,0x6e,0x20,0x5b,0x5b,0x70,0x6f,0x73,0x69,0x74,0x69,0x6f,
    0x6e,0x5d,0x5d,0x3b,0x0a,0x7d,0x3b,0x0a,0x0a,0x73,0x74,0x72,0x75,0x63,0x74,0x20,
    0x6d,0x61,0x69,0x6e,0x30,0x5f,0x69,0x6e,0x0a,0x7b,0x0a,0x20,0x20,0x20,0x20,0x66,
    0x6c,0x6f,0x61,0x74,0x33,0x20,0x70,0x6f,0x73,0x69,0x74,0x69,0x6f,0x6e,0x20,0x5b,
    0x5b,0x61,0x74,0x74,0x72,0x69,0x62,0x75,0x74,0x65,0x28,0x30,0x29,0x5d,0x5d,0x3b,
    0x0a,0x20,0x20,0x20,0x20,0x66,0x6c,0x6f,0x61,0x74,0x33,0x20,0x61,0x43,0x6f,0x6c,
    0x6f,0x72,0x20,0x5b,0x5b,0x61,0x74,0x74,0x72,0x69,0x62,0x75,0x74,0x65,0x28,0x31,
    0x29,0x5d,0x5d,0x3b,0x0a,0x7d,0x3b,0x0a,0x0a,0x76,0x65,0x72,0x74,0x65,0x78,0x20,
    0x6d,0x61,0x69,0x6e,0x30,0x5f,0x6f,0x75,0x74,0x20,0x6d,0x61,0x69,0x6e,0x30,0x28,
    0x6d,0x61,0x69,0x6e,0x30,0x5f,0x69,0x6e,0x20,0x69,0x6e,0x20,0x5b,0x5b,0x73,0x74,
    0x61,0x67,0x65,0x5f,0x69,0x6e,0x5d,0x5d,0x29,0x0a,0x7b,0x0a,0x20,0x20,0x20,0x20,
    0x6d,0x61,0x69,0x6e,0x30,0x5f,0x6f,0x75,0x74,0x20,0x6f,0x75,0x74,0x20,0x3d,0x20,
    0x7b,0x7d,0x3b,0x0a,0x20,0x20,0x20,0x20,0x6f,0x75,0x74,0x2e,0x67,0x6c,0x5f,0x50,
    0x6f,0x73,0x69,0x74,0x69,0x6f,0x6e,0x20,0x3d,0x20,0x66,0x6c,0x6f,0x61,0x74,0x34,
    0x28,0x69,0x6e,0x2e,0x70,0x6f,0x73,0x69,0x74,0x69,0x6f,0x6e,0x2e,0x78,0x2c,0x20,
    0x69,0x6e,0x2e,0x70,0x6f,0x73,0x69,0x74,0x69,0x6f,0x6e,0x2e,0x79,0x2c,0x20,0x69,
    0x6e,0x2e,0x70,0x6f,0x73,0x69,0x74,0x69,0x6f,0x6e,0x2e,0x7a,0x2c,0x20,0x31,0x2e,
    0x30,0x29,0x3b,0x0a,0x20,0x20,0x20,0x20,0x6f,0x75,0x74,0x2e,0x6f,0x75,0x72,0x43,
    0x6f,0x6c,0x6f,0x72,0x20,0x3d,0x20,0x69,0x6e,0x2e,0x61,0x43,0x6f,0x6c,0x6f,0x72,
    0x3b,0x0a,0x20,0x20,0x20,0x20,0x72,0x65,0x74,0x75,0x72,0x6e,0x20,0x6f,0x75,0x74,
    0x3b,0x0a,0x7d,0x0a,0x0a,0x00,
};
//
//    #include <metal_stdlib>
//    #include <simd/simd.h>
//
//    using namespace metal;
//
//    struct main0_out
//    {
//        float4 FragColor [[color(0)]];
//    };
//
//    struct main0_in
//    {
//        float3 ourColor [[user(locn0)]];
//    };
//
//    fragment main0_out main0(main0_in in [[stage_in]])
//    {
//        main0_out out = {};
//        out.FragColor = float4(in.ourColor, 1.0);
//        return out;
//    }
//
//
const fs_source_metal_macos = [332]u8 {
    0x23,0x69,0x6e,0x63,0x6c,0x75,0x64,0x65,0x20,0x3c,0x6d,0x65,0x74,0x61,0x6c,0x5f,
    0x73,0x74,0x64,0x6c,0x69,0x62,0x3e,0x0a,0x23,0x69,0x6e,0x63,0x6c,0x75,0x64,0x65,
    0x20,0x3c,0x73,0x69,0x6d,0x64,0x2f,0x73,0x69,0x6d,0x64,0x2e,0x68,0x3e,0x0a,0x0a,
    0x75,0x73,0x69,0x6e,0x67,0x20,0x6e,0x61,0x6d,0x65,0x73,0x70,0x61,0x63,0x65,0x20,
    0x6d,0x65,0x74,0x61,0x6c,0x3b,0x0a,0x0a,0x73,0x74,0x72,0x75,0x63,0x74,0x20,0x6d,
    0x61,0x69,0x6e,0x30,0x5f,0x6f,0x75,0x74,0x0a,0x7b,0x0a,0x20,0x20,0x20,0x20,0x66,
    0x6c,0x6f,0x61,0x74,0x34,0x20,0x46,0x72,0x61,0x67,0x43,0x6f,0x6c,0x6f,0x72,0x20,
    0x5b,0x5b,0x63,0x6f,0x6c,0x6f,0x72,0x28,0x30,0x29,0x5d,0x5d,0x3b,0x0a,0x7d,0x3b,
    0x0a,0x0a,0x73,0x74,0x72,0x75,0x63,0x74,0x20,0x6d,0x61,0x69,0x6e,0x30,0x5f,0x69,
    0x6e,0x0a,0x7b,0x0a,0x20,0x20,0x20,0x20,0x66,0x6c,0x6f,0x61,0x74,0x33,0x20,0x6f,
    0x75,0x72,0x43,0x6f,0x6c,0x6f,0x72,0x20,0x5b,0x5b,0x75,0x73,0x65,0x72,0x28,0x6c,
    0x6f,0x63,0x6e,0x30,0x29,0x5d,0x5d,0x3b,0x0a,0x7d,0x3b,0x0a,0x0a,0x66,0x72,0x61,
    0x67,0x6d,0x65,0x6e,0x74,0x20,0x6d,0x61,0x69,0x6e,0x30,0x5f,0x6f,0x75,0x74,0x20,
    0x6d,0x61,0x69,0x6e,0x30,0x28,0x6d,0x61,0x69,0x6e,0x30,0x5f,0x69,0x6e,0x20,0x69,
    0x6e,0x20,0x5b,0x5b,0x73,0x74,0x61,0x67,0x65,0x5f,0x69,0x6e,0x5d,0x5d,0x29,0x0a,
    0x7b,0x0a,0x20,0x20,0x20,0x20,0x6d,0x61,0x69,0x6e,0x30,0x5f,0x6f,0x75,0x74,0x20,
    0x6f,0x75,0x74,0x20,0x3d,0x20,0x7b,0x7d,0x3b,0x0a,0x20,0x20,0x20,0x20,0x6f,0x75,
    0x74,0x2e,0x46,0x72,0x61,0x67,0x43,0x6f,0x6c,0x6f,0x72,0x20,0x3d,0x20,0x66,0x6c,
    0x6f,0x61,0x74,0x34,0x28,0x69,0x6e,0x2e,0x6f,0x75,0x72,0x43,0x6f,0x6c,0x6f,0x72,
    0x2c,0x20,0x31,0x2e,0x30,0x29,0x3b,0x0a,0x20,0x20,0x20,0x20,0x72,0x65,0x74,0x75,
    0x72,0x6e,0x20,0x6f,0x75,0x74,0x3b,0x0a,0x7d,0x0a,0x0a,0x00,
};
//
//    diagnostic(off, derivative_uniformity);
//
//    var<private> position_1 : vec3f;
//
//    var<private> ourColor : vec3f;
//
//    var<private> aColor : vec3f;
//
//    var<private> gl_Position : vec4f;
//
//    fn main_1() {
//      let x_22 : f32 = position_1.x;
//      let x_24 : f32 = position_1.y;
//      let x_27 : f32 = position_1.z;
//      gl_Position = vec4f(x_22, x_24, x_27, 1.0f);
//      let x_35 : vec3f = aColor;
//      ourColor = x_35;
//      return;
//    }
//
//    struct main_out {
//      @builtin(position)
//      gl_Position : vec4f,
//      @location(0)
//      ourColor_1 : vec3f,
//    }
//
//    @vertex
//    fn main(@location(0) position_1_param : vec3f, @location(1) aColor_param : vec3f) -> main_out {
//      position_1 = position_1_param;
//      aColor = aColor_param;
//      main_1();
//      return main_out(gl_Position, ourColor);
//    }
//
//
const vs_source_wgsl = [715]u8 {
    0x64,0x69,0x61,0x67,0x6e,0x6f,0x73,0x74,0x69,0x63,0x28,0x6f,0x66,0x66,0x2c,0x20,
    0x64,0x65,0x72,0x69,0x76,0x61,0x74,0x69,0x76,0x65,0x5f,0x75,0x6e,0x69,0x66,0x6f,
    0x72,0x6d,0x69,0x74,0x79,0x29,0x3b,0x0a,0x0a,0x76,0x61,0x72,0x3c,0x70,0x72,0x69,
    0x76,0x61,0x74,0x65,0x3e,0x20,0x70,0x6f,0x73,0x69,0x74,0x69,0x6f,0x6e,0x5f,0x31,
    0x20,0x3a,0x20,0x76,0x65,0x63,0x33,0x66,0x3b,0x0a,0x0a,0x76,0x61,0x72,0x3c,0x70,
    0x72,0x69,0x76,0x61,0x74,0x65,0x3e,0x20,0x6f,0x75,0x72,0x43,0x6f,0x6c,0x6f,0x72,
    0x20,0x3a,0x20,0x76,0x65,0x63,0x33,0x66,0x3b,0x0a,0x0a,0x76,0x61,0x72,0x3c,0x70,
    0x72,0x69,0x76,0x61,0x74,0x65,0x3e,0x20,0x61,0x43,0x6f,0x6c,0x6f,0x72,0x20,0x3a,
    0x20,0x76,0x65,0x63,0x33,0x66,0x3b,0x0a,0x0a,0x76,0x61,0x72,0x3c,0x70,0x72,0x69,
    0x76,0x61,0x74,0x65,0x3e,0x20,0x67,0x6c,0x5f,0x50,0x6f,0x73,0x69,0x74,0x69,0x6f,
    0x6e,0x20,0x3a,0x20,0x76,0x65,0x63,0x34,0x66,0x3b,0x0a,0x0a,0x66,0x6e,0x20,0x6d,
    0x61,0x69,0x6e,0x5f,0x31,0x28,0x29,0x20,0x7b,0x0a,0x20,0x20,0x6c,0x65,0x74,0x20,
    0x78,0x5f,0x32,0x32,0x20,0x3a,0x20,0x66,0x33,0x32,0x20,0x3d,0x20,0x70,0x6f,0x73,
    0x69,0x74,0x69,0x6f,0x6e,0x5f,0x31,0x2e,0x78,0x3b,0x0a,0x20,0x20,0x6c,0x65,0x74,
    0x20,0x78,0x5f,0x32,0x34,0x20,0x3a,0x20,0x66,0x33,0x32,0x20,0x3d,0x20,0x70,0x6f,
    0x73,0x69,0x74,0x69,0x6f,0x6e,0x5f,0x31,0x2e,0x79,0x3b,0x0a,0x20,0x20,0x6c,0x65,
    0x74,0x20,0x78,0x5f,0x32,0x37,0x20,0x3a,0x20,0x66,0x33,0x32,0x20,0x3d,0x20,0x70,
    0x6f,0x73,0x69,0x74,0x69,0x6f,0x6e,0x5f,0x31,0x2e,0x7a,0x3b,0x0a,0x20,0x20,0x67,
    0x6c,0x5f,0x50,0x6f,0x73,0x69,0x74,0x69,0x6f,0x6e,0x20,0x3d,0x20,0x76,0x65,0x63,
    0x34,0x66,0x28,0x78,0x5f,0x32,0x32,0x2c,0x20,0x78,0x5f,0x32,0x34,0x2c,0x20,0x78,
    0x5f,0x32,0x37,0x2c,0x20,0x31,0x2e,0x30,0x66,0x29,0x3b,0x0a,0x20,0x20,0x6c,0x65,
    0x74,0x20,0x78,0x5f,0x33,0x35,0x20,0x3a,0x20,0x76,0x65,0x63,0x33,0x66,0x20,0x3d,
    0x20,0x61,0x43,0x6f,0x6c,0x6f,0x72,0x3b,0x0a,0x20,0x20,0x6f,0x75,0x72,0x43,0x6f,
    0x6c,0x6f,0x72,0x20,0x3d,0x20,0x78,0x5f,0x33,0x35,0x3b,0x0a,0x20,0x20,0x72,0x65,
    0x74,0x75,0x72,0x6e,0x3b,0x0a,0x7d,0x0a,0x0a,0x73,0x74,0x72,0x75,0x63,0x74,0x20,
    0x6d,0x61,0x69,0x6e,0x5f,0x6f,0x75,0x74,0x20,0x7b,0x0a,0x20,0x20,0x40,0x62,0x75,
    0x69,0x6c,0x74,0x69,0x6e,0x28,0x70,0x6f,0x73,0x69,0x74,0x69,0x6f,0x6e,0x29,0x0a,
    0x20,0x20,0x67,0x6c,0x5f,0x50,0x6f,0x73,0x69,0x74,0x69,0x6f,0x6e,0x20,0x3a,0x20,
    0x76,0x65,0x63,0x34,0x66,0x2c,0x0a,0x20,0x20,0x40,0x6c,0x6f,0x63,0x61,0x74,0x69,
    0x6f,0x6e,0x28,0x30,0x29,0x0a,0x20,0x20,0x6f,0x75,0x72,0x43,0x6f,0x6c,0x6f,0x72,
    0x5f,0x31,0x20,0x3a,0x20,0x76,0x65,0x63,0x33,0x66,0x2c,0x0a,0x7d,0x0a,0x0a,0x40,
    0x76,0x65,0x72,0x74,0x65,0x78,0x0a,0x66,0x6e,0x20,0x6d,0x61,0x69,0x6e,0x28,0x40,
    0x6c,0x6f,0x63,0x61,0x74,0x69,0x6f,0x6e,0x28,0x30,0x29,0x20,0x70,0x6f,0x73,0x69,
    0x74,0x69,0x6f,0x6e,0x5f,0x31,0x5f,0x70,0x61,0x72,0x61,0x6d,0x20,0x3a,0x20,0x76,
    0x65,0x63,0x33,0x66,0x2c,0x20,0x40,0x6c,0x6f,0x63,0x61,0x74,0x69,0x6f,0x6e,0x28,
    0x31,0x29,0x20,0x61,0x43,0x6f,0x6c,0x6f,0x72,0x5f,0x70,0x61,0x72,0x61,0x6d,0x20,
    0x3a,0x20,0x76,0x65,0x63,0x33,0x66,0x29,0x20,0x2d,0x3e,0x20,0x6d,0x61,0x69,0x6e,
    0x5f,0x6f,0x75,0x74,0x20,0x7b,0x0a,0x20,0x20,0x70,0x6f,0x73,0x69,0x74,0x69,0x6f,
    0x6e,0x5f,0x31,0x20,0x3d,0x20,0x70,0x6f,0x73,0x69,0x74,0x69,0x6f,0x6e,0x5f,0x31,
    0x5f,0x70,0x61,0x72,0x61,0x6d,0x3b,0x0a,0x20,0x20,0x61,0x43,0x6f,0x6c,0x6f,0x72,
    0x20,0x3d,0x20,0x61,0x43,0x6f,0x6c,0x6f,0x72,0x5f,0x70,0x61,0x72,0x61,0x6d,0x3b,
    0x0a,0x20,0x20,0x6d,0x61,0x69,0x6e,0x5f,0x31,0x28,0x29,0x3b,0x0a,0x20,0x20,0x72,
    0x65,0x74,0x75,0x72,0x6e,0x20,0x6d,0x61,0x69,0x6e,0x5f,0x6f,0x75,0x74,0x28,0x67,
    0x6c,0x5f,0x50,0x6f,0x73,0x69,0x74,0x69,0x6f,0x6e,0x2c,0x20,0x6f,0x75,0x72,0x43,
    0x6f,0x6c,0x6f,0x72,0x29,0x3b,0x0a,0x7d,0x0a,0x0a,0x00,
};
//
//    diagnostic(off, derivative_uniformity);
//
//    var<private> FragColor : vec4f;
//
//    var<private> ourColor : vec3f;
//
//    fn main_1() {
//      let x_13 : vec3f = ourColor;
//      FragColor = vec4f(x_13.x, x_13.y, x_13.z, 1.0f);
//      return;
//    }
//
//    struct main_out {
//      @location(0)
//      FragColor_1 : vec4f,
//    }
//
//    @fragment
//    fn main(@location(0) ourColor_param : vec3f) -> main_out {
//      ourColor = ourColor_param;
//      main_1();
//      return main_out(FragColor);
//    }
//
//
const fs_source_wgsl = [418]u8 {
    0x64,0x69,0x61,0x67,0x6e,0x6f,0x73,0x74,0x69,0x63,0x28,0x6f,0x66,0x66,0x2c,0x20,
    0x64,0x65,0x72,0x69,0x76,0x61,0x74,0x69,0x76,0x65,0x5f,0x75,0x6e,0x69,0x66,0x6f,
    0x72,0x6d,0x69,0x74,0x79,0x29,0x3b,0x0a,0x0a,0x76,0x61,0x72,0x3c,0x70,0x72,0x69,
    0x76,0x61,0x74,0x65,0x3e,0x20,0x46,0x72,0x61,0x67,0x43,0x6f,0x6c,0x6f,0x72,0x20,
    0x3a,0x20,0x76,0x65,0x63,0x34,0x66,0x3b,0x0a,0x0a,0x76,0x61,0x72,0x3c,0x70,0x72,
    0x69,0x76,0x61,0x74,0x65,0x3e,0x20,0x6f,0x75,0x72,0x43,0x6f,0x6c,0x6f,0x72,0x20,
    0x3a,0x20,0x76,0x65,0x63,0x33,0x66,0x3b,0x0a,0x0a,0x66,0x6e,0x20,0x6d,0x61,0x69,
    0x6e,0x5f,0x31,0x28,0x29,0x20,0x7b,0x0a,0x20,0x20,0x6c,0x65,0x74,0x20,0x78,0x5f,
    0x31,0x33,0x20,0x3a,0x20,0x76,0x65,0x63,0x33,0x66,0x20,0x3d,0x20,0x6f,0x75,0x72,
    0x43,0x6f,0x6c,0x6f,0x72,0x3b,0x0a,0x20,0x20,0x46,0x72,0x61,0x67,0x43,0x6f,0x6c,
    0x6f,0x72,0x20,0x3d,0x20,0x76,0x65,0x63,0x34,0x66,0x28,0x78,0x5f,0x31,0x33,0x2e,
    0x78,0x2c,0x20,0x78,0x5f,0x31,0x33,0x2e,0x79,0x2c,0x20,0x78,0x5f,0x31,0x33,0x2e,
    0x7a,0x2c,0x20,0x31,0x2e,0x30,0x66,0x29,0x3b,0x0a,0x20,0x20,0x72,0x65,0x74,0x75,
    0x72,0x6e,0x3b,0x0a,0x7d,0x0a,0x0a,0x73,0x74,0x72,0x75,0x63,0x74,0x20,0x6d,0x61,
    0x69,0x6e,0x5f,0x6f,0x75,0x74,0x20,0x7b,0x0a,0x20,0x20,0x40,0x6c,0x6f,0x63,0x61,
    0x74,0x69,0x6f,0x6e,0x28,0x30,0x29,0x0a,0x20,0x20,0x46,0x72,0x61,0x67,0x43,0x6f,
    0x6c,0x6f,0x72,0x5f,0x31,0x20,0x3a,0x20,0x76,0x65,0x63,0x34,0x66,0x2c,0x0a,0x7d,
    0x0a,0x0a,0x40,0x66,0x72,0x61,0x67,0x6d,0x65,0x6e,0x74,0x0a,0x66,0x6e,0x20,0x6d,
    0x61,0x69,0x6e,0x28,0x40,0x6c,0x6f,0x63,0x61,0x74,0x69,0x6f,0x6e,0x28,0x30,0x29,
    0x20,0x6f,0x75,0x72,0x43,0x6f,0x6c,0x6f,0x72,0x5f,0x70,0x61,0x72,0x61,0x6d,0x20,
    0x3a,0x20,0x76,0x65,0x63,0x33,0x66,0x29,0x20,0x2d,0x3e,0x20,0x6d,0x61,0x69,0x6e,
    0x5f,0x6f,0x75,0x74,0x20,0x7b,0x0a,0x20,0x20,0x6f,0x75,0x72,0x43,0x6f,0x6c,0x6f,
    0x72,0x20,0x3d,0x20,0x6f,0x75,0x72,0x43,0x6f,0x6c,0x6f,0x72,0x5f,0x70,0x61,0x72,
    0x61,0x6d,0x3b,0x0a,0x20,0x20,0x6d,0x61,0x69,0x6e,0x5f,0x31,0x28,0x29,0x3b,0x0a,
    0x20,0x20,0x72,0x65,0x74,0x75,0x72,0x6e,0x20,0x6d,0x61,0x69,0x6e,0x5f,0x6f,0x75,
    0x74,0x28,0x46,0x72,0x61,0x67,0x43,0x6f,0x6c,0x6f,0x72,0x29,0x3b,0x0a,0x7d,0x0a,
    0x0a,0x00,
};
pub fn simpleShaderDesc(backend: sg.Backend) sg.ShaderDesc {
    var desc: sg.ShaderDesc = .{};
    desc.label = "simple_shader";
    switch (backend) {
        .GLCORE => {
            desc.attrs[0].name = "position";
            desc.attrs[1].name = "aColor";
            desc.vs.source = &vs_source_glsl430;
            desc.vs.entry = "main";
            desc.fs.source = &fs_source_glsl430;
            desc.fs.entry = "main";
        },
        .GLES3 => {
            desc.attrs[0].name = "position";
            desc.attrs[1].name = "aColor";
            desc.vs.source = &vs_source_glsl300es;
            desc.vs.entry = "main";
            desc.fs.source = &fs_source_glsl300es;
            desc.fs.entry = "main";
        },
        .D3D11 => {
            desc.attrs[0].sem_name = "TEXCOORD";
            desc.attrs[0].sem_index = 0;
            desc.attrs[1].sem_name = "TEXCOORD";
            desc.attrs[1].sem_index = 1;
            desc.vs.source = &vs_source_hlsl5;
            desc.vs.d3d11_target = "vs_5_0";
            desc.vs.entry = "main";
            desc.fs.source = &fs_source_hlsl5;
            desc.fs.d3d11_target = "ps_5_0";
            desc.fs.entry = "main";
        },
        .METAL_MACOS => {
            desc.vs.source = &vs_source_metal_macos;
            desc.vs.entry = "main0";
            desc.fs.source = &fs_source_metal_macos;
            desc.fs.entry = "main0";
        },
        .WGPU => {
            desc.vs.source = &vs_source_wgsl;
            desc.vs.entry = "main";
            desc.fs.source = &fs_source_wgsl;
            desc.fs.entry = "main";
        },
        else => {},
    }
    return desc;
}
