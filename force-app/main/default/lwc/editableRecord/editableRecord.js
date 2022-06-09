import { LightningElement, api } from 'lwc';
import updateTaskStatus from '@salesforce/apex/LoadedServiceHours.updateTaskStatus'
import { ShowToastEvent } from "lightning/platformShowToastEvent";

export default class EditableRecord extends LightningElement {
@api typeAttributes;
@api status;
@api newHours;

newStatus

handleUpdate(){
    console.log('typeAttributes', this.typeAttributes )
    console.log('currentStatus.......', this.status )


    if(this.status == 'In Progress'){
        this.newStatus = "Completed"
        //console.log("if --->", this.newStatus);
    }else if(this.status == 'Not Started'){
        this.newStatus = "In Progress"
       // console.log("if --->", this.newStatus);
    }
        
    updateTaskStatus({taskId: this.typeAttributes.taskId , newStatus: this.newStatus})
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
    // console.log('Current status.......', this.currentStatus )
   
   
}

handleTest(){
    console.log('entro al handleTest' , ' el que debe hacer el wire');
    // console.log('newHours es -->', this.newHours);
    // return this.dispatchEvent(new CustomEvent('addHours', {
    //     composed: true,
    //     bubbles: true
    // }));
}


}