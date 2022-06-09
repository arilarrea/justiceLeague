import { LightningElement,api } from 'lwc';

export default class InputRecord extends LightningElement {
    @api typeAttributes;

    handleInpuntChange(event){
        console.log('algo cambio ', event.target.value);
        let hours = event.target.value;
        return this.dispatchEvent(new CustomEvent('inputChange', {
            detail: {horas: 'horas texto'},
        composed: true,
        bubbles: true,
    }));
    }
}