'use strict';
'require view';
'require form';
'require uci';

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

return view.extend({
	load: function() {
		return Promise.all([uci.load('wanpolicy'), uci.load('network')]);
	},

	render: function() {
		var m, s, o;
		m = new form.Map('wanpolicy', _('Interface Watchdogs'),
			_('The interface list is detected automatically from the router. Only interfaces for which you create and enable a watchdog are pinged; all other interfaces are untouched.'));

		s = m.section(form.GridSection, 'watchdog', _('Watchdogs'));
		s.addremove = true;
		s.anonymous = false;
		s.nodescriptions = true;

		o = s.option(form.Flag, 'enabled', _('Enabled'));
		o.default = o.enabled;
		o = s.option(form.Value, 'name', _('Name'));
		o.rmempty = false;
		o = s.option(form.ListValue, 'interface', _('Interface'));
		addInterfaces(o);
		o.rmempty = false;
		o = s.option(form.DynamicList, 'target', _('Ping targets'));
		o.placeholder = '1.1.1.1';
		o.rmempty = false;
		o.description = _('If any target replies, the check is considered successful.');
		o = s.option(form.Value, 'interval', _('Interval (seconds)'));
		o.datatype = 'uinteger';
		o.default = '10';
		o = s.option(form.Value, 'failures', _('Consecutive failures'));
		o.datatype = 'uinteger';
		o.default = '3';
		o = s.option(form.Value, 'timeout', _('Ping timeout (seconds)'));
		o.datatype = 'uinteger';
		o.default = '2';
		o = s.option(form.Value, 'restart_delay', _('Down/Up delay (seconds)'));
		o.datatype = 'uinteger';
		o.default = '2';
		o = s.option(form.Value, 'recovery_wait', _('Recovery wait (seconds)'));
		o.datatype = 'uinteger';
		o.default = '20';

		return m.render();
	}
});
