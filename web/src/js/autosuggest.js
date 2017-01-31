class Autosuggest {
  constructor(opt) {
    this.selector = opt.selector , 
    this.source = opt.source ,
    this.data = opt.data || [] ,

    this.data = this.data.sort()
  }

  setKeyUpUpdating(selector) {
    $(selector).keyup(e => {
      var code = (e.keyCode || e.which);
      // do nothing if it's an arrow key or tab or enter
      if (code == 8 || code == 37 || code == 38 || code == 39 || code == 40 || code == 13) {
        return;
      }
      var v = e.target.value
      if (!v) return
      this.updateSuggestion(v)
    })
  }

  updateSuggestion(string) {
    var s = $(this.selector)
    var arr
    $(`${this.selector} option`).remove()

    if (string) {
      arr = _.filter(this.data, (element) => _.includes(element, string) ).slice(0, 5)
    } else {
      arr = this.data.slice(0,5)
    }
    arr.forEach( a =>  s.append(`<option value='${a}'>`) ) 
  }

  updateData(inputSelector){
    fetch(this.source())
      .then(r => r.json())
      .then(r => {
        this.data = r.sort()
        this.updateSuggestion('') 
      })
  }

  updateDataOnChange(selector, target){
    $(selector).change(e => {
      // loader.start()
      fetch(this.source(e.target.value))
        .then(r => r.json())
        .then(r => {
          this.data = r.sort()
          this.updateSuggestion('') 
        })
        // .then(() => loader.end());
    })
  }
}

module.exports = Autosuggest