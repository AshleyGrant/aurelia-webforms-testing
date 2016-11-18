import {inject, TemplatingEngine} from 'aurelia-framework';

@inject(TemplatingEngine)
export class App {
  message = 'Hello World';

  constructor(templatingEngine) {
    this.templatingEngine = templatingEngine;
    // this.viewModelInstance = new window.Button_1();
  }

  attached() {
    let elem = document.querySelector("*[aspx-enhance] button");
    console.log(this.viewModelInstance);
    this.templatingEngine.enhance({element: elem, bindingContext: window.Button_1});
  }
}
