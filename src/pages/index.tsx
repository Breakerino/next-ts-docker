import Image from "next/image";
import Head from 'next/head';

import "./index.css";

const Index: React.FC = () => {
	return (
		<>
			<Head>
				<title>Next.js + TypeScript + Docker</title>
				<meta name="viewport" content="width=device-width, initial-scale=1" />
				<link rel="icon" href="/favicon.ico" />
			</Head>

			<div className="wrapper">
				<main>
					<div className="container">
						<a href="https://nextjs.org/" target="_blank">
							<Image
								className="nextjs-logo"
								src="/nextjs-logo-icon.svg"
								alt="Next.js logo"
								width={180}
								height={38}
								priority
							/>
						</a>
						<h1>TypeScript + Docker</h1>
					</div>
				</main>
				<footer>
					<div className="container">
						<div className="created-by">
							<span>Created by</span>
							<a href="https://breakerino.me" target="_blank">
								<Image
									className="breakerino-logo"
									src="/breakerino-logo-icon.svg"
									alt="Breakerino logo"
									width={110}
									height={16}
									priority
								/>
							</a>
						</div>
					</div>
				</footer>
			</div>
		</>
	);
}

export default Index;