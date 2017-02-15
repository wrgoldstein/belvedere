exports.event_input = function(ix){
  return $(`
    <div class="form-group" id="form-group-events-${ix}">
      <input type="text" name="events-input-${ix}" 
             list="events" id="events-input-${ix}" 
             class="events-input form-control" value="" 
             placeholder="Event">
      <a href="#" class="close-thik"></a>
    </div>
    `)
}