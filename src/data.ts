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
];
