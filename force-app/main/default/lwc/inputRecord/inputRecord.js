import { LightningElement,api, track } from 'lwc';
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import addTaskRecordHours from '@salesforce/apex/LoadedServiceHours.addTaskRecordHours'

export default class InputRecord extends LightningElement {
    @api typeAttributes;
    @track
    hours = 0

    handlesaveHours(event){
        let idButton = (JSON.parse(JSON.stringify( this.typeAttributes )).taskId);
        // let idInput = this.template.querySelector('lightning-input')
        // let idInput = this.template.querySelector(`lightning-input[input-id=${idButton}]`)
        console.log('no entro al if')
        console.log('idButton', idButton);
        console.log('this.hours  es ', this.hours)
        if(this.hours > 0){
           console.log('es mayor a cero')
           addTaskRecordHours({taskId: idButton , numberHours: this.hours})
            .then((res) => {
                    console.log("res es --->", res);
                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: "Success",
                            message: res,
                            variant: "success"
                        })
                    );
                    // this.fldsItemValues = [];
                    // this.change += 1;
                    //  return this.refresh();
                return this.dispatchEvent(new CustomEvent('refresh', {
                    composed: true,
                    bubbles: true
                }));
            
            })
            .catch((error) => {
                console.log(error);
                this.dispatchEvent(
                new ShowToastEvent({
                    title: "Error",
                    message: "error ms",
                    // message:
                    //   "Ups, An Error Occured!! " + error.body.pageErrors[0].message,
                    variant: "error"
                })
                );
            })


        }else{
            console.log('error') 
            this.dispatchEvent(
                new ShowToastEvent({
                  title: "Warning",
                   message: "you must fill in the field 'Add Hours'",
                  // message:
                  //   "Ups, An Error Occured!! " + error.body.pageErrors[0].message,
                  variant: "warning"
                })
              );
        }

    }

    
    handleInpuntChange(event){
        console.log('algo cambio ', event.target.value);
        console.log('desde iputRecord ', JSON.parse(JSON.stringify( this.typeAttributes )))
        this.hours = parseInt( event.target.value);
        // console.log('this.hours  es ', this.hours)

        return this.dispatchEvent(new CustomEvent('inputChange', {
            detail: {horas: 'horas texto'},
        composed: true,
        bubbles: true,
    }));
    }
}