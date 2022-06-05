import { LightningElement, api, wire, track } from "lwc";
import getRolesWhitoutAssignment from "@salesforce/apex/AllocationService.getRolesWhitoutAssignment";
import getTeamProgressesByProject from "@salesforce/apex/AllocationService.getTeamProgressesByProject";

const columns = [
  { label: "Role", fieldName: "Role__c" },
  { label: "Hours Requested", fieldName: "QuantityHours__c" },
  { label: "Hours Allocated", fieldName: "QuantityHoursAllocated__c" }
];
const columnsTeamProgress = [
  { label: "Resource Name", fieldName: "Resource__r.FullName__c" },
  { label: "Role", fieldName: 'Resource__r.Role__c' },
  { label: "Hours Allocated", fieldName: "QuantityHoursAllocated__c" }
];

export default class RolesAndTeam extends LightningElement {
  @api columns = columns;
  @track columnsTeamProgress = columnsTeamProgress;
  @api recordId;
  @track teamProgress = [];

  //private
  rolesAllocated;
  fldsItemValues = [];

  @wire(getRolesWhitoutAssignment, { projectId: "$recordId" })
  golesWhitoutA(result, error) {
    if (result) {
      this.rolesAllocated = result;
      //console.log("rolesAllocated desde el padre son: ", this.rolesAllocated);
    } else if (error) {
      this.rolesAllocated = undefined;
    }
  }
 /**************  INICIO DATA TABLE PARA LOS TEAM PROGRESES  *****************/
 

  @wire(getTeamProgressesByProject, { projectId: "$recordId" })
  //wiring an apex method to a function
  wiredTeamP({ error, data }) {
      if(data) {
         //this is the final array into which the flattened response will be pushed. 
         let teamProgressArray = [];
          
         for (let row of data) {
              // this const stroes a single flattened row. 
              const flattenedRow = {}
              
              // get keys of a single row — Name, Phone, LeadSource and etc
              let rowKeys = Object.keys(row); 
             
              //iterate 
              rowKeys.forEach((rowKey) => {
                  
                  //get the value of each key of a single row. John, 999-999-999, Web and etc
                  const singleNodeValue = row[rowKey];
                  
                  //check if the value is a node(object) or a string
                  if(singleNodeValue.constructor === Object){
                      
                      //if it's an object flatten it
                      this._flatten(singleNodeValue, flattenedRow, rowKey)        
                  }else{
                      
                      //if it’s a normal string push it to the flattenedRow array
                      flattenedRow[rowKey] = singleNodeValue;
                  }
                  
              });
             
              //push all the flattened rows to the final array 
              teamProgressArray.push(flattenedRow);
          }
          
          //assign the array to an array that's used in the template file
          this.teamProgress = teamProgressArray;
      } else if (error) {
          this.error = error;
      }
  }
  
  /* create keys in the format of Account.Id, Account.Rating, Account.Industry and etc
  
  we can avoid using this function by reusing the above function. 
  
  To understand in easily I used a separate function 
  
  Feel free to refactor it */
  _flatten = (nodeValue, flattenedRow, nodeName) => {        
      let rowKeys = Object.keys(nodeValue);
      rowKeys.forEach((key) => {
          let finalKey = nodeName + '.'+ key;
          flattenedRow[finalKey] = nodeValue[key];
      })
  }
  
  

/**************  FIN DATA TABLE PARA LOS TEAM PROGRESES  *****************/

}
