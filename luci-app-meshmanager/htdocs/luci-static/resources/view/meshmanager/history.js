'use strict';
'require view';'require rpc';'require poll';
var callHistory=rpc.declare({object:'meshmanager',method:'history',expect:[]});
return view.extend({
 load:function(){return callHistory();},
 render:function(data){
  var root=E('div',{},[E('h2',{},_('Roaming History')),E('div',{'class':'cbi-map-descr'},_('Ghi nhận khi Controller quan sát cùng một client chuyển từ Node này sang Node khác qua heartbeat. Đây là AP transition quan sát được, không phải phép đo chính xác thời gian FT.')),E('div',{'id':'mm-history'})]);
  function draw(rows){
   var t=E('table',{'class':'table'},[E('tr',{'class':'tr table-titles'},[E('th',{},_('Thời gian')),E('th',{},_('Client')),E('th',{},_('Từ Node')),E('th',{},_('Sang Node')),E('th',{},_('RSSI cũ')),E('th',{},_('RSSI mới'))])]);
   (rows||[]).forEach(function(x){t.appendChild(E('tr',{},[E('td',{},x.time?new Date(x.time*1000).toLocaleString():'-'),E('td',{},x.mac||'-'),E('td',{},x.from||'-'),E('td',{},x.to||'-'),E('td',{},String(x.old_signal||'-')+' dBm'),E('td',{},String(x.new_signal||'-')+' dBm')]));});
   var b=root.querySelector('#mm-history');b.innerHTML='';b.appendChild(t);
  }
  draw(data);poll.add(function(){return callHistory().then(draw);},5);return root;
 },handleSaveApply:null,handleSave:null,handleReset:null
});
