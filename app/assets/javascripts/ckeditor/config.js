// Copied the whole config file because there is a bug if you only override some config options
// "Browse server" button will not show when adding an image
/*
Copyright (c) 2003-2011, CKSource - Frederico Knabben. All rights reserved.
For licensing, see LICENSE.html or http://ckeditor.com/license
*/

CKEDITOR.editorConfig = function( config ) {
    // Define changes to default configuration here. For example:
    config.language = 'fr';
    config.stylesSet = 'my_styles';
    // config.uiColor = '#AADC6E';
    config.height = 1000;
    /* Filebrowser routes */
    // The location of an external file browser, that should be launched when "Browse Server" button is pressed.
    config.filebrowserBrowseUrl = "/ckeditor/attachment_files";

    // The location of an external file browser, that should be launched when "Browse Server" button is pressed in the Flash dialog.
    config.filebrowserFlashBrowseUrl = "/ckeditor/attachment_files";

    // The location of a script that handles file uploads in the Flash dialog.
    config.filebrowserFlashUploadUrl = "/ckeditor/attachment_files";

    // The location of an external file browser, that should be launched when "Browse Server" button is pressed in the Link tab of Image dialog.
    config.filebrowserImageBrowseLinkUrl = "/ckeditor/pictures";

    // The location of an external file browser, that should be launched when "Browse Server" button is pressed in the Image dialog.
    config.filebrowserImageBrowseUrl = "/ckeditor/pictures";

    // The location of a script that handles file uploads in the Image dialog.
    config.filebrowserImageUploadUrl = "/ckeditor/pictures";

    // The location of a script that handles file uploads.
    config.filebrowserUploadUrl = "/ckeditor/attachment_files";

    // Rails CSRF token
    config.filebrowserParams = function(){
        var csrf_token, csrf_param, meta,
                metas = document.getElementsByTagName('meta'),
                params = new Object();

        for ( var i = 0 ; i < metas.length ; i++ ){
            meta = metas[i];

            switch(meta.name) {
                case "csrf-token":
                    csrf_token = meta.content;
                    break;
                case "csrf-param":
                    csrf_param = meta.content;
                    break;
                default:
                    continue;
            }
        }

        if (csrf_param !== undefined && csrf_token !== undefined) {
            params[csrf_param] = csrf_token;
        }

        return params;
    };

    config.addQueryString = function( url, params ){
        var queryString = [];

        if ( !params ) {
            return url;
        } else {
            for ( var i in params )
                queryString.push( i + "=" + encodeURIComponent( params[ i ] ) );
        }

        return url + ( ( url.indexOf( "?" ) != -1 ) ? "&" : "?" ) + queryString.join( "&" );
    };

    // Integrate Rails CSRF token into file upload dialogs (link, image, attachment and flash)
    CKEDITOR.on( 'dialogDefinition', function( ev ){
        // Take the dialog name and its definition from the event data.
        var dialogName = ev.data.name;
        var dialogDefinition = ev.data.definition;
        var content, upload;

        if (CKEDITOR.tools.indexOf(['link', 'image', 'attachment', 'flash'], dialogName) > -1) {
            content = (dialogDefinition.getContents('Upload') || dialogDefinition.getContents('upload'));
            upload = (content == null ? null : content.get('upload'));

            if (upload && upload.filebrowser && upload.filebrowser['params'] === undefined) {
                upload.filebrowser['params'] = config.filebrowserParams();
                upload.action = config.addQueryString(upload.action, upload.filebrowser['params']);
            }
        }
    });
    config.toolbar = [
         [ 'Undo', 'Redo' ],
         [ 'Bold','Italic','Underline','Strike','-','RemoveFormat' ],
         [ 'NumberedList','BulletedList','-','Outdent','Indent','-','Blockquote', '-','JustifyLeft','JustifyCenter','JustifyRight','JustifyBlock' ],
        '/',
         [ 'Link','Unlink','Anchor' ],
         [ 'Image','Table','HorizontalRule'],
         [ 'Styles','Format' ],
         [ 'TextColor','BGColor' ],
         [ 'Source' ]
    ];
    // config.extraPlugins = 'youtube';
};


CKEDITOR.stylesSet.add( 'my_styles', [
  /* Block Styles */

  // These styles are already available in the "Format" combo ("format" plugin),
  // so they are not needed here by default. You may enable them to avoid
  // placing the "Format" combo in the toolbar, maintaining the same features.
  /*
  { name: 'Paragraph',    element: 'p' },
  { name: 'Heading 1',    element: 'h1' },
  { name: 'Heading 2',    element: 'h2' },
  { name: 'Heading 3',    element: 'h3' },
  { name: 'Heading 4',    element: 'h4' },
  { name: 'Heading 5',    element: 'h5' },
  { name: 'Heading 6',    element: 'h6' },
  { name: 'Preformatted Text',element: 'pre' },
  { name: 'Address',      element: 'address' },
  */

  { name: 'Italic Title',   element: 'h2', styles: { 'font-style': 'italic' } },
  { name: 'Subtitle',     element: 'h3', styles: { 'color': '#aaa', 'font-style': 'italic' } },
  {
    name: 'Légende',
    element: 'div',
    attributes: { class: 'blog-article__legend' }
  },

  /* Inline Styles */

  // These are core styles available as toolbar buttons. You may opt enabling
  // some of them in the Styles combo, removing them from the toolbar.
  // (This requires the "stylescombo" plugin)
  /*
  { name: 'Strong',     element: 'strong', overrides: 'b' },
  { name: 'Emphasis',     element: 'em' , overrides: 'i' },
  { name: 'Underline',    element: 'u' },
  { name: 'Strikethrough',  element: 'strike' },
  { name: 'Subscript',    element: 'sub' },
  { name: 'Superscript',    element: 'sup' },
  */

  { name: 'Marker',     element: 'span', attributes: { 'class': 'marker' } },

  { name: 'Big',        element: 'big' },
  { name: 'Small',      element: 'small' },
  { name: 'Typewriter',   element: 'tt' },

  { name: 'Computer Code',  element: 'code' },
  { name: 'Keyboard Phrase',  element: 'kbd' },
  { name: 'Sample Text',    element: 'samp' },
  { name: 'Variable',     element: 'var' },

  { name: 'Deleted Text',   element: 'del' },
  { name: 'Inserted Text',  element: 'ins' },

  { name: 'Cited Work',   element: 'cite' },
  { name: 'Inline Quotation', element: 'q' },

  { name: 'Language: RTL',  element: 'span', attributes: { 'dir': 'rtl' } },
  { name: 'Language: LTR',  element: 'span', attributes: { 'dir': 'ltr' } },

  /* Object Styles */

  {
    name      : 'Styled image (left)',
    element   : 'img',
    attributes: { 'class': 'left' }
  },

  {
    name: 'Compact table',
    element: 'table',
    attributes: {
      cellpadding: '5',
      cellspacing: '0',
      border: '1',
      bordercolor: '#ccc'
    },
    styles: {
      'border-collapse': 'collapse'
    }
  },

  { name: 'Borderless Table',   element: 'table', styles: { 'border-style': 'hidden', 'background-color': '#E6E6FA' } },
  { name: 'Square Bulleted List', element: 'ul',    styles: { 'list-style-type': 'square' } }
] );
