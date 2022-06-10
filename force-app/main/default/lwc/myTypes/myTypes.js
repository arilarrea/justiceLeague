import LightningDatatable from 'lightning/datatable';
import { LightningElement, api , wire, track} from 'lwc';
import customName from './customName.html';
import customNumber from './customNumber.html';
import customButtonGroup from './customButtonGroup.html';
import customAddHours from './customAddHours.html';


export default class MyTypes extends LightningDatatable {
    // @api infoTable;
    // test(){
    //     console.log('Entro al myTypes');
    // }

    
    static customTypes = {
        customText: {
            template: customName,
            standardCellLayout: true,
            typeAttributes: ['accountName'],
        },
        customNumber: {
            template: customNumber,
            standardCellLayout: false,
        },
        customButtonGroup: {
            template: customButtonGroup,
            standardCellLayout: false,
            typeAttributes:['variantButton', 'labelButton', 'iconButton', 'variantRecordButton', 'Status__c' , 'taskId'],
        },
        customAddHours: {
            template: customAddHours,
            standardCellLayout: false,
            typeAttributes:['disableButton', 'taskId'],
        }
        // Other types here
    }
}