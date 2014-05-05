// Generates Atom menu file from Emmet action list
var fs = require('fs');
var path = require('path');
var actions = require('emmet/lib/action/main');

function generateMenu(menu) {
	return menu.map(function(item) {
		if (item.type == 'action') {
			return {
				label: item.label,
				command: 'emmet:' + item.name.replace(/_/g, '-')
			};
		}

		if (item.type == 'submenu') {
			return {
				label: item.name,
				submenu: generateMenu(item.items)
			};
		}
	});
}

var menu = {
	'menu': [{
		label: 'Packages',
		submenu: [{
			label: 'Emmet',
			submenu: generateMenu(actions.getMenu()).concat([{
				label: 'Interactive Expand Abbreviation',
				command: 'emmet:interactive-expand-abbreviation'
			}])
		}]
	}]
};

var menuFile = path.join(__dirname, 'menus', 'emmet.json');
fs.writeFileSync(menuFile, JSON.stringify(menu, null, '\t'), {encoding: 'utf8'});

console.log('Menu file "%s" generated successfully', menuFile);