CKEDITOR.editorConfig=function(e){e.language="fr",e.height=1e3,e.filebrowserBrowseUrl="/ckeditor/attachment_files",e.filebrowserFlashBrowseUrl="/ckeditor/attachment_files",e.filebrowserFlashUploadUrl="/ckeditor/attachment_files",e.filebrowserImageBrowseLinkUrl="/ckeditor/pictures",e.filebrowserImageBrowseUrl="/ckeditor/pictures",e.filebrowserImageUploadUrl="/ckeditor/pictures",e.filebrowserUploadUrl="/ckeditor/attachment_files",e.filebrowserParams=function(){for(var e,r,t,o=document.getElementsByTagName("meta"),i=new Object,a=0;a<o.length;a++)switch(t=o[a],t.name){case"csrf-token":e=t.content;break;case"csrf-param":r=t.content;break;default:continue}return void 0!==r&&void 0!==e&&(i[r]=e),i},e.addQueryString=function(e,r){var t=[];if(!r)return e;for(var o in r)t.push(o+"="+encodeURIComponent(r[o]));return e+(-1!=e.indexOf("?")?"&":"?")+t.join("&")},CKEDITOR.on("dialogDefinition",function(r){var t,o,i=r.data.name,a=r.data.definition;CKEDITOR.tools.indexOf(["link","image","attachment","flash"],i)>-1&&(t=a.getContents("Upload")||a.getContents("upload"),o=null==t?null:t.get("upload"),o&&o.filebrowser&&void 0===o.filebrowser.params&&(o.filebrowser.params=e.filebrowserParams(),o.action=e.addQueryString(o.action,o.filebrowser.params)))}),e.toolbar=[["Undo","Redo"],["Bold","Italic","Underline","Strike","-","RemoveFormat"],["NumberedList","BulletedList","-","Outdent","Indent","-","Blockquote","-","JustifyLeft","JustifyCenter","JustifyRight","JustifyBlock"],"/",["Link","Unlink","Anchor"],["Image","Table","HorizontalRule"],["Styles","Format"],["TextColor","BGColor"],["Source"]]};