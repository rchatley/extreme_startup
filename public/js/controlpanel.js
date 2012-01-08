$(document).ready(function() {

	$('#advance').click(function(){
		$.post('/advance_round', function(data) {
		  location.reload();
		});
	});

	$('#pause').click(function(){
 		$.post('/pause', function(data) {
		  location.reload();
		});
	});

	$('#resume').click(function(){
 		$.post('/resume', function(data) {
		  location.reload();
		});
	});
	
});