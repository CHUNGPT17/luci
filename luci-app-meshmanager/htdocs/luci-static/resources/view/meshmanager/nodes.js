'use strict';
'require view';'require rpc';'require ui';'require uci';'require poll';
var nodes=rpc.declare({object:'meshmanager',method:'nodes',expect:[]});
var sync=rpc.declare({object:'meshmanager',method:'sync',params:['node'],expect:{}});
var discover=rpc.declare({object:'meshmanager',method:'discover',expect:{}});
return view.extend({
 load:function(){return Promise.all([uci.load('meshmanager'),nodes()]);},
 render:function(d){
  var timeout=parseInt(uci.get('meshmanager','main','offline_timeout')||15), data=d[1]||[];
  var root=E('div',{},[E('h2',{},_('Nodes')),E('div',{'class':'cbi-map-descr'},_('Agent tự đăng ký bằng heartbeat. Cấu hình shared được đồng bộ tự động khi revision của Controller thay đổi.')),E('button',{'class':'btn cbi-button-action','click':function(){discover();ui.addNotification(null,E('p',{},_('Đã yêu cầu cập nhật Node.')));}},_('Làm mới')),E('div',{'id':'mm-nodes'})]);
  function draw(ns){
   var now=Math.floor(Date.now()/1000);
   var t=E('table',{'class':'table'},[E('tr',{'class':'tr table-titles'},[E('th',{},_('Tên')),E('th',{},_('IP')),E('th',{},_('Backhaul')),E('th',{},_('2.4GHz')),E('th',{},_('5GHz')),E('th',{},_('Config')),E('th',{},_('Trạng thái')),E('th',{},'')])]);
   (ns||[]).forEach(function(n){var online=(now-(n.last_seen||0))<=timeout;var bh=n.backhaul==='wireless'?('Wi-Fi '+String(n.backhaul_signal||'')+' dBm'):(n.backhaul||'-');t.appendChild(E('tr',{},[E('td',{},n.name||n.id),E('td',{},n.ip||'-'),E('td',{},bh),E('td',{},String(n.clients24||0)+' clients'),E('td',{},String(n.clients5||0)+' clients'),E('td',{},'v'+(n.version||'-')),E('td',{'style':'font-weight:600;color:'+(online?'#159447':'#d33')},online?_('Online'):_('Offline')),E('td',{},E('button',{'class':'btn','disabled':!online,'click':function(){sync(n.id);ui.addNotification(null,E('p',{},_('Đã phát hành revision mới; Agent online sẽ tự đồng bộ.')));}},_('Sync')))]));});
   var box=root.querySelector('#mm-nodes');box.innerHTML='';box.appendChild(t);
  }
  draw(data);poll.add(function(){return nodes().then(draw);},5);return root;
 },handleSaveApply:null,handleSave:null,handleReset:null
});
