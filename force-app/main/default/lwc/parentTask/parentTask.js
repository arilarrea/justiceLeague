import { LightningElement, api, wire } from 'lwc';
import getPendingTaskbyResourceCount from "@salesforce/apex/LoadedServiceHours.getPendingTaskbyResourceCount";
import uId from '@salesforce/user/Id';

//getPendingTaskbyResourceAndProject
export default class ParentTask extends LightningElement {
//private
pendingTasksCount;
usrId= uId;
change = 0;

@wire(getPendingTaskbyResourceCount,{userId: '$usrId' , change: '$change' })
getTask(result, error){
    if(result){
        console.log("user", this.usrId)
        console.log("result query", result)
        this.pendingTasksCount = result;
    }else if(error){
        this.pendingTasksCount = undefined;
    }
}

handleStatusUpdated(event){
    console.log('test de evento')
    this.change +=1;
}

}