import { CATEGORIES, type CategoryType, type ArticleType, type SampleType } from './data.ts';
import { BrowserRouter, Routes, Route } from 'react-router-dom'
import github_svg from './github-mark.svg';
import zig_svg from './zig-mark.svg';
import sokol_logo from './logo_s_large.png';
import './App.css'
const BASE_URL = import.meta.env.BASE_URL;

function Item(props: { sample: SampleType }) {
  const [name, label] = typeof props.sample == 'string'
    ? [props.sample, props.sample]
    : props.sample;
  return (<div className="item">
    <a href={`${BASE_URL}wasm/${name}.html`}>
      {label}
      <figure>
        <img width={150} height={78} src={`${BASE_URL}wasm/${name}.jpg`} />
      </figure>
    </a>
  </div>);
}

function Article(article: ArticleType) {
  return (<>
    <div className="item article">
      <a href={article.url} target="_blank">
        {'🔗'}{article.title}
      </a>
    </div>
    {article.samples.map((sample, key) => <Item key={key} sample={sample} />)}
  </>);
}

function Category(category: CategoryType) {
  return (<>
    <div className="item category">
      {category.name}
    </div>
    {category.articles.map((props, key) => <Article key={key} {...props} />)}
  </>);
}

function Home() {

  <header>
    <h1>Learn OpenGL Examples</h1>
    <nav>
      <ul>
      </ul>
    </nav>
  </header>

  return (
    <>
      <main className="items">
        <div className="item"><a href="https://github.com/ousttrue/learnopengl-examples">
          <a href="https://github.com/ousttrue/learnopengl-examples" target="_blank">
            <img width={150} src={github_svg} />
          </a>
        </a></div>
        <div className="item">
          <a href="https://github.com/floooh/sokol-zig" target="_blank">
            <img width={75} src={sokol_logo} />
            <img width={75} src={zig_svg} />
          </a>
        </div>
        <div className="item">
          <a href="https://github.com/JoeyDeVries/LearnOpenGL" target="_blank">
            🔗learnopengl
          </a>
        </div>

        <div className="item">
          <a href="https://github.com/JoeyDeVries/LearnOpenGL" target="_blank">
            <img width={75} src={sokol_logo} />
            🔗learnopengl-examples(joey)
          </a>
        </div>

        <div className="item">
          <a href="https://github.com/zeromake/learnopengl-examples" target="_blank">
            <img width={75} src={sokol_logo} />
            🔗learnopengl-examples(zero)
          </a>
        </div>

        {CATEGORIES.map((props, key) => <Category key={key} {...props} />)}
      </main>
    </>
  )
}

function Page404() {
  return (<>
    <div className="not_found">
      <div>404 not found</div>
    </div>
  </>);
}

function App() {
  return (
    <>
      <BrowserRouter basename={BASE_URL}>
        <Routes>
          <Route index element={<Home />} />
          <Route path="*" element={<Page404 />} />
        </Routes>
      </BrowserRouter>
    </>
  )
}

export default App
