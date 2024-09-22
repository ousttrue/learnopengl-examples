import { CATEGORIES, type CategoryType, type ArticleType } from './data.ts';
const BASE_URL = import.meta.env.BASE_URL;

function Item(props: { name: string }) {
  return (<div className="item">
    <a href={`${BASE_URL}wasm/${props.name}.html`}>
      {props.name}
      <figure>
        <img width={150} height={78} src={`${BASE_URL}wasm/${props.name}.jpg`} />
      </figure>
    </a>
  </div>);
}

function Article(article: ArticleType) {
  return (<>
    <div className="item article">
      <a href={article.url} target="_blank">
        {article.title}
      </a>
    </div>
    {article.samples.map((name, key) => <Item key={key} name={name} />)}
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

function App() {

  return (
    <>
      <div className="container">
        <header>
          <h1>Learn OpenGL Examples</h1>
          <nav>
            <ul>
              <li><a href="https://github.com/floooh/sokol-zig">sokol-zig</a></li>
              <li><a href="https://learnopengl.com/">learnopengl</a></li>
              <li><a href="https://github.com/zeromake/learnopengl-examples">
                learnopengl-examples
              </a></li>
              <li><a href="https://github.com/ousttrue/learnopengl-examples">
                learnopengl-examples-zig
              </a></li>
            </ul>
          </nav>
        </header>
        <main className="items">
          {CATEGORIES.map((props, key) => <Category key={key} {...props} />)}
        </main>
        <footer>
          <nav></nav>
        </footer>
      </div>
    </>
  )
}

export default App
