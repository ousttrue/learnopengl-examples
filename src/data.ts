// name, label
export type SampleType = string | [string, string];

export type ArticleType = {
  title: string,
  url: string,
  samples: SampleType[],
};

export type CategoryType = {
  name: string,
  url?: string,
  articles: ArticleType[],
};

export const CATEGORIES: CategoryType[] = [
  {
    "name": "Getting started",
    "articles": [
      {
        "title": "Hello Window",
        "url": "https://learnopengl.com/Getting-started/Hello-Window",
        "samples": [
          "1-3-1"
        ]
      },
      {
        "title": "Hello Triangle",
        "url": "https://learnopengl.com/Getting-started/Hello-Triangle",
        "samples": [
          "1-4-1",
          "1-4-2",
          "1-4-3"
        ]
      },
      {
        "title": "Shaders",
        "url": "https://learnopengl.com/Getting-started/Shaders",
        "samples": [
          "1-5-1",
          "1-5-2",
          "1-5-3"
        ]
      },
      {
        "title": "Textures",
        "url": "https://learnopengl.com/Getting-started/Textures",
        "samples": [
          "1-6-1",
          "1-6-2",
          "1-6-3"
        ]
      },
      {
        "title": "Transformations",
        "url": "https://learnopengl.com/Getting-started/Transformations",
        "samples": [
          "1-7-1",
          "1-7-2"
        ]
      },
      {
        "title": "Coordinate Systems",
        "url": "https://learnopengl.com/Getting-started/Coordinate-Systems",
        "samples": [
          "1-8-1",
          "1-8-2",
          "1-8-3"
        ]
      },
      {
        "title": "Camera",
        "url": "https://learnopengl.com/Getting-started/Camera",
        "samples": [
          "1-9-1",
          "1-9-2",
          "1-9-3"
        ]
      }
    ]
  },
  {
    "name": "Lighting",
    "articles": [
      {
        "title": "Colors",
        "url": "https://learnopengl.com/Lighting/Colors",
        "samples": [
          "2-1-1"
        ]
      },
      {
        "title": "Basic Lighting",
        "url": "https://learnopengl.com/Lighting/Basic-Lighting",
        "samples": [
          "2-2-1",
          "2-2-2",
          "2-2-3"
        ]
      },
      {
        "title": "Materials",
        "url": "https://learnopengl.com/Lighting/Materials",
        "samples": [
          "2-3-1",
          "2-3-1",
          "2-3-3"
        ]
      },
      {
        "title": "Lighting Maps",
        "url": "https://learnopengl.com/Lighting/Lighting-maps",
        "samples": [
          "2-4-1",
          "2-4-2"
        ]
      },
      {
        "title": "Light Casters",
        "url": "https://learnopengl.com/Lighting/Light-casters",
        "samples": [
          "2-5-1",
          "2-5-2",
          "2-5-3",
          "2-5-4"
        ]
      },
      {
        "title": "Multiple Lights",
        "url": "https://learnopengl.com/Lighting/Multiple-lights",
        "samples": [
          "2-6-1"
        ]
      }
    ]
  },
  {
    "name": "Model Loading",
    "articles": [
      {
        "title": "Model",
        "url": "https://learnopengl.com/Model-Loading/Model",
        "samples": [
          "3-1-1",
          "3-1-2"
        ]
      }
    ]
  },
  {
    "name": "Advanced OpenGL",
    "articles": [
      {
        "title": "Depth Testing",
        "url": "https://learnopengl.com/Advanced-OpenGL/Depth-testing",
        "samples": [
          "4-1-1",
          "4-1-2",
          "4-1-3",
          "4-1-4"
        ]
      },
      {
        "title": "Stencil Testing",
        "url": "https://learnopengl.com/Advanced-OpenGL/Stencil-testing",
        "samples": [
          "4-2-1"
        ]
      },
      {
        "title": "Blending",
        "url": "https://learnopengl.com/Advanced-OpenGL/Blending",
        "samples": [
          "4-3-1",
          "4-3-2",
          "4-3-3",
          "4-3-4"
        ]
      },
      {
        "title": "Face Culling",
        "url": "https://learnopengl.com/Advanced-OpenGL/Face-culling",
        "samples": [
          "4-4-1"
        ]
      },
      {
        "title": "Framebuffers",
        "url": "https://learnopengl.com/Advanced-OpenGL/Framebuffers",
        "samples": [
          "4-5-1",
          "4-5-2",
          "4-5-3",
          "4-5-4",
          "4-5-5",
          "4-5-6"
        ]
      },
      {
        "title": "Cubemaps ",
        "url": "https://learnopengl.com/Advanced-OpenGL/Cubemaps",
        "samples": [
          "4-6-1",
          "4-6-2",
          "4-6-3",
          "4-6-4",
          "4-6-5"
        ]
      },
      {
        "title": "Advanced GLSL",
        "url": "https://learnopengl.com/Advanced-OpenGL/Advanced-GLSL",
        "samples": [
          "4-8-1",
          "4-8-2",
          "4-8-3",
          "4-8-4"
        ]
      },
      {
        "title": "Geometry Shader",
        "url": "https://learnopengl.com/Advanced-OpenGL/Geometry-Shader",
        "samples": [
          "4-9-1",
          "4-9-2",
          "4-9-3",
          "4-9-4"
        ]
      },
      {
        "title": "Instancing",
        "url": "https://learnopengl.com/Advanced-OpenGL/Instancing",
        "samples": [
          "4-10-1",
          "4-10-2",
          "4-10-3",
          "4-10-4"
        ]
      },
      {
        "title": "Anti Aliasing",
        "url": "https://learnopengl.com/Advanced-OpenGL/Anti-Aliasing",
        "samples": [
          "4-11-1",
          "4-11-2",
          "4-11-3",
          "4-11-4"
        ]
      },
      {
        "title": "Advanced Lighting",
        "url": "https://learnopengl.com/Advanced-Lighting/Advanced-Lighting",
        "samples": [
          "5-1-1"
        ]
      },
      {
        "title": "Gamma",
        "url": "https://learnopengl.com/Advanced-Lighting/Gamma-Correction",
        "samples": [
          "5-2-1"
        ]
      },
      {
        "title": "Shadow Mapping",
        "url": "https://learnopengl.com/Advanced-Lighting/Shadows/Shadow-Mapping",
        "samples": [
          "5-3-1",
          "5-3-2",
          "5-3-3"
        ]
      },
      {
        "title": "Point Shadows",
        "url": "https://learnopengl.com/Advanced-Lighting/Shadows/Point-Shadows",
        "samples": [
          "5-4-1",
          "5-4-2",
          "5-4-3"
        ]
      },
      {
        "title": "Normal Mapping",
        "url": "https://learnopengl.com/Advanced-Lighting/Normal-Mapping",
        "samples": [
          "5-5-1",
          "5-5-2",
          "5-5-3"
        ]
      }
    ]
  },
  {
    "name": "SokolExamples",
    "articles": [
      {
        "title": "Sokol WebGL",
        "url": "https://floooh.github.io/sokol-html5/",
        "samples": [
          "clear",
          "triangle",
          "triangle-bufferless",
          "quad",
          "bufferoffsets",
          "cube",
          "noninterleaved",
          "texcube",
          "vertexpull",
          "sbuftex",
          "shapes",
          "shapes-transform",
          "offscreen-msaa",
          "instancing",
          "instancing-pull",
          "mrt",
          "mrt-pixelformats",
          "arraytex",
          "tex3d",
          "dyntex3d",
          "dyntex",
          "basisu",
          "cubemap-jpeg",
          "cubemaprt",
          "miprender",
          "layerrender",
          "primtypes",
          "uvwrap",
          "mipmap",
          "uniformtypes",
          "blend",
          "sdf",
          "shadows",
          "shadows-depthtex",
          "imgui",
          "imgui-dock",
          "imgui-highdpi",
          "cimgui",
          "imgui-images",
          "imgui-usercallback",
          "nuklear",
          "nuklear-images",
          "sgl-microui",
          "fontstash",
          "fontstash-layers",
          "debugtext",
          "debugtext-printf",
          "debugtext-userfont",
          "debugtext-context",
          "debugtext-layers",
          "events",
          "icon",
          "droptest",
          "pixelformats",
          "drawcallperf",
          "saudio",
          "modplay",
          "noentry",
          "restart",
          "sgl",
          "sgl-lines",
          "sgl-points",
          "sgl-context",
          "loadpng",
          "plmpeg",
          "cgltf",
          "shdfeatures",
          "spine-simple",
          "spine-inspector",
          "spine-layers",
          "spine-skinsets",
          "spine-switch-skinsets",
          "spine-contexts",
          "ozz-anim",
          "ozz-skin",
          "ozz-storagebuffer",
        ]
      }
    ]
  },
];
