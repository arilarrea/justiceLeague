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


const columns = [
  { 
    label: "Task name", fieldName: "Name" , 
  },
  { label: "Status", fieldName: "Status__c", type: "text", initialWidth: 100 },
  {
    label: "Estimated hours",
    fieldName: "EstimatedHours__c",
    type: "number",
    // typeAttributes: {
    //   status: {
    //     fieldName: 'status'
    //   }
    // }
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
    initialWidth: 150 
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
      currentStatus: {
        fieldName: 'Status__c'
      },
      taskId: {
        fieldName: 'Id'
      }

    }
  },
  // {
  //   type: "button", label: "Actions", typeAttributes: 
  //   {  
  //     label: 'Start',  
  //     name: 'Start',  
  //     title: 'Start',  
  //     disabled: false,  
  //     value: 'view',  
  //     iconPosition: 'left'  
  //   },
  // },
];

export default class ChildTask extends LightningElement {
  columns = columns; //esto no se toca, son las columnas
  @api project
  fldsItemValues = [];
  usrId= uId;
  @track resList;

// action;
// selectedrow;

onRowAction(event){

  const action = event.detail.action

  const row = event.detail.row;

  switch (action.name) {
    

    case 'Start':
      console.log("COLUMNAS", this.columns[4])

    this.columns = [
      { label: "Task name", fieldName: "Name" },
      { label: "Status", fieldName: "Status__c", type: "text" },
      {
        label: "Stimated hours",
        fieldName: "EstimatedHours__c",
        type: "text"
      },
      {
        label: "Registered hours",
        fieldName: "RecordHours__c",
        type: "text",
      },
      {type: "number", label: "Actions", editable: true }
    
    ];
      break;
        }
}

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
 userId: '$usrId', projectId: '$project.Id'
})
taskPending(result, error) {
  if (result.data) {
    // Process record data
    this.resList = result.data.map((record) => {
      console.log('que es record -->', record);

      let variantButton = record.Status__c === 'Not Started' ? START_BUTTON_VARIANT : FINISH_BUTTON_VARIANT;
      let labelButton = record.Status__c === 'Not Started' ? START_BUTTON_LABEL: FINISH_BUTTON_LABEL;
      let iconButton = record.Status__c === 'Not Started' ? START_BUTTON_ICON: FINISH_BUTTON_ICON;
      let variantRecordButton = record.Status__c === 'In Progress' ? RECORD_BUTTON_VARIANT: null;

      return {...record, 
          'variantButton': variantButton, 
          'labelButton':labelButton,
          'iconButton':iconButton,
          'variantRecordButton':variantRecordButton,
      }
  });
     console.log("TaskPending son", this.resList);
    //this.resList = result
  } else if (error) {
    console.log("Hubo error en wire : ", error);
    this.resList = undefined
  }
}
testMethod(){
  console.log("SOY UN TEST Y FUNCIONO");
  var abc = this.template.querySelector('lightning-datatable')
  // console.log(this.project.Id);
  // console.log("USUARIO" ,this.usrId);

  console.log("RESLIST",abc.data)
}
// async refresh() {
//   await refreshApex(this.resList);
// }

}