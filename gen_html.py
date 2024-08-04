from typing import List, Dict
import pathlib
import sys
# pip install pytest-playwright
from playwright.sync_api import sync_playwright
import dataclasses

BEGIN_HTML = """<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01//EN" "http://www.w3.org/TR/html4/strict.dtd">
<html>
<head>
<meta charset="UTF-8"/>
<meta name="viewport" content="width=device-width, initial-scale=1"/>
<title>Learn OpenGL Examples</title>
<link rel="icon" type="image/png" href="favicon.png"/>
<link href="styles/style.css" rel="stylesheet" />
</head>
<body>
<header>
<h1><a class="main-menu-link" href="https://github.com/zeromake/learnopengl-examples">Learn OpenGL Examples</a></h1>
<nav>
    <ul>
    <li><a href="https://github.com/zeromake/learnopengl-examples">github</a></li>
    <li><a href="https://learnopengl.com">learnopengl</a></li>
    <li><a href="https://github.com/floooh/sokol">sokol</a></li>
    <li><a href="https://www.geertarien.com">blog</a></li>
    </ul>
</nav>
</header>
<main>
    <section id="intro">
        <p>
            <b>Unofficial</b> WebGL examples for <a href="https://learnopengl.com/">learnopengl.com</a>
        </p>
        <ul>
            <li> written in C, compiled to WebAssembly </li>
            <li> shader dialect GLSL v450, cross-compiled to GLSL v300es (WebGL2) </li>
            <li> uses <a href="https://github.com/floooh/sokol">Sokol libraries</a> for cross platform support </li>
            <li> last updated: 2024-06-11 08:54:50 +00:00 </i>
        </ul>
    </section>
"""

END_HTML = """
<hr>

</main>
</body>
</html>
"""

ARTICLE_HTML = """
<article>
    <section class="header"><h3><a href="">Hello Window <i class="icon-link-ext"></i></a></h3></section>
    <section class="group examples">
        <figure class="col-15">
            <figcaption><h4>rendering</h4></figcaption>
            <div><img class="responsive" src="1-3-1.jpg" alt=""></div>
            <a href="1-3-1.html">Read More</a>
        </figure>
    </section>
</article>
"""


@dataclasses.dataclass
class Section:
    name: str


@dataclasses.dataclass
class Article:
    name: str
    url: str
    sections: List[Section]


EXAMPLE_MAP: Dict[str, List[Article]] = {
    "Getting started": [
        Article(
            "Hello Window",
            "https://learnopengl.com/Getting-started/Hello-Window",
            [Section("1-3-1")],
        ),
        Article(
            "Hello Triangle",
            "https://learnopengl.com/Getting-started/Hello-Triangle",
            [Section("1-4-1"), Section("1-4-2"), Section("1-4-3")],
        ),
        Article(
            "Shaders",
            "https://learnopengl.com/Getting-started/Shaders",
            [Section("1-5-1"), Section("1-5-2"), Section("1-5-3")],
        ),
        Article(
            "Textures",
            "https://learnopengl.com/Getting-started/Textures",
            [Section("1-6-1"), Section("1-6-2"), Section("1-6-3")],
        ),
        Article(
            "Transformations",
            "https://learnopengl.com/Getting-started/Transformations",
            [
                Section("1-7-1"),
                Section("1-7-2"),
            ],
        ),
        Article(
            "Coordinate Systems",
            "https://learnopengl.com/Getting-started/Coordinate-Systems",
            [Section("1-8-1"), Section("1-8-2"), Section("1-8-3")],
        ),
        Article(
            "Camera",
            "https://learnopengl.com/Getting-started/Camera",
            [Section("1-9-1"), Section("1-9-2"), Section("1-9-3")],
        ),
    ],
    "Lighting": [
        Article(
            "Colors",
            "https://learnopengl.com/Lighting/Colors",
            [Section("2-1-1")],
        ),
        Article(
            "Basic Lighting",
            "https://learnopengl.com/Lighting/Basic-Lighting",
            [Section("2-2-1"), Section("2-2-2"), Section("2-2-3")],
        ),
        Article(
            "Materials",
            "https://learnopengl.com/Lighting/Materials",
            [Section("2-3-1"), Section("2-3-1"), Section("2-3-3")],
        ),
        Article(
            "Lighting Maps",
            "https://learnopengl.com/Lighting/Lighting-maps",
            [
                Section("2-4-1"),
                Section("2-4-2"),
            ],
        ),
        Article(
            "Light Casters",
            "https://learnopengl.com/Lighting/Light-casters",
            [Section("2-5-1"), Section("2-5-2"), Section("2-5-3"), Section("2-5-4")],
        ),
        Article(
            "Multiple Lights",
            "https://learnopengl.com/Lighting/Multiple-lights",
            [Section("2-6-1")],
        ),
    ],
    "Model Loading": [
        Article(
            "Model",
            "https://learnopengl.com/Model-Loading/Model",
            [Section("3-1-1"), Section("3-1-2")],
        ),
    ],
    "Advanced OpenGL": [
        Article(
            "Depth Testing",
            "https://learnopengl.com/Advanced-OpenGL/Depth-testing",
            [Section("4-1-1"), Section("4-1-2"), Section("4-1-3"), Section("4-1-4")],
        ),
        Article(
            "Stencil Testing",
            "https://learnopengl.com/Advanced-OpenGL/Stencil-testing",
            [Section("4-2-1")],
        ),
        Article(
            "Blending",
            "https://learnopengl.com/Advanced-OpenGL/Blending",
            [Section("4-3-1"), Section("4-3-2"), Section("4-3-3"), Section("4-3-4")],
        ),
        Article(
            "Face Culling",
            "https://learnopengl.com/Advanced-OpenGL/Face-culling",
            [Section("4-4-1")],
        ),
        Article(
            "Framebuffers",
            "https://learnopengl.com/Advanced-OpenGL/Framebuffers",
            [
                Section("4-5-1"),
                Section("4-5-2"),
                Section("4-5-3"),
                Section("4-5-4"),
                Section("4-5-5"),
                Section("4-5-6"),
            ],
        ),
        Article(
            "Cubemaps ",
            "https://learnopengl.com/Advanced-OpenGL/Cubemaps",
            [
                Section("4-6-1"),
                Section("4-6-2"),
                Section("4-6-3"),
                Section("4-6-4"),
                Section("4-6-5"),
            ],
        ),
        Article(
            "Advanced GLSL",
            "https://learnopengl.com/Advanced-OpenGL/Advanced-GLSL",
            [Section("4-8-1"), Section("4-8-2"), Section("4-8-3"), Section("4-8-4")],
        ),
        Article(
            "Geometry Shader",
            "https://learnopengl.com/Advanced-OpenGL/Geometry-Shader",
            [Section("4-9-1"), Section("4-9-2"), Section("4-9-3"), Section("4-9-4")],
        ),
        Article(
            "Instancing",
            "https://learnopengl.com/Advanced-OpenGL/Instancing",
            [
                Section("4-10-1"),
                Section("4-10-2"),
                Section("4-10-3"),
                Section("4-10-4"),
            ],
        ),
        Article(
            "Anti Aliasing",
            "https://learnopengl.com/Advanced-OpenGL/Anti-Aliasing",
            [
                Section("4-11-1"),
                Section("4-11-2"),
                Section("4-11-3"),
                Section("4-11-4"),
            ],
        ),
        Article(
            "Advanced Lighting",
            "https://learnopengl.com/Advanced-Lighting/Advanced-Lighting",
            [Section("5-1-1")],
        ),
        Article(
            "Gamma",
            "https://learnopengl.com/Advanced-Lighting/Gamma-Correction",
            [Section("5-2-1")],
        ),
        Article(
            "Shadow Mapping",
            "https://learnopengl.com/Advanced-Lighting/Shadows/Shadow-Mapping",
            [Section("5-3-1"), Section("5-3-2"), Section("5-3-3")],
        ),
        Article(
            "Point Shadows",
            "https://learnopengl.com/Advanced-Lighting/Shadows/Point-Shadows",
            [Section("5-4-1"), Section("5-4-2"), Section("5-4-3")],
        ),
        Article(
            "Normal Mapping",
            "https://learnopengl.com/Advanced-Lighting/Normal-Mapping",
            [Section("5-5-1"), Section("5-5-2"), Section("5-5-3")],
        ),
    ],
}


def screen_shot(name: str, port: int, width: int, height: int):
    with sync_playwright() as p:
        browser = p.chromium.launch()
        page = browser.new_page(viewport={"width": width, "height": height})
        page.goto(f"http://localhost:{port}/{name}.html")
        page.screenshot(path=f"docs/{name}.jpg")

        browser.close()


def main():
    port = 8080
    if len(sys.argv) > 1:
        port = int(sys.argv[1])

    with pathlib.Path("docs/index.html").open("w", encoding="utf-8") as f:
        f.write(BEGIN_HTML)
        f.write(END_HTML)

        # for k, v in EXAMPLE_MAP.items():
        # screen_shot("shapes-transform", port, 400, 300)


if __name__ == "__main__":
    main()
