'use strict';
'require view';
'require form';
'require uci';
'require ui';

function addInterfaces(o) {
	var found = false;
	uci.sections('network', 'interface', function(s) {
		var name = s['.name'];
		if (name && name !== 'loopback') {
			o.value(name, name);
			found = true;
		}
	});

	if (!found)
		o.value('', _('No network interfaces found'));
}

var YOUTUBE_DOMAINS = [
	'youtube.com',
	'youtu.be',
	'googlevideo.com',
	'ytimg.com',
	'youtubei.googleapis.com',
	'youtube.googleapis.com'
];

function addYoutubePreset(map) {
	var sid = uci.add('wanpolicy', 'policy');
	uci.set('wanpolicy', sid, 'enabled', '1');
	uci.set('wanpolicy', sid, 'name', 'YouTube');
	uci.set('wanpolicy', sid, 'proto', 'all');
	uci.set('wanpolicy', sid, 'domain', YOUTUBE_DOMAINS);

	return uci.save()
		.then(function() {
			ui.addNotification(null, E('p', _('YouTube policy created. Select its Primary and Backup interfaces, then click Save & Apply.')));
			return map.load();
		})
		.then(function() { return map.reset(); });
}

return view.extend({
	load: function() {
		return Promise.all([uci.load('wanpolicy'), uci.load('network')]);
	},

	render: function() {
		var m, s, o;
		m = new form.Map('wanpolicy', _('WAN Policy'),
			_('Interface names are detected automatically from the router. For each domain policy, choose which current interface is primary and which is backup; no WAN name is hard-coded by this app.'));

		s = m.section(form.NamedSection, 'global', 'global', _('General'));
		s.anonymous = true;
		o = s.option(form.Flag, 'enabled', _('Enable WAN Policy'));
		o.default = o.enabled;
		o = s.option(form.ListValue, 'pbr_resolver_set', _('PBR domain resolver'));
		o.value('dnsmasq.nftset', 'dnsmasq.nftset');
		o.default = 'dnsmasq.nftset';
		o = s.option(form.Flag, 'strict_enforcement', _('Strict enforcement'));
		o.default = o.disabled;
		o.description = _('Keep this disabled if traffic should fall back instead of being rejected when a selected route is unavailable.');

		o = s.option(form.Button, '_youtube_preset', _('Quick preset: YouTube'));
		o.inputstyle = 'add';
		o.inputtitle = _('Add YouTube Policy');
		o.description = _('Creates a new editable policy pre-filled with common YouTube domains. Interface names are not preset; choose Primary and Backup from the router interface list.');
		o.onclick = function() {
			return addYoutubePreset(m);
		};

		s = m.section(form.GridSection, 'policy', _('Domain policies'));
		s.addremove = true;
		s.anonymous = false;
		s.nodescriptions = true;

		o = s.option(form.Flag, 'enabled', _('Enabled'));
		o.default = o.enabled;
		o = s.option(form.Value, 'name', _('Name'));
		o.rmempty = false;
		o = s.option(form.ListValue, 'primary', _('Primary interface'));
		addInterfaces(o);
		o.rmempty = false;
		o = s.option(form.ListValue, 'backup', _('Backup interface'));
		addInterfaces(o);
		o.rmempty = false;
		o = s.option(form.ListValue, 'proto', _('Protocol'));
		o.value('all', _('All'));
		o.value('tcp', 'TCP');
		o.value('udp', 'UDP');
		o.default = 'all';
		o = s.option(form.DynamicList, 'domain', _('Domains'));
		o.rmempty = false;
		o.placeholder = 'youtube.com';
		o.description = _('Add domains with the + button and remove individual domains with the delete button. You can freely edit preset domains. Domain-to-IP tracking is handled by PBR with dnsmasq nftset.');
		o.modalonly = true;

		return m.render();
	}
});
