import { LightningElement, api } from 'lwc';
import updateTaskStatus from '@salesforce/apex/LoadedServiceHours.updateTaskStatus'
import { ShowToastEvent } from "lightning/platformShowToastEvent";

export default class EditableRecord extends LightningElement {
@api typeAttributes;
@api currentStatus

// taskId=JSON.stringify(typeAttributes.taskId);

handleUpdate(){
    console.log('ENTRO.......', this.currentStatus )

    // const inputsItems = JSON.parse(
    //     this.typeAttributes.slice().map((draft) => {
    //       return draft;
    //     })
    // )
    // console.log('inputs ', inputsItems)

    // if(this.typeAttributes.Status__c == 'In Progress'){
    //     this.newStatus = "Completed"
    //     console.log("if --->", this.newStatus);
    // }else if(this.typeAttributes.Status__c == 'Not Started'){
    //     this.newStatus = "In Progress"
    //     console.log("if --->", this.newStatus);
    // }
        
    updateTaskStatus({taskId: this.typeAttributes.taskId , newStatus: this.typeAttributes.Status__c})
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
        // return this.refresh();
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
    console.log('ENTRO.......', this.typeAttributes )
    console.log('Current status.......', this.currentStatus )

    
}

}