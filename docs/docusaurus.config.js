module.exports = {
  title: 'Jembi Platform',
  tagline: 'An easy CDR solution',
  url: 'https://jembi.github.io',
  baseUrl: '/platform/',
  favicon: 'img/favicon.ico',
  organizationName: 'jembi',
  projectName: 'platform',
  themeConfig: {
    navbar: {
      title: 'Jembi Platform',
      logo: {
        alt: 'Jembi Platform Logo',
        src: 'img/jembi_icon.png'
      },
      items: [
        { to: 'docs/introduction/overview', label: 'Docs', position: 'left' },
        {
          href: 'https://github.com/jembi/platform',
          label: 'GitHub',
          position: 'right'
        }
      ]
    },
    footer: {
      style: 'dark',
      copyright: `<a rel="license" href="http://creativecommons.org/licenses/by/4.0/"><img alt="Creative Commons Licence" style="border-width:0" src="https://i.creativecommons.org/l/by/4.0/88x31.png" /></a><br />This work is licensed under a <a rel="license" href="http://creativecommons.org/licenses/by/4.0/">Creative Commons Attribution 4.0 International License</a>.`
    },
    prism: {
      theme: require('prism-react-renderer/themes/nightOwl')
    }
  },
  presets: [
    [
      '@docusaurus/preset-classic',
      {
        docs: {
          sidebarPath: require.resolve('./sidebars.js'),
          editUrl: 'https://github.com/jembi/platform/tree/master/docs/'
        },
        theme: {
          customCss: require.resolve('./src/css/custom.css')
        }
      }
    ]
  ]
}
