'use strict';
'require view';'require rpc';'require poll';
var callClients=rpc.declare({object:'meshmanager',method:'clients',expect:[]});
return view.extend({
 load:function(){return callClients();},
 render:function(data){
  var root=E('div',{},[E('h2',{},_('Clients')),E('div',{'class':'cbi-map-descr'},_('Client đang kết nối trực tiếp trên router này. Trên Controller, xem Nodes để biết tổng trạng thái toàn hệ thống.')),E('div',{'id':'mm-clients'})]);
  function draw(rows){
   rows=rows||[];
   var t=E('table',{'class':'table'},[E('tr',{'class':'tr table-titles'},[E('th',{},_('MAC')),E('th',{},_('Band')),E('th',{},_('Interface')),E('th',{},_('RSSI')),E('th',{},_('TX')),E('th',{},_('RX'))])]);
   rows.forEach(function(c){t.appendChild(E('tr',{},[E('td',{},c.mac||'-'),E('td',{},c.band==='5g'?'5GHz':c.band==='2g'?'2.4GHz':'-'),E('td',{},c.ifname||'-'),E('td',{},String(c.signal||'-')+' dBm'),E('td',{},c.tx||'-'),E('td',{},c.rx||'-')]));});
   var box=root.querySelector('#mm-clients');box.innerHTML='';box.appendChild(t);
  }
  draw(data);
  poll.add(function(){return callClients().then(draw);},5);
  return root;
 },handleSaveApply:null,handleSave:null,handleReset:null
});
