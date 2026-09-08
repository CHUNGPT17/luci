'use strict';
'require view';
'require fs';
'require poll';
'require dom';

function txt(v) { return String(v == null ? '' : v); }
function badge(text, good) {
	return E('span', { 'style': (good ? 'background:#e8f7ee;color:#19743b;border:1px solid #9bd8ae' : 'background:#fdecec;color:#b42318;border:1px solid #f3aaa5') + ';padding:3px 9px;border-radius:4px;font-weight:600;display:inline-block' }, [ text ]);
}
function card(title, body) {
	return E('div', { 'style':'border:1px solid #dce3ea;border-radius:6px;background:#fff;margin:0 0 14px 0' }, [
		E('div', { 'style':'font-size:16px;font-weight:700;padding:13px 15px;border-bottom:1px solid #e7ebef' }, [ title ]),
		E('div', { 'style':'padding:12px 15px' }, [ body ])
	]);
}
function statusView(data) {
	var w = data.watchdogs || [], p = data.policies || [];
	var ok = w.every(function(x){ return x.health === 'healthy'; });
	var summary = E('div', { 'style':(ok?'background:#eefaf2;border:1px solid #b7e3c5;color:#176b35':'background:#fff5f5;border:1px solid #ffc9c9;color:#9c1c1c')+';padding:12px 14px;border-radius:6px;margin-bottom:14px' }, [
		E('strong', {}, [ ok ? _('WAN Policy đang hoạt động') : _('Có watchdog đang báo lỗi') ]),
		E('div', {'style':'margin-top:3px'}, [ '%d policy • %d watchdog'.format(p.length, w.length) ])
	]);
	var wt = E('div', {'class':'table'}, [ E('div', {'class':'tr table-titles'}, [E('div',{'class':'th'},[_('Tên')]),E('div',{'class':'th'},[_('Interface')]),E('div',{'class':'th'},[_('Trạng thái')]),E('div',{'class':'th'},[_('Fail')]),E('div',{'class':'th'},[_('Restart cuối')])]) ]);
	w.forEach(function(x){ wt.appendChild(E('div',{'class':'tr'},[E('div',{'class':'td'},[txt(x.name)]),E('div',{'class':'td'},[txt(x.interface)]),E('div',{'class':'td'},[badge(x.health==='healthy'?'ONLINE':'OFFLINE',x.health==='healthy')]),E('div',{'class':'td'},[txt(x.fails)]),E('div',{'class':'td'},[x.last_restart>0?new Date(x.last_restart*1000).toLocaleString():'-'])])); });
	if (!w.length) wt.appendChild(E('div',{'class':'tr'},[E('div',{'class':'td'},[_('Chưa tạo watchdog nào. Interface không có watchdog sẽ không bị ping.')])]));
	var pt = E('div', {'class':'table'}, [ E('div', {'class':'tr table-titles'}, [E('div',{'class':'th'},[_('Policy')]),E('div',{'class':'th'},[_('Ưu tiên')]),E('div',{'class':'th'},[_('Dự phòng')]),E('div',{'class':'th'},[_('Đang đi qua')]),E('div',{'class':'th'},[_('Primary health')])]) ]);
	p.forEach(function(x){ pt.appendChild(E('div',{'class':'tr'},[E('div',{'class':'td'},[txt(x.name)]),E('div',{'class':'td'},[txt(x.primary)]),E('div',{'class':'td'},[txt(x.backup)]),E('div',{'class':'td'},[txt(x.selected)]),E('div',{'class':'td'},[badge(x.primary_health==='healthy'?'ONLINE':'OFFLINE',x.primary_health==='healthy')])])); });
	if (!p.length) pt.appendChild(E('div',{'class':'tr'},[E('div',{'class':'td'},[_('Chưa tạo domain policy nào.')])]));
	return E([], [summary, card(_('Interface Watchdog'), wt), card(_('Domain Policies'), pt)]);
}
function logView(s) { return E('pre',{'style':'max-height:330px;overflow:auto;background:#111827;color:#e5e7eb;padding:12px;border-radius:5px;font-size:12px;white-space:pre-wrap'},[s||_('Chưa có log.')]); }
return view.extend({
	load:function(){ return Promise.all([fs.read('/tmp/wanpolicy/status.json').catch(function(){return '{}';}),fs.read('/tmp/wanpolicy/wanpolicy.log').catch(function(){return '';})]); },
	render:function(data){
		var sb=E('div',{}), lb=E('div',{});
		function refresh(){ return Promise.all([fs.read('/tmp/wanpolicy/status.json').catch(function(){return '{}';}),fs.read('/tmp/wanpolicy/wanpolicy.log').catch(function(){return '';})]).then(function(r){var d={};try{d=JSON.parse(r[0]);}catch(e){} dom.content(sb,statusView(d));dom.content(lb,logView(r[1]));}); }
		var d={};try{d=JSON.parse(data[0]);}catch(e){} dom.content(sb,statusView(d));dom.content(lb,logView(data[1])); poll.add(refresh,5);
		return E([], [E('h2',{},[_('WAN Policy — Status & Logs')]),E('p',{},[_('Theo dõi watchdog, interface đang được policy sử dụng và nhật ký failover/restart theo thời gian thực.')]),sb,card(_('Logs'),lb)]);
	},
	handleSaveApply:null,handleSave:null,handleReset:null
});
