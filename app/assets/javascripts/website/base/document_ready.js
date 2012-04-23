$(document).ready(function() {

	/*
	Bind Input Field Prompts:
	<div class="prompt">
	  <label for="Enter_email">Enter email</label>
	  <input id="login_id" name="login_id" size="30" type="text">
	</div>

	for each .field:
	  on click: set focus to input
	  for the field's input:
	    onFocus: hide the label
	    onBlur: show the label if value.nil?
	*/
  $(".prompt").each (function (idx){
    var label = $(this).find("label");
    var input = $(this).find("input");
    if (input.val() != "") label.addClass("invisible")
    $(this).click(function(srcc){
      input.focus();
    })
    input.focus(function (srcc){
      label.removeClass("invisible") //remove the style so we do not add it 2x
      label.addClass("invisible")    
    })
    input.blur(function (srcc){
      if ($(this).val() == "") label.removeClass("invisible")
    })
  })

});
