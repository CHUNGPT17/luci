'use strict';
'require view';'require rpc';'require ui';
var sync=rpc.declare({object:'meshmanager',method:'sync',params:['node'],expect:{}});
return view.extend({render:function(){return E('div',{},[E('h2',{},_('Đồng bộ cấu hình')),E('p',{},_('Controller phát hành revision mới; Agent sẽ tự nhận ở chu kỳ heartbeat kế tiếp.')),E('button',{'class':'btn cbi-button-action important','click':function(){sync('');ui.addNotification(null,E('p',{},_('Đã phát hành cấu hình mới.')));}},_('Đồng bộ tất cả Node'))]);},handleSaveApply:null,handleSave:null,handleReset:null});
