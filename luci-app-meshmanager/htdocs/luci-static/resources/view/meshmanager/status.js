'use strict';
'require view';
'require rpc';
'require uci';
'require poll';

var callStatus = rpc.declare({ object: 'meshmanager', method: 'status', expect: {} });
var callNodes = rpc.declare({ object: 'meshmanager', method: 'nodes', expect: [] });

return view.extend({
	load: function() {
		return Promise.all([uci.load('meshmanager'), callStatus(), callNodes()]);
	},

	render: function(data) {
		var timeout = parseInt(uci.get('meshmanager', 'main', 'offline_timeout') || 15);
		var root = E('div', {}, [
			E('h2', {}, _('Mesh Manager')),
			E('div', { 'class': 'cbi-map-descr' }, _('Controller / Agent, Wi-Fi 2.4/5GHz, 802.11r/k/v, Smart Roaming và đồng bộ cấu hình.')),
			E('div', { 'id': 'mm-status' })
		]);

		function draw(status, nodes) {
			status = status || {};
			nodes = nodes || [];
			var now = Math.floor(Date.now() / 1000);
			var online = nodes.filter(function(n) {
				return now - (n.last_seen || 0) <= timeout;
			}).length;
			var box = root.querySelector('#mm-status');
			box.innerHTML = '';
			box.appendChild(E('table', { 'class': 'table' }, [
				E('tr', {}, [E('td', {}, _('Vai trò')), E('td', {}, status.role || '-')]),
				E('tr', {}, [E('td', {}, _('IP')), E('td', {}, status.ip || '-')]),
				E('tr', {}, [E('td', {}, _('Config Version')), E('td', {}, 'v' + (status.version || '-'))]),
				E('tr', {}, [E('td', {}, _('Smart Roaming')), E('td', {}, status.smart === '1' ? _('Enabled') : _('Disabled'))]),
				E('tr', {}, [E('td', {}, _('Nodes')), E('td', {}, online + ' online / ' + Math.max(nodes.length - online, 0) + ' offline')]),
				E('tr', {}, [E('td', {}, _('Đồng bộ cuối')), E('td', {}, status.last_sync || '-')])
			]));
		}

		draw(data[1], data[2]);
		poll.add(function() {
			return Promise.all([callStatus(), callNodes()]).then(function(x) {
				draw(x[0], x[1]);
			});
		}, 5);
		return root;
	},

	handleSaveApply: null,
	handleSave: null,
	handleReset: null
});
