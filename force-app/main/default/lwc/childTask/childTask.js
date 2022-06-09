import { LightningElement, api , wire, track} from 'lwc';
import uId from '@salesforce/user/Id';
import getPendingTaskbyResourceAndProject from "@salesforce/apex/LoadedServiceHours.getPendingTaskbyResourceAndProject";
import { refreshApex } from "@salesforce/apex";
import { ShowToastEvent } from "lightning/platformShowToastEvent";

const START_BUTTON_VARIANT = "brand";
const FINISH_BUTTON_VARIANT = "success";
const START_BUTTON_ICON = "utility:play";
const FINISH_BUTTON_ICON = "action:check";
const START_BUTTON_LABEL = "START";
const FINISH_BUTTON_LABEL = "FINISH";
const RECORD_BUTTON_VARIANT ="brand-outline";
const RECORD_BUTTON_DISABLE = "disabled";


const columns = [
  { 
    label: "Task name", fieldName: "Name" , 
  },
  { label: "Status", fieldName: "Status__c", type: "text", initialWidth: 100 },
  {
    label: "Estimated hours",
    fieldName: "EstimatedHours__c",
    type: "number",
  },
  {
    label: "Registered hours",
    fieldName: "RecordHours__c",
    type: "number",
  },
  {
    label: "Add Hours",
    fieldName: "RecordHours__c",
    type: "customAddHours",
    initialWidth: 150 ,
    typeAttributes: {
      disableButton: {
        fieldName: 'disableButton'
      }

    }
  },
  {
    label: "Actions",
    fieldName: "RecordHours__c",
    type: "customButtonGroup",
    initialWidth: 350 ,
    typeAttributes: {
      variantButton: {
        fieldName: 'variantButton'
      },
      labelButton: {
        fieldName: 'labelButton'
      },
      iconButton: {
        fieldName: 'iconButton'
      },
      variantRecordButton: {
        fieldName: 'variantRecordButton'
      },
      Status__c: {
        fieldName: 'Status__c'
      },
      taskId: {
        fieldName: 'Id'
      }

    }
  },

];

export default class ChildTask extends LightningElement {
  
  //privates
  change = 0;
  columns = columns; //esto no se toca, son las columnas
  fldsItemValues = [];
  newHours=0

  @api project
  usrId= uId;
  @track resList;

saveHandle(event) {
  this.fldsItemValues = event.detail.draftValues;
  const inputsItems = this.fldsItemValues.slice().map(draft => {
      const fields = Object.assign({}, draft);
      return { fields };
  });

 
  const promises = inputsItems.map(recordInput => updateRecord(recordInput));
  Promise.all(promises).then(res => {
    console.log("RES", res)
      this.dispatchEvent(
        new ShowToastEvent({
              title: 'Success',
              message: 'Records Updated Successfully!!',
              variant: 'success'
          })
      );
      this.fldsItemValues = [];
      return this.refresh();
  }).catch(error => {
    console.log("ERROR", error)
      this.dispatchEvent(
          new ShowToastEvent({
              title: 'Error',
              message: 'An Error Occured!!',
              variant: 'error'
          })
      );
  }).finally(() => {
      this.fldsItemValues = [];
  });
}

@wire(getPendingTaskbyResourceAndProject, {
 userId: '$usrId', projectId: '$project.Id', current: "$change"
})
taskPending(result, error) {
  if (result.data) {
    // Process record data
    this.resList = result.data.map((record) => {
      //console.log('que es record -->', record);

      let variantButton = record.Status__c === 'Not Started' ? START_BUTTON_VARIANT : FINISH_BUTTON_VARIANT;
      let labelButton = record.Status__c === 'Not Started' ? START_BUTTON_LABEL: FINISH_BUTTON_LABEL;
      let iconButton = record.Status__c === 'Not Started' ? START_BUTTON_ICON: FINISH_BUTTON_ICON;
      let variantRecordButton = record.Status__c === 'In Progress' ? RECORD_BUTTON_VARIANT: null;
      let disableButton = record.Status__c === 'In Progress' ? '' : RECORD_BUTTON_DISABLE; 

      return {...record, 
          'variantButton': variantButton, 
          'labelButton':labelButton,
          'iconButton':iconButton,
          'variantRecordButton':variantRecordButton,
          'disableButton':disableButton
      }
  });
     console.log("TaskPending son", this.resList);
    //this.resList = result
  } else if (error) {
    console.log("Hubo error en wire : ", error);
    this.resList = undefined
  }
}

handleStatusUpdated(event){

  if(event.target.value){
    this.newHours = event.target.value
    console.log('event.target.value desde chield-handleStatusUpdated es: ', event.target.value);
  }
  console.log('entro a handleStatusUpdated')
  

  this.change +=1;
  return this.dispatchEvent(new CustomEvent('refresh', {
    composed: true,
    bubbles: true
}));
}

handleAddHours(event){
  console.log('entro a handleAddHours')

  console.log('algo cambio Padre ', event.detail);
}

testMethod(){
  console.log("SOY UN TEST Y FUNCIONO");
  console.log('newHours desde chield - es -->', this.newHours);
  // console.log("USUARIO" ,this.usrId);

  console.log("RESLIST",abc.data)
}
 async refresh() {
   await refreshApex(this.resList);
 }

}