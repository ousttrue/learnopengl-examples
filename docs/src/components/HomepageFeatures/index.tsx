import clsx from 'clsx';
import Heading from '@theme/Heading';
import styles from './styles.module.css';
import { list as LearnOpenGL } from './list';
import Link from '@docusaurus/Link';
import ThemedImage from '@theme/ThemedImage';
import useBaseUrl from '@docusaurus/useBaseUrl';


function Item({ name }: { name: string }) {
  return (

    <div className={clsx('col col--4')}>
      <div className="text--center padding-horiz--md">
        <Heading as="h3">{name}</Heading>
        <p>
          <Link
            target="_blank"
            to={useBaseUrl(`/wasm/${name}.html`)}>
            <ThemedImage
              sources={{
                light: useBaseUrl(`/wasm/${name}.jpg`),
                dark: useBaseUrl(`/wasm/${name}.jpg`),
              }} />
          </Link>
        </p>
      </div>
    </div>
  );
}

function Feature({ title, url, sections }) {
  return (
    <>
      {sections.map((name, idx) => (
        <Item key={idx} name={name} />
      ))
      }
    </>
  );
}

function Group({ name, list }) {
  return (
    <>
      {list.map((props, idx) => (
        <Feature key={idx} {...props} />
      ))
      }
    </>
  );
}

export default function HomepageFeatures(): JSX.Element {
  return (
    <section className={styles.features}>
      <div className="container">
        <div className="row">
          {LearnOpenGL.map((props, idx) => (
            <Group key={idx} {...props} />
          ))}
        </div>
      </div>
    </section>
  );
}
