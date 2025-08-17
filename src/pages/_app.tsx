import type { AppProps } from 'next/app'

import Layout from '@/app/layout'
import "./globals.css";

const App: React.FC<AppProps> = ({ Component, pageProps }) => {
	return (
		<Layout>
			<Component {...pageProps} />
		</Layout>
	)
}

export default App;