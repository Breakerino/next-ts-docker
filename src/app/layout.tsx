import { Inter } from "next/font/google";

const interFont = Inter({
	variable: "--font",
	subsets: ['cyrillic']
});

export default function RootLayout({
	children,
}: Readonly<{
	children: React.ReactNode;
}>) {
	return (
		<>
			<head>
				<meta name="apple-mobile-web-app-title" content="Breakerino" />
			</head>
			<html lang="en">
				<body className={`${interFont.variable}`}>
					{children}
				</body>
			</html>
		</>
	);
}