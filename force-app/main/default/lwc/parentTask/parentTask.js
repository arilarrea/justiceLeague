import { LightningElement, api, wire } from 'lwc';
import getPendingTaskbyResourceCount from "@salesforce/apex/LoadedServiceHours.getPendingTaskbyResourceCount";
import uId from '@salesforce/user/Id';

//getPendingTaskbyResourceAndProject
export default class ParentTask extends LightningElement {

pendingTasksCount;
usrId= uId;
@wire(getPendingTaskbyResourceCount,{userId: '$usrId' })
getTask(result, error){
    if(result){
        console.log("user", this.usrId)
        console.log("result query", result)
        this.pendingTasksCount = result;
    }else if(error){
        this.pendingTasksCount = undefined;
    }
}

}