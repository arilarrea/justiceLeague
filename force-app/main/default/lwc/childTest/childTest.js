import { LightningElement, api, track, wire } from "lwc";
import getResourcesByRole from "@salesforce/apex/AllocationService.getResourcesByRole";
import allocationCreate from "@salesforce/apex/AllocationService.allocationCreate";
import getHoursPendingToAssignByRole from "@salesforce/apex/AllocationService.getHoursPendingToAssignByRole";
import { refreshApex } from "@salesforce/apex";

import { ShowToastEvent } from "lightning/platformShowToastEvent";

const columns = [
  { label: "Resource Name", fieldName: "FullName__c" },
  { label: "Rate per hour", fieldName: "RatePerHour__c", type: "currency" },
  {
    label: "Start Date",
    fieldName: "startDate",
    type: "date-local",
    editable: true
  },
  {
    label: "End Date",
    fieldName: "endDate",
    type: "date-local",
    editable: true
  }
];

export default class ChildTest extends LightningElement {
  //privados
  fldsItemValues = [];

  @api role;
  @api recordId;
  @api columns = columns; //esto no se toca, son las columnas
  change = 0;

  @api testMethod() {
    console.log("FUNCIONA EL BOTON");
    console.log("Rec", this.recordId);
    console.log("change es: ", this.change);
    // console.log("las horas restantes son: ", this.hoursPendingToAssign);
  }

  @api saveHandleAction(event) {
    console.log("EVENT", event);
    this.fldsItemValues = event.detail.draftValues;

    const inputsItems = JSON.stringify(
      this.fldsItemValues.slice().map((draft) => {
        let draft2 = {};
        draft2.Resource__c = draft.Id;
        draft2.Project__c = this.recordId;
        draft2.startDateAllocated__c = draft.startDate;
        draft2.endDateAllocated__c = draft.endDate;

        return draft2;
      })
    );

    console.log("Inputs con formato json --->", inputsItems);
    allocationCreate({ alocationJson: inputsItems , projectID : this.recordId})
      .then((res) => {
        console.log("res es --->", res);
        this.dispatchEvent(
          new ShowToastEvent({
            title: "Success",
            message: res,
            variant: "success"
          })
        );
        this.fldsItemValues = [];
        this.change += 1;
        return this.refresh();
      })
      .catch((error) => {
        console.log(error);
        this.dispatchEvent(
          new ShowToastEvent({
            title: "Error",
            message:
              "Ups, An Error Occured!! " + error.body.pageErrors[0].message,
            variant: "error"
          })
        );
      })
      .finally(() => {
        this.fldsItemValues = [];
      });
  }

  @api showToast() {
    const event = new ShowToastEvent({
      title: "Ups, and error has occurred",
      variant: "error",
      message: "You can't set up this resource alocation."
    });
    this.dispatchEvent(event);
  }

  @track resList;
  @wire(getResourcesByRole, { roleName: "$role.Role__c" })
  resourceList(result, error) {
    this.resList = result;
    if (result.error) {
      this.resList = undefined;
    }
  }

  @track hoursPendingToAssign;
  @wire(getHoursPendingToAssignByRole, {
    projectId: "$recordId",
    RoleName: "$role.Role__c",
    current: "$change"
  })
  hoursPending(result, error) {
    if (result.data) {
      console.log("hoursPending son", result.data[0].HoursPendingToAssign__c);
      this.hoursPendingToAssign = result.data[0].HoursPendingToAssign__c;
    } else if (error) {
      console.log("Hubo error en wire : ", error);
      //this.hoursPendingToAssign = undefined;
    }
  }

  async refresh() {
    await refreshApex(this.resList);
    //await refreshApex(this.hoursPendingToAssign);
  }
}