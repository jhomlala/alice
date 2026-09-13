/** @type {import('@docusaurus/plugin-content-docs').SidebarsConfig} */
const sidebars = {
  docsSidebar: [
    {
      type: 'category',
      label: 'Getting Started',
      items: ['introduction', 'configuration', 'advanced-usage'],
    },
    {
      type: 'category',
      label: 'HTTP Clients',
      items: ['dio', 'chopper', 'http', 'http_client'],
    },
    {
      type: 'category',
      label: 'Storage',
      items: ['objectbox'],
    },
  ],
};
module.exports = sidebars;
