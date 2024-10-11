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
    name: "Getting started", articles: [
      {
        title: "Hello Triangle",
        url: "https://learnopengl.com/Getting-started/Hello-Triangle",
        samples: [
          "hello_triangle",
        ],
      },
      {
        title: "Textures",
        url: "https://learnopengl.com/Getting-started/Textures",
        samples: [
          "textures",
        ],
      },
    ]
  },
  {
    name: "Lighting",
    articles: [
      {
        title: "Colors",
        url: "https://learnopengl.com/Lighting/Colors",
        samples: [
          "colors",
        ],
      },
      {
        title: "Basic-Lighting",
        url: "https://learnopengl.com/Lighting/Basic-Lighting",
        samples: [
          "basic_lighting_diffuse",
          "basic_lighting_specular",
          "basic_lighting_exercise1",
          "basic_lighting_exercise2",
          "basic_lighting_exercise3",
        ],
      },
    ],
  },
  { name: "Model Loading", articles: [] },
  {
    name: "Advanced OpenGL", articles: [
      {
        title: "Framebuffers",
        url: "https://learnopengl.com/Advanced-OpenGL/Framebuffers",
        samples: [
          "framebuffers",
        ],
      },
      {
        title: "Cubemap",
        url: "https://learnopengl.com/Advanced-OpenGL/Cubemaps",
        samples: [
          "cubemap_skybox",
        ],
      },
    ]
  },
  { name: "Advanced Lighting", articles: [] },
  {
    name: "PBR", articles: [
      {
        title: "noet: PBR sahder を動かす",
        url: "https://qiita.com/ousttrue/items/d362d8d774eed7b6ce5f",
        samples: [],
      },
      {
        title: "Lighting",
        url: "https://learnopengl.com/PBR/Lighting",
        samples: [
          "lighting",
          "lighting_textured",
        ],
      },
      {
        title: "IBL Diffuse irradiance",
        url: "https://learnopengl.com/PBR/IBL/Diffuse-irradiance",
        samples: [
          "ibl_irradiance_conversion",
          "ibl_irradiance",
        ],
      },
      {
        title: "IBL Specular",
        url: "https://learnopengl.com/PBR/IBL/Specular-IBL",
        samples: [
          "ibl_specular",
          "ibl_specular_textured",
        ],
      },
    ]
  },
];
