﻿
function go(template, run) {
    document.forms['f'].run.value=run || document.forms['f'].run.value;
    document.forms['f'].action = template || document.forms['f'].action;
    document.forms['f'].submit();
    return true;
}

function log(stuff)
{
    if( typeof console != 'undefined' )
    {
        console.log(stuff);
    }
}


(function($) {
    function pf_document_ready()
    {
	$('table.markrow input[type="checkbox"]').change(function(){
	    log('Checkbox highlight toggle');
            if ($(this).is(':checked')){
		$(this).parent().addClass('highlighted');
		$(this).parent().siblings().addClass('highlighted');
            } else if($(this).parent().is('.highlighted')) {
		$(this).parent().removeClass('highlighted');
		$(this).parent().siblings().removeClass('highlighted');
            }
	});
    };
    
    
    jQuery(document).ready(pf_document_ready);
}
)(jQuery);

function showhide(whichLayer)
{
    var node2 = document.getElementById(whichLayer);
    $(node2).toggle();
}


log('PF js loaded');