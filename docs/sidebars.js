/** @type {import('@docusaurus/plugin-content-docs').SidebarsConfig} */
const sidebars = {
  docsSidebar: [
    {
      type: 'category',
      label: 'Getting Started',
      items: ['introduction', 'configuration', 'environments', 'advanced-usage', 'platforms'],
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
  ],
};
module.exports = sidebars;
