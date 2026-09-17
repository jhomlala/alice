/** @type {import('@docusaurus/plugin-content-docs').SidebarsConfig} */
const sidebars = {
  docsSidebar: [
    {
      type: 'category',
      label: 'Getting Started',
      items: ['introduction', 'configuration', 'environments', 'platforms'],
    },
    {
      type: 'category',
      label: 'Features',
      items: [
        'features/inspector-ui',
        'features/search-and-filtering',
        'features/stats-and-timeline',
        'features/exporting-and-sharing',
        'features/request-replay',
      ],
    },
    {
      type: 'category',
      label: 'Advanced Usage',
      items: ['advanced-usage'],
    },
    {
      type: 'category',
      label: 'HTTP Clients',
      items: ['dio', 'retrofit', 'chopper', 'http', 'http_client', 'graphql'],
    },
    {
      type: 'category',
      label: 'Storage',
      items: ['objectbox'],
    },
    {
      type: 'category',
      label: 'Migrations',
      items: ['migration'],
    },
  ],
};
module.exports = sidebars;
