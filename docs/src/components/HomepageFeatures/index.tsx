import React from "react";
import Heading from '@theme/Heading';
import {
  CATEGORIES,
  type ArticleType,
  type CategoryType,
} from './data';
import Link from '@docusaurus/Link';
import ThemedImage from '@theme/ThemedImage';
import useBaseUrl from '@docusaurus/useBaseUrl';


// a sample. wasm thumbnail 
function Sample({ name }: { name: string }) {
  return (<span className="sample">
    <p>
      <Link
        target="_blank"
        to={useBaseUrl(`/wasm/${name}.html`)}>
        <h4>{name}</h4>
        <figure>
          <img src={useBaseUrl(`/wasm/${name}.jpg`)} />
        </figure>
      </Link>
    </p>
  </span>);
}

function OpenClose({ children }) {
  const [open, setOpen] = React.useState(false)
  const onClick = () => setOpen((prev) => !prev)
  return (
    <>
      <button onClick={onClick} style={{ cursor: "pointer" }}>{open ? 'close' : 'open'}</button>
      <div className={`collapse ${open ? 'visible' : 'hidden'}`}>{children}</div>
    </>
  )
}

// article. url
function Article(props: ArticleType) {
  return (<>
    <h3><a href={props.url}>{props.title}</a></h3>
    <OpenClose>
      <div className="article">
        {props.samples.map((name, key) => (
          <Sample key={key} name={name} />
        ))
        }
      </div>
    </OpenClose>
  </>);
}

// category
function Category(props: CategoryType) {
  return (
    <>
      <h2>{props.name}</h2>
      <div className="category">
        {props.articles.map((props, key) => (
          <Article key={key} {...props} />
        ))
        }
      </div>
    </>
  );
}

export default function HomepageFeatures(): JSX.Element {
  return (
    <section>
      {CATEGORIES.map((props, key) => (
        <Category key={key} {...props} />
      ))}
    </section>
  );
}
