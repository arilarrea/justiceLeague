import { LightningElement, api, wire } from "lwc";
import getRolesWhitoutAssignment from "@salesforce/apex/AllocationService.getRolesWhitoutAssignment";

export default class PartentTest extends LightningElement {
  @api recordId;
  rolesWithoutAssignment;
  @wire(getRolesWhitoutAssignment, { projectId: "$recordId" })
  testing(result, error) {
    if (result) {
      this.rolesWithoutAssignment = result;
      console.log(
        "RolesWhitoutAssignment desde el padre son: ",
        this.rolesWithoutAssignment
      );
    } else if (error) {
      this.rolesWithoutAssignment = undefined;
    }
  }
}