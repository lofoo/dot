var me,you,he,she;
String.prototype.trim=function(){return this.replace(/^\s+|\s+$/g, '');};
String.prototype.ltrim=function(){return this.replace(/^\s+/,'');};
String.prototype.rtrim=function(){return this.replace(/\s+$/,'');};
String.prototype.fulltrim=function(){return this.replace(/(?:(?:^|\n)\s+|\s+(?:$|\n))/g,'').replace(/\s+/g,' ');};


App = Ember.Application.create({
  dburl: 'http://192.168.1.101:9200',
  isDebug: true,
  isMockjax: true,
  searchstr: '',
  searching: false,
  highlighting: true,
  allRecord: [],
});


App.Router.map(function() {
  // put your routes here
});


App.SearchElasticComponent = Ember.Component.extend({
  needs: ['index'],
  size: 200,
  search: '',
  isShowAll: false,
  isHighlight: true,
  page:1,
  perPage: 5,

  actions: {
    highlight: function() {
      if ( this.get('isHighlight') === true)
      {
        Ember.set('App.searching', false)
        Ember.set('App.highlighting', false)
      }
      else
      {
        Ember.set('App.searching', true)
        Ember.set('App.highlighting', true)
      }
      this.toggleProperty('isHighlight')
    },

    showAll: function() {
      var self = this
      var isShowAll = this.get('isShowAll')
      if ( isShowAll === false) 
      {
        this.set('search', '')
        this.set('isShowAll', true)
        self.sendAction('stillmore')
      }
      else
        this.set('isShowAll', false)
    }
  },

  showAllChanged: function  () {
    var self = this;
    var isShowAll = this.get('isShowAll')

    if ( isShowAll === true) {
      $.when(App.Doc.findAll()).then(function(data){
        App.Doc.searchRecord.setObjects([])

        var allRecord = jQuery.extend(true, {}, data);
        self.sendAction('setAllRecord', allRecord)

        var perPage =  self.get('perPage')
        data.hits.hits = data.hits.hits.slice(0,perPage)
        App.Doc.searchRecord.pushObject(data)
        Ember.set('App.Doc.isLoaded', true)
      });
    } else{
      App.Doc.searchRecord.setObjects([])
      Ember.set('App.Doc.isLoaded', false)
    }
  }.observes('isShowAll'),

  queryElastic: function() {
    // console.log(this.$())
    var search = this.get('search')
    this.sendAction('cancleEdit')
    this.sendAction('cancleCreate')
    Ember.set('App.searchstr', search)

    if ( App.highlighting === false && App.searching === false)
    {
    }
    else {
      Ember.set('App.searching', true)
    }

    if ( search === '' || search === undefined)
    {
      Ember.set('App.Doc.isLoaded', false)
      Ember.set('App.searching', false)
      this.set('isShowAll', true)
      this.sendAction('stillmore')
      App.Doc.searchRecord.setObjects([])
      return 
    }
    this.set('isShowAll', false)
    this.sendAction('changeQuery',search);
    // console.log('call me maybe: queryElastic');
  }.property('search')

});


App.IndexController = Ember.ArrayController.extend({
  needs: ['edit'],
  searching: '',
  creating: false,
  totalResult: 0,
  noresult: false,
  editing: false,
  editmodel: [],
  allRecord: [],
  page: 1,
  perPage: 5,
  stillmore: false,


  searchChanged: function  () {
    console.log('searchChanged')
  }.observes('search'),


  actions: {

    showmore: function (id) {
      $('[data-id="'  + id + '"] .show-more-button').addClass('hide')
      $('[data-id="'  + id + '"] .show-less-button').removeClass('hide')
      $('[data-id="'  + id + '"] .post-description').removeClass('toolong')
      $('[data-id="'  + id + '"] .morecontent').removeClass('gradbox')

    },

    showless: function (id) {
      $('[data-id="'  + id + '"] .show-more-button').removeClass('hide')
      $('[data-id="'  + id + '"] .show-less-button').addClass('hide')
      $('[data-id="'  + id + '"] .post-description').addClass('toolong')
      $('[data-id="'  + id + '"] .morecontent').addClass('gradbox')

    },

    setQuery: function(query) {
      // this.set('stillmore', true)
      this.set('page', 1)
      var myContext = {query: query, self: this};
      Em.run.debounce(myContext,this.perfQuery, 100);
    },

    createNew: function () {
      var self = this;
      this.toggleProperty('creating')
      // $.when(App.Doc.findAll()).then(function(data){
      //   var totalResult = data.hits.total
      //   self.set('totalResult', totalResult)
      // });
},

cancleEdit: function  () {

  if( this.get('editing') === true)  
  {
   this.toggleProperty('editing')
   console.log('cancle edit')
 }
},

cancleCreate: function  () {   
  if( this.get('creating') === true)  
  {
    this.toggleProperty('creating')
  }
},

delete: function  (id) { 
  this.send('cancleCreate')
  this.send('cancleEdit')
  swal({
    title: "Are you sure?",
    text: "Your will not be able to recover this imaginary file!",
    type: "warning",
    showCancelButton: true,
    confirmButtonColor: "#DD6B55",
    confirmButtonText: "Yes, delete it!",
    closeOnConfirm: false
  }, function() {
    App.Doc.delete(id);
    swal("Deleted!", "Your imaginary file has been deleted.", "success");
    Ember.run.later(function(){$('[data-id="' + id +'"]').remove()},1000)
  });
},

editPost: function  (title, url, content, id) {
  this.send('cancleCreate')

  $('html, body').animate({scrollTop : 0},500);
  this.set('editing', true)
  
  content = content.replace(/<br\s*\/>/gi, '\n')
  this.set('editmodel',[ {'title': title, 'url': url, 'content': content, 'id': id}] )

  var editcontent  = content
  console.log(title,url,content,id);
  if (editcontent !== '' || editcontent !== undefined)
   editcontent     = editcontent.replace(/\r?\n/g, '<br/>');

 var newSearchRecord = App.Doc.searchRecord[0].hits.hits
 newSearchRecord = _.remove(newSearchRecord, function(post) { return post._id !==  id })

 App.Doc.searchRecord[0].hits.hits = newSearchRecord
 App.Doc.pushRecord(title, url, editcontent, id)


},

createPost: function  () {
 var title      = this.get('title')
 var url        = this.get('url') 
 var newContent = this.get('newContent') 
 if (newContent !== '' || newContent !== undefined)
   newContent     = newContent.replace(/\r?\n/g, '<br/>');
       // console.log( 'title: ' + title, 'url: ' + url, 'newContent: ' + newContent)

       var saveobj = { content: newContent, title: title, url: url}
       // var totalResult = this.get('totalResult')
       var id = ""
       $.when(App.Doc.save( JSON.stringify(saveobj))).then(function(msg){
         id = msg._id
       });

       this.toggleProperty('creating')
       this.set('title','')
       this.set('url','')
       this.set('newContent','')

       App.Doc.pushRecord(title, url, newContent, id)
     },

     setAllRecord: function  (allRecord) {
      console.log(allRecord)
      this.set('allRecord', allRecord)
    },

    stillmore: function  () {
      this.set('stillmore', true)
    }


  },


  perfQuery: function  () {
    var self = this.self;
    var perPage = self.get('perPage')
    self.set('noresult', false)

    $.when( App.Doc.search(this.query) ).then(function(data){
      App.Doc.searchRecord.setObjects([])
      var allRecord = jQuery.extend(true, {}, data);
      self.set('allRecord', allRecord)

      var perPage =  self.get('perPage')
      data.hits.hits = data.hits.hits.slice(0,perPage)
      App.Doc.searchRecord.pushObject(data)
      console.log('total result:' + data.hits.total)
      
      if ( data.hits.total <= perPage)
        self.set('stillmore', false)
      else
        self.set('stillmore', true)

      if ( data.hits.total === 0)
      {
        Ember.set('App.Doc.isLoaded', false)
        console.log('should true')
        self.set('noresult', true)
      }
      else
        Ember.set('App.Doc.isLoaded', true)
    });

    console.log('you are search: ' + this.query)
  },

  gotMore: function( page ) {
    this.set('loadingMore', false);
    this.set('page', page);
  }

});



App.EditController = Ember.ArrayController.extend({
  needs: ['index'],
  editmodel: Ember.computed.alias('controllers.index.editmodel'),
  editing:   Ember.computed.alias('controllers.index.editing'),

  fillEdit: function() {
    var editmodel = this.get('editmodel')
    this.set('title',editmodel[0].title)
    this.set('url',editmodel[0].url)
    this.set('id',editmodel[0].id)
    this.set('editcontent',editmodel[0].content)
  }.observes('editmodel').on('init'),

  updateEdit: function () {
  }.observes('title', 'url', 'editcontent').on('init'),

  actions: {

   submitEdit: function (id) {

     var title        = this.get('title')
     var url          = this.get('url') 
     var id           = this.get('id') 
     var editcontent  = this.get('editcontent') 
     if (editcontent !== '' || editcontent !== undefined)
       editcontent     = editcontent.replace(/\r?\n/g, '<br/>');
     var saveobj = { content: editcontent, title: title, url: url}

     var res = ""
     $.when(App.Doc.update( id, JSON.stringify(saveobj))).then(function(msg){
       res = msg
     });

     this.toggleProperty('editing')
     var newSearchRecord = App.Doc.searchRecord[0].hits.hits
     newSearchRecord = _.remove(newSearchRecord, function(post) { return post._id !==  id })

     App.Doc.searchRecord[0].hits.hits = newSearchRecord
     App.Doc.pushRecord(title, url, editcontent, id)

   },

   cancleEdit: function () {
     this.toggleProperty('editing')
   }

 }

});



App.RL = Ember.Object.extend({
 isLoaded:   false,
 isError:    false,
 isDirty:    false,
 isNew:      false,
 isSaving:   false,
 isDeleting: false,
 searchRecord: [],

 prefix: function  () {
   return Path.join(this.url,this.namespace)
 },

 find: function (type,id) {
  var joinurl = Path.join(this.prefix(), type, id );
  $.getJSON( joinurl ).then(function(data) {
    console.info('App.RL find --> ' + joinurl);
    console.info(data)
    console.info('App.RL find --> ' + joinurl);
    console.log('\n')
    return data
  });
},

findAll: function () {
  var joinurl = Path.join(this.prefix(),"_search?size=1000");
  return $.getJSON( joinurl ).then(function(data) {
    console.info('App.RL findAll --> ' + joinurl);
    console.info('App.RL findAll --> ' + joinurl);
    console.log('\n')
    return data
  });
},

search: function  (query) {
  var result = ''
  var self = this;
  this.isLoaded = false;
  var postobj =   {
    "from" : 0,
    "size" : 100,
    "query": {
      "multi_match": {
       "fields": [ "title", "content", "url" ],
       "phrase" : {
         "query": "PutQueryHere",
         "operator": "and"
       }
     }
   }
 }

 var poststr = JSON.stringify(postobj);

 query = query.replace(/\\/g,'\\\\');
 query = query.replace('"','\\"');
 query = query.replace('.','\\\\.');
 poststr = poststr.replace(/PutQueryHere/,query);

 var joinurl = Path.join(this.prefix(), "_search" );
 var request = $.ajax({
  type: "POST",
  url: joinurl,
  async: false,
  data: poststr
});

 console.log('\n')

 request.done(function( data ) {
  self.set('isLoaded', true);
  console.info('App.RL search --> ' + joinurl);
  console.info( 'search successful' );
  console.info('App.RL search --> ' + joinurl);
  console.log('\n')

  result = data

  // var searchRecord =  self.get('searchRecord')
  // searchRecord.setObjects([])
  // searchRecord.pushObject(data)
});

 request.fail(function( jqXHR, textStatus ) {
  console.error('App.RL search --> ' + joinurl);
  sweetAlert("search failed: " + textStatus );
  console.error('App.RL search --> ' + joinurl);
  console.log('\n')
});
 return result
},

save: function ( data) {
  this.isSaving = true;
  var result="";

  var joinurl = Path.join(this.prefix());
  var request = $.ajax({
    type: "POST",
    url: joinurl,
    async: false,
    data: data
  });
  
  console.log('\n')

  request.done(function( msg ) {
    this.isSaving = false;
    console.info('App.RL save --> ' + joinurl);
    console.info( 'save successful' );
    console.info('App.RL save --> ' + joinurl);
    console.log('\n')
    result = msg
  });

  request.fail(function( jqXHR, textStatus ) {
    this.isError  = true;
    this.isSaving = false;
    console.error('App.RL save --> ' + joinurl);
    sweetAlert("Save failed: " + textStatus );
    console.error('App.RL save --> ' + joinurl);
    console.log('\n')
  });
  return result
},

update: function ( id, data) {
  this.isSaving = true;
  var result="";

  var joinurl = Path.join(this.prefix(), id);
  var request = $.ajax({
    type: "PUT",
    url: joinurl,
    async: false,
    data: data
  });
  
  console.log('\n')

  request.done(function( msg ) {
    this.isSaving = false;
    console.info('App.RL update --> ' + joinurl);
    console.info( 'update successful' );
    console.info('App.RL update --> ' + joinurl);
    console.log('\n')
    result = msg
  });

  request.fail(function( jqXHR, textStatus ) {
    this.isError  = true;
    this.isSaving = false;
    console.error('App.RL update --> ' + joinurl);
    sweetAlert("update failed: " + textStatus );
    console.error('App.RL update --> ' + joinurl);
    console.log('\n')
  });
  return result
},


delete: function  (id) {
  this.isDeleting = true;
  var joinurl = Path.join(this.prefix(), id );
  var request = $.ajax({
    type: "DELETE",
    url: joinurl
  });
  console.log('\n')

  request.done(function( msg ) {
    this.isDeleting = false;
    console.info('App.RL delete --> ' + joinurl);
    console.info( 'delete successful' );
    console.info('App.RL delete --> ' + joinurl);
    console.log('\n')
  });

  request.fail(function( jqXHR, textStatus ) {
    this.isDeleting = false;
    this.isError  = true;
    console.error('App.RL delete --> ' + joinurl);
    sweetAlert("delete failed: " + textStatus );
    console.error('App.RL delete --> ' + joinurl);
    console.log('\n')
  });

},

pushRecord: function  (title, url, newContent, id) {
 var swap = App.Doc.searchRecord[0].hits.hits

 if (swap.length === 0)
 {
  var newRecord = {'_source':  {}  } 
}
else
 var newRecord = jQuery.extend(true, {}, swap[0])
newRecord._source['title']         =  title  
newRecord._source['url']           =  url
newRecord._source['content']       =  newContent
newRecord['_id']                   =  id
swap.unshift(newRecord)

swap2 = []
swap2.push({})
swap2[0]["hits"]=[]
swap2[0]["hits"]["hits"] = swap

Ember.set('App.Doc.searchRecord', swap2)

}

});



Path =  Ember.Object.create({
 join: function () {
  var result = '';
  for (var i = 0; i < arguments.length; i++) {
    if ( arguments[i] !== '')
    {
      if ( i!== 0 )
        result+= '/' +  arguments[i];
      else
        result += arguments[i];
    }
  }
  // console.log('Path.join --> ' + result)
  return result;
}
});

App.isMockjax = false

if (App.isMockjax)
{
  $.mockjax({
    url: App.dburl + '/testdata/docs/1',
    dataType: 'json',
    responseTime: 10,
    responseText: {"_index":"testdata","_type":"docs","_id":"1","_version":1,"found":true,"_source":{ "phrase" : "R&Blilly  MONITOR-how SCHULTE Apnea How也许如果206 Mon600itor 700 event.node $.cheerio", "product": "化痰止咳冲我剂" , "url": "http://tjholow_1"}}
  });

  $.mockjax({
    url: App.dburl + '/testdata/docs/_search',
    dataType: 'json',
    responseTime: 10,
    responseText: {"took" : 0, "timed_out" : false, "_shards" : {"total" : 5, "successful" : 5, "failed" : 0 }, "hits" : {"total" : 2, "max_score" : 1.0, "hits" : [ {"_index" : "testdata", "_type" : "docs", "_id" : "1", "_score" : 1.0, "_source":{ "phrase" : "R&Blilly  MONITOR-how SCHULTE Apnea How也许如果206 Mon600itor 700 event.node $.cheerio", "product": "化痰止咳冲我剂" , "url": "http://tjholow_1"} }, {"_index" : "testdata", "_type" : "docs", "_id" : "2", "_score" : 1.0, "_source":{ "phrase" : "APNEA MONITOR- SCHULTE Apnea Monitor, Neonatal", "product" :  "no玉屏风口服我液awesome" , "url": "http://tjholow_2"} } ] } }
  });
}



App.Doc = App.RL.create({
  url: App.dburl,
  namespace: 'testdata/docs'
});



App.IndexRoute = Ember.Route.extend({

  fetchPage: function(page, perPage) {
    var controller = this.get('controller')
    console.log('fetchpage')
    var items = Em.A([]);
    var firstIndex = (page-1) * perPage;
    var lastIndex  = page * perPage;

    var allRecord = controller.get('allRecord')
    if( firstIndex >= allRecord.hits.total )
    {
      controller.set('stillmore', false)
      return
    }
    var nextRecord = jQuery.extend(true, {}, allRecord);
    nextRecord.hits.hits = nextRecord.hits.hits.slice(0,lastIndex)

    
    items.push(nextRecord)
    Ember.set('App.Doc.searchRecord', items)
    Ember.set('App.Doc.isLoaded', true)

  },

  actions: {
    getMore: function() {
      console.log('getMore')
      var controller = this.get('controller'),
      nextPage = controller.get('page') + 1,
      perPage = controller.get('perPage')

      this.fetchPage(nextPage, perPage);
      controller.gotMore(nextPage);
    }
  },

  model: function() {
    // App.Doc.find('docs',1);
    // App.Doc.findAll('docs');
    // App.Doc.search('Neonata');
    // App.Doc.save('docs',3, '{ content: "John", title: "Boston", url: "This Url"}');
    // App.Doc.delete('docs',3);
  }
});

App.IndexView = Ember.View.extend({
  didInsertElement: function(){
    $(window).on('scroll', $.proxy(this.didScroll, this));
  },

  willDestroyElement: function(){
    $(window).off('scroll', $.proxy(this.didScroll, this));
  },

  didScroll: function(){
    if (this.isScrolledToBottom()) {
        // this.get('controller').send('getMore');
        console.log('didScroll')
      }
    },

    isScrolledToBottom: function(){
      var distanceToViewportTop = (
        $(document).height() - $(window).height());
      var viewPortTop = $(document).scrollTop();

      if (viewPortTop === 0) {
        return false;
      }

      return (viewPortTop - distanceToViewportTop === 0);
    }
  });



Ember.Handlebars.registerHelper('highlight', function( title, url, content, options) {
  // var escaped = Handlebars.Utils.escapeExpression(str);
  // return new Ember.Handlebars.SafeString('<em class="highlight">' + escaped + '</em>');
  if  ( App.highlighting === false )
  {
    var title   =    options.contexts[0]._source.title 
    var url     =    options.contexts[0]._source.url 
    var oriurl  =    options.contexts[0]._source.url 
    var content =    options.contexts[0]._source.content 
    
    var highlightobj = {}    

    highlightobj["title"]    =  title   
    highlightobj["url"]      =  url    
    highlightobj["oriurl"]   =  oriurl    
    highlightobj["content"]  =  content

    return options.fn(highlightobj)
  }

  var searchstr = App.searchstr;
  var token = '-|&|,|\\.|，|。|:'

  var regSearch = new RegExp(token,"gi");

  searchstr = searchstr.replace(regSearch,' ')
  searchstr = searchstr.fulltrim()
  searchstr = searchstr.replace(/ /g,"|")
  console.warn('token: ' + searchstr);

  var reContent = new RegExp('(' + searchstr + ')',"gi");

  var title   =    options.contexts[0]._source.title 
  var url     =    options.contexts[0]._source.url 
  var oriurl  =    options.contexts[0]._source.url 
  var content =    options.contexts[0]._source.content 

  title = title.replace(reContent, '<em class="highlight">$1</em>')
  url = url.replace(reContent, '<em class="highlight">$1</em>')

  content = content.replace(/<br\s*\/>/gi, '؏')
  content = content.replace(reContent, '<em class="highlight">$1</em>')
  content = content.replace(/؏/gi, '<br/>' )

  var highlightobj = {}    

  highlightobj["title"]    =  title   
  highlightobj["url"]      =  url    
  highlightobj["oriurl"]   =  oriurl    
  highlightobj["content"]  =  content

  return options.fn(highlightobj);

});


Ember.Handlebars.registerHelper('addShowMore',function(){
  console.log('call add showmore')
  var el = '[data-id]'

  $('.post:first').waitUntilExists(function(){ 
    $(el).each(function(index,elem) {
      var myContext = { elem: elem }

      Ember.run.later(myContext,function(){
        var height = $(this.elem).height()
        if ( height >= 300)
        {
          me=$(this.elem)
          $(this.elem).children('.show-more-button').removeClass('hide')
          $(this.elem).children('.morecontent').addClass('gradbox')
        }

      },500)

    })

  })

});


// $.getJSON('/testdata/docs/1', function(response) {
//   console.log(response)
// });

// App.IndexRoute = Ember.Route.extend({
//   model: function() {
//     return ['red', 'yellow', 'blue'];
//   }
// });
