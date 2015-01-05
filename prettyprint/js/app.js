// (function getjson () {
// 	for (var i = 1 ; i <= getTotal; i++) {
// 		$.ajax({
// 			url: "http://localhost:9200/kd/sheet/" + i,
// 			dataType: 'json',
// 			async: false,
// 			data: {},
// 			success: function(data) {
// 				console.log( "getjson success" );
// 				if ( nowDay === Number(data._source.date)) {
// 					dataArray.push(data._source);
// 					$('.custom-dropdown select').append("<option value=" + dataIndex + ">" + data._source.name+ "</option>");
// 					dataIndex++;
// 				}
// 			}
// 		});
// 	};
// 	$('.custom-dropdown select').click(function(){populateData(dataArray[$(this).val()-1]); });


// // 		request = new XMLHttpRequest();
// // 		request.open('GET', 'http://localhost:9200/kd/sheet/' + i, true);

// // 		request.onreadystatechange = function() {
// // 			if (this.readyState === 4){
// // 				if (this.status >= 200 && this.status < 400){
// //       // Success!
// //       data = JSON.parse(this.responseText);
// //       // console.log(data);
// //       if ( nowDay === Number(data._source.date)) {
// //       	dataArray.push(data._source);
// //       	$('.custom-dropdown select').append("<option value=" + dataIndex + ">" + data._source.name+ "</option>");
// //       	$('.custom-dropdown select').click(function(){populateData(dataArray[$(this).val()-1]); });
// //       	dataIndex++;
// //       }
// //   } else {
// //       // Error :(
// //   }
// // }
// // };
// // request.send();
// // // request = null;

// })();


// function populateData(data) {
// 	$('.send-address').text(data.product);
// 	$('.recive-name').text(data.name);
// 	$('.recive-address').text(data.addr);
// 	$('.recive-phone').text(data.phone);
// 	selectCompany(data.product);
// }


// function selectCompany (product) {
// 	 if ( (product.indexOf('古铺'))+1 ) {
// 	 	$('.send-comp').text('厦门     古铺®');
// 	 }
// 	 else{
// 	 	$('.send-comp').text('厦门     YaoJiao®');
// 	 }
// }



// (function editable() {

// 	$(".send-comp").editable(function(value, settings) { 
// 		console.log(this);
// 		console.log(value);
// 		console.log(settings);
// 		return(value);
// 	}, {
// 		data : "{'厦门     YaoJiao®':'厦门     YaoJiao®','厦门     古铺®':'厦门     古铺®'}",
// 		type   : "select",
// 		submit : "OK",
// 		style  : "inherit",
// 		onblur  : "submit"
// 	});

// 	$("[class^=send]").editable(function(value, settings) { 
// 		console.log(this);
// 		console.log(value);
// 		console.log(settings);
// 		return(value);
// 	}, { 
// 		onblur  : 'submit',
// 	});

// 	$("[class^=recive]").editable(function(value, settings) { 
// 		console.log(this);
// 		console.log(value);
// 		console.log(settings);
// 		return(value);
// 	}, {
// 		onblur  : "submit",
// 	});

// })();
