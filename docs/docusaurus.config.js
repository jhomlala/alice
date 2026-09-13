/** @type {import('@docusaurus/types').Config} */
const config = {
  title: 'Alice',
  tagline: 'HTTP Inspector tool for Flutter',
  url: 'https://jhomlala.github.io',
  baseUrl: '/alice/',
  organizationName: 'jhomlala',
  projectName: 'alice',
  onBrokenLinks: 'warn',
  onBrokenMarkdownLinks: 'warn',
  i18n: {
    defaultLocale: 'en',
    locales: ['en']
  },
  presets: [
    [
      'classic',
      {
        docs: {
          routeBasePath: '/',
          path: '.',
          sidebarPath: require.resolve('./sidebars.js'),
          editUrl: 'https://github.com/jhomlala/alice/tree/master/',
        },
        blog: false,
        theme: {
          customCss: require.resolve('./src/css/custom.css')
        },
      },
    ],
  ],
  themeConfig: {
    colorMode: {
      defaultMode: 'dark',
      disableSwitch: false,
      respectPrefersColorScheme: false
    },
    navbar: {
      title: 'Alice',
      items: [
        {
          to: '/',
          label: 'Docs',
          position: 'left'
        },
        {
          href: 'https://pub.dev/packages/alice',
          label: 'pub.dev',
          position: 'right'
        },
        {
          href: 'https://github.com/jhomlala/alice',
          label: 'GitHub',
          position: 'right'
        },
      ],
    },
    footer: {
      style: 'dark',
      copyright: `Copyright © ${new Date().getFullYear()} Alice. Built with Docusaurus.`,
    },
    prism: {
      additionalLanguages: ['dart', 'yaml']
    },
  },
};
module.exports = config;
