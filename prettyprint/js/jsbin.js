var me = null;
var sessionhandle = null;
var storeArray=[];
var __storeindex = -1;
//yaojiao制皂  
 yaojiaozhizao = {
   app_key : '21787525',
   app_secret : '6dfd25675f31e63f2001d75316e84f55',
   session : '6102628c412131cfef76f85545a1611c7f101bea6655ac01849144340'
 };   
   
 //yaojiao店铺 
 yaojiaodianpu = {
   app_key : '21788695',
   app_secret : 'a60f6dc9046fc83f908c958b02ca9f88',
   session : '610051261ec3d7a44dba190880df9ec21a0128d21599e9d1849124761'
 };   
 
 //古铺良品
 gupuliangpin = {
   app_key : '21788679',
   app_secret : '6843f041349981778200d335cc9468e0',
   session : '6100523450cb96e55fe6973306ebdee1e1cd2d3bca096301781635477'
 };   
 
 //厦门富丽手工皂
 xiamenfulishougongzao = {
   app_key : '21788697',
   app_secret : '03d48c80435b17f0aaf7950e449bfedd',
   session : '6101820fc56a3cd1481a37803e4117e6a5c4f345d8213f11767293553'
 };  

var fields='seller_nick,buyer_nick,title,type,created,sid,tid,seller_rate,buyer_rate,status,payment,discount_fee,adjust_fee,post_fee,total_fee,pay_time,end_time,modified,consign_time,buyer_obtain_point_fee,point_fee,real_point_fee,received_payment,commission_fee,pic_path,num_iid,num_iid,num,price,cod_fee,cod_status,shipping_type,receiver_name,receiver_state,receiver_city,receiver_district,receiver_address,receiver_zip,receiver_mobile,receiver_phone,orders.title,orders.pic_path,orders.price,orders.num,orders.iid,orders.num_iid,orders.sku_id,orders.refund_status,orders.status,orders.oid,orders.total_fee,orders.payment,orders.discount_fee,orders.adjust_fee,orders.sku_properties_name,orders.item_meal_name,orders.buyer_rate,orders.seller_rate,orders.outer_iid,orders.outer_sku_id,orders.refund_id,orders.seller_type';
    
var sign='';
var basicurl = 'http://gw.api.taobao.com/router/rest?';
var app_secret='';
var app_key='';
var format='json';
var method='taobao.trades.sold.get';
var partner_id='top-apitools';
var session='';
var sign_method='md5';
var timestamp= moment().format('YYYY-MM-DD HH:mm:ss'); 
var v='2.0';  

function fetchsheet(sheetIndex,storeArray){
  $.ajax({
        url: "http://localhost:9200/kd/sheet/" + sheetIndex,
        dataType: 'json',
        async: false,
        data: {},
        success: function(data) {
//          console.log( "getjson success" );
         if ( nowDay === Number(data._source.date)) {
          data._source._id=sheetIndex;
          storeArray.push(data._source);
         }
        }
    });
}
 
function fetchItem(storeIndex){
 

 console.log(timestamp);   
    
 
    
 function setstore(storeindex){   //1.yaojiao制皂 2.yaojiao店铺 3.古铺良品 4.厦门富丽手工皂
   switch (storeindex){
           case 1:
       app_key    = yaojiaozhizao.app_key;
       app_secret =yaojiaozhizao.app_secret;
       session    = yaojiaozhizao.session;
       break;     
            case 2:
       app_key    = yaojiaodianpu.app_key;
       app_secret =yaojiaodianpu.app_secret;
       session    = yaojiaodianpu.session;
       break;
            case 3:
       app_key    = gupuliangpin.app_key;
       app_secret =gupuliangpin.app_secret;
       session    = gupuliangpin.session;
       break;
            case 4:
       app_key    = xiamenfulishougongzao.app_key;
       app_secret =xiamenfulishougongzao.app_secret;
       session    = xiamenfulishougongzao.session;
       break;       
       
     default:
       break;
 } 
}
    setstore(storeIndex);   
//  session = 'fsdfsdfds';
//     app_secret='fdsfdsfd';
  
 var formatstr = app_secret + 'app_key' + app_key + 'fields' + fields + 'format' + format + 'method' + method + 'partner_id' + partner_id + 'session' + session + 'sign_method' + sign_method + 'timestamp' + timestamp + 'v' + v + app_secret;
     
    console.log(formatstr);
    
  var md5sign = md5(formatstr);
    
    console.log(md5sign);
   
var solditemAPI = basicurl + 'sign=' + md5sign.toUpperCase() + '&app_key=' + app_key + '&fields=' + fields + '&format=' + format + '&method=' + method + '&partner_id=' + partner_id + '&session=' + session + '&sign_method=' +sign_method + '&timestamp=' + timestamp + '&v=' + v ; 
    
   console.log(solditemAPI);
     
  $.ajax({
     url: solditemAPI,
     dataType: 'json',
     async: false,
     success : function(data){
       console.log('ajax success');
       me = data;
       if (data.error_response !== undefined)
       requireSession();
       else{
    tradeel = data.trades_sold_get_response.trades.trade;
      storeArray= [];
      for (var j = tradeel.length - 1,i=0; i<=j; i++) {
        xhrwrapper(tradeel[i]);
        tradeel[i]._id = i + 1;
        storeArray.push(tradeel[i]);
   }
        console.log(storeArray);
       }
       data = JSON.stringify(data);
//        console.log(data);
     }
 });

    function requireSession(){
      sessionhandle.set('sessioninvalid',true);
      console.log('session invalid!!!!');
    }   
   
  function xhrwrapper(xhr){ 
    me = xhr;
    xhr.name    = xhr.receiver_name;
    xhr.phone   = xhr.receiver_mobile + ' ' +(xhr.receiver_phone?xhr.receiver_phone:'');
    xhr.addr    = xhr.receiver_address;
    xhr.product = xhr.orders.order[0].title + ' X' + xhr.orders.order[0].num;
    xhr.buytime = xhr.pay_time;
    console.log(xhr);
  } 
    
//   $.ajax({
//      url: itemAPI,
//      dataType: 'jsonp',
//      cache: true,
//      jsonp: false,
   
//      error : function(data){
//        console.log('success');
//        console.log(this.data);
//      } 
//  });
}

App = Ember.Application.create();

App.Router.map(function () {
     this.resource("index", {path : "/"});
    });


// App.SessionstatusController = Ember.ObjectController.extend({
//  isSessionvalidBinding: 'App.IndexController.sessionvalid',
//   actions:{
//     setsessionvalid : function (status){ 
//       this.set('isSessionvalid',false);
//       console.log('call to action');
//       console.log(this.isSessionvalid);
//     } 
//   }
// });

    App.IndexRoute = Ember.Route.extend({
     init: function  () {
      console.log('IndexRoute init');
     },

     model : function (params) {
      getTotal=40;
      nowDay=new Date().getDate();
      console.log('IndexRoute model');
      for (var i = 1 ; i <= getTotal; i++) {         //noprotect
    fetchsheet(i,storeArray);
      }
      return storeArray;
     },
     actions: {
      autoSelectCompany: function  (product) {
       if ( (product.indexOf('古铺'))+1 ) {
        $('.send-comp').text('厦门     古铺®');
       }
       else{
        $('.send-comp').text('厦门     YaoJiao®');
       }       
      }
     }
    });

    App.IndexController = Ember.ArrayController.extend({
     needs: ['fillinfo','sessionstatus','getsession'],
     selectedCompanyObjectInit: true,
     selectedCompanyObject: null,
     selectedStore:null,
     selectedStoreInit:true,
     isSelecting: false,
     company:'厦门     古铺®',
     sessioninvalid: false,
     init: function  () {
      sessionhandle = this;
      console.log('IndexController init');
     },

     selectedObjectChanged: function() {
      var selectedObject = this.get('selectedObject');
      console.log('selectedObject._id : ' + selectedObject._id);
      this.send('changeTemplate',selectedObject._id);
     }.observes('selectedObject'),

     selectedCompanyObjectChanged: function() {
      var selectedObject = this.get('selectedCompanyObject');
      console.log('selectedCompanyObject._id : ' + selectedObject.id);
      if (this.selectedCompanyObjectInit !== true) 
       {this.set('isSelecting',false);}
      else
       {this.selectedCompanyObjectInit = false;}
      this.set('company',selectedObject.companyName);
     }.observes('selectedCompanyObject'),

     selectedStoreChanged: function() {
        var selectedObject = this.get('selectedStore');
        console.log('selectedCompany._id : ' + selectedObject.id);
       if (this.selectedStoreInit === false)
         {
       sessionhandle.set('sessioninvalid',false);
       fetchItem(selectedObject.id);
        console.log(this.get('target'));  //access route from controller
           console.log('before set ' + storeArray);
        this.set('model',storeArray);
        this.send('changeTemplate',1);  //set default name to 1
         __storeindex = selectedObject.id; //save global storeindex state
           this.get('controllers.getsession').set('getsessionpage','https://oauth.taobao.com/authorize?response_type=token&client_id=' + app_key);  //set iframe  get session page
       
         }
  
     }.observes('selectedStore'),
      
   actions:{  
     
     refreshpage: function funcName(){ 
       window.location.reload();
     } ,
    printpage: function funcName(){ 
       window.print();
     } ,
     
     clickselectstore: function funcName(){ 
       this.set('selectedStoreInit',false);
     } ,
     cancleselectstore: function (){
       sessionhandle.set('sessioninvalid',false);
   },           
      selecting:function  () {
       console.log('selecting company now!');
       this.set('isSelecting',true);
      },

      changeTemplate: function(selection) {
       console.log('call changeTemplate');
       selectionData = storeArray[selection-1];
       console.log('changemodel' );
       var newmodel = this.get('controllers.fillinfo').get('model').toArray();

       newmodel[newmodel.findBy('class','send-address').id-1].fillText   = selectionData.product;
       newmodel[newmodel.findBy('class','recive-name').id-1].fillText    = selectionData.name;
       newmodel[newmodel.findBy('class','recive-address').id-1].fillText = selectionData.addr;
       newmodel[newmodel.findBy('class','recive-phone').id-1].fillText   = selectionData.phone;

       this.get('controllers.fillinfo').set('model',newmodel);
       console.log('New fillText: ' + newmodel);
     // fillTextModel = AppFillinfoController.model;
     // fillTextModel.findBy("class","send-address").fillText    = selectionData.product;    
     // fillTextModel.findBy("class","recive-name").fillText     = selectionData.name;        
     // fillTextModel.findBy("class","recive-address").fillText  = selectionData.addr;      
     // fillTextModel.findBy("class","recive-phone").fillText    = selectionData.phone;      
     this.send('autoSelectCompany',selectionData.product);
    }
   }
  });
    AppIndexController = App.IndexController.create();

    App.CompanyController = Ember.ArrayController.create({
     isSelectingBinding: 'App.IndexController.isSelecting',
     content: [
     {id:1, companyName:'厦门     古铺®'},
     {id:2, companyName:'厦门     YaoJiao®'}
     ]
    });

    App.StoreController = Ember.ArrayController.create({
   selectedStoreBinding:'App.IndexController.selectedStore',
     content: [
     {id:1, storeName:'YaoJiao制皂'},
     {id:2, storeName:'YaoJiao店铺'},
     {id:3, storeName:'古铺良品'},
     {id:4, storeName:'厦门富丽手工皂'}
     ]
});


    App.SelectView = Ember.Select.extend({    
     didInsertElement: function() {
      console.log('selection focus');
      this.$().focus();
     },

     focusOut: function () {
      this.set('isSelecting',false);
      console.log('selection focus-out');
     }  
    });
    // App.selectedCompany = Ember.Object.create({
    //   CompanyBinding: 'App.IndexController.selectedCompanyObject'
    // });

    App.FillinfoController = Ember.ArrayController.extend({
     model:[
     {id:1, class: 'send-address', fillText: 'sendAddress'},
     {id:2, class: 'recive-name', fillText: 'reciveName'},
     {id:3, class: 'recive-address', fillText: 'reciveAddress'},
     {id:4, class: 'recive-phone', fillText: 'recivePhone'}       
     ]
    });

    App.EditController = Ember.ObjectController.extend({
     actions: {
      editText: function () {
       console.log('EditController editText');
       this.set('isEditing', true);
      },
      acceptChanges: function () {
       console.log('EditController acceptChanges');
       this.set('isEditing', false);
      }
     },
     isEditing: false
    });

    App.GetsessionController = Ember.ArrayController.extend({
     getsessionpage: 'ddddddddddddddddd',
     yoursessionkey:'yourSessionKey', 
     actions: {
      setsession: function () {
       var yoursessionkey = this.get('yoursessionkey');
       console.log('Your input SessionKey:'  + yoursessionkey);
      sessionhandle.set('sessioninvalid',false);
        
      switch (__storeindex){
           case 1:
       yaojiaozhizao.session          = yoursessionkey;
       break;     
            case 2:
       yaojiaodianpu.session          = yoursessionkey;
       break;
            case 3:
       gupuliangpin.session           = yoursessionkey;
       break;
            case 4:
       xiamenfulishougongzao.session  = yoursessionkey;
       break;       
       
     default:
       break;
 }
      fetchItem(__storeindex);
     this.get('controllers.index').send('changeTemplate',1); 
      }
} 
   });


    App.EditTextView = Ember.TextField.extend({
     didInsertElement: function () {
      this.$().focus();
     }
    });

    Ember.Handlebars.helper('edit-text', App.EditTextView);







































// describe('Array1', function(){
//   describe('#indexOf()', function(){
//     it('should return -1 when the value is not present', function(){
//       [1,2,3].indexOf(5).should.equal(-1);
//       [1,2,3].indexOf(0).should.equal(-1);
//     });
//   });
// });
    
//         describe('Array2', function(){
//   describe('#indexOf()', function(){
//     it('should return -1 when the value is not present', function(){
//       [1,2,3].indexOf(5).should.equal(-1);
//       [1,2,3].indexOf(0).should.equal(-1);
//     });
//   });
// });
        
//             describe('Array3', function(){
//   describe('#indexOf()', function(){
//     it('should return -1 when the value is not present', function(){
//       [1,2,3].indexOf(5).should.equal(-1);
//       [1,2,3].indexOf(0).should.equal(-1);
//     });
//   });
// });









  //       App.ContentComponentsComponent = Ember.Component.extend({

  //    sendAddress: 'sendAddress',
  //    reciveName: 'reciveName',
  //    reciveAddress: 'reciveAddress',
  //    recivePhone: 'recivePhone',

  //    startCounter: function() {
  //     dynamicContent =  this;
  //   }.on('didInsertElement')
  // });


   //      Ember.Handlebars.helper('editable', function() {
   //   console.log('call editable helper');
   //   $('document').ready(function () {
   //    $(".send-comp").editable(function(value, settings) { 
   //     console.log(this);
   //     console.log(value);
   //     console.log(settings);
   //     return(value);
   //   }, {
   //     data : "{'厦门     YaoJiao®':'厦门     YaoJiao®','厦门     古铺®':'厦门     古铺®'}",
   //     type   : "select",
   //     submit : "OK",
   //     style  : "inherit",
   //     onblur  : "submit"
   //   });

   //    $("[class^=send]").editable(function(value, settings) { 
   //     console.log(this);
   //     console.log(value);
   //     console.log(settings);
   //     return(value);
   //   }, { 
   //     onblur  : 'submit',
   //   });

   //    $("[class^=recive]").editable(function(value, settings) { 
   //     console.log(this);
   //     console.log(value);
   //     console.log(settings);
   //     return(value);
   //   }, {
   //     onblur  : "submit",
   //   });  
   //  });
   // });

