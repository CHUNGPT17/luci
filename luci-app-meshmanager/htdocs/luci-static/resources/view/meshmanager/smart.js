'use strict';
'require view';'require form';'require uci';'require rpc';
var apply=rpc.declare({object:'meshmanager',method:'apply',expect:{}});
return view.extend({
 load:function(){return uci.load('meshmanager');},
 render:function(){
  var m=new form.Map('meshmanager',_('Smart Roaming'),_('Chủ động gửi 802.11v BSS Transition Request khi client bám AP có RSSI yếu. Thiết bị client vẫn là bên quyết định chuyển AP.'));
  var s=m.section(form.NamedSection,'smart','smart_roaming');s.anonymous=true;
  var o=s.option(form.Flag,'enabled',_('Kích hoạt Smart Roaming'));
  o=s.option(form.Value,'roaming_rssi',_('Ngưỡng yêu cầu roaming (dBm)'));o.datatype='range(-100,-30)';o.description=_('Ví dụ -67 dBm. Khi thấp hơn ngưỡng này, hệ thống yêu cầu client tìm AP tốt hơn.');
  o=s.option(form.Value,'critical_rssi',_('Critical RSSI (dBm)'));o.datatype='range(-100,-30)';
  o=s.option(form.Value,'min_dwell',_('Thời gian bám tối thiểu (giây)'));o.datatype='uinteger';o.description=_('Tránh vừa kết nối xong đã bị steering.');
  o=s.option(form.Value,'cooldown',_('Roaming cooldown (giây)'));o.datatype='uinteger';o.description=_('Khoảng nghỉ giữa hai lần yêu cầu roaming cho cùng một client để chống ping-pong.');
  o=s.option(form.Flag,'prefer_5g',_('Ưu tiên 5GHz'));o.description=_('Dành cho logic steering/candidate trên các client hỗ trợ; không ép client rời mạng.');
  o=s.option(form.Flag,'prevent_pingpong',_('Chống ping-pong'));
  o=s.option(form.Flag,'bss_transition',_('Gửi BSS Transition Request'));
  o=s.option(form.Flag,'apply_24',_('Áp dụng cho 2.4GHz'));
  o=s.option(form.Flag,'apply_5',_('Áp dụng cho 5GHz'));
  o=s.option(form.Flag,'force_disconnect',_('Ngắt client ở Critical RSSI'));
  o.description=_('Mặc định nên TẮT. Bật có thể làm gián đoạn tải file/cuộc gọi nếu client không roaming kịp.');
  return m.render();
 },
 handleSaveApply:function(ev){return this.handleSave(ev).then(function(){return apply();});}
});
