import { LightningElement,api, track,wire } from 'lwc';
import get4EDLines from '@salesforce/apex/Create4EDLineController.getLineItems';
import {CloseActionScreenEvent} from 'lightning/actions';
import createEDLine from '@salesforce/apex/Create4EDLineController.saveLines';
import {ShowToastEvent} from 'lightning/platformShowToastEvent';
import { refreshApex } from '@salesforce/apex';

export default class Create4EDLine extends LightningElement {
    @api recordId;
    @track EDList;
    isLoad = false;
    allCheck = false;
    @track originaldata;
    @track deliveryDate;

    @wire(get4EDLines, {EDId: '$recordId'})
    lineList(result) {
        const {data, error} = result;
        this.originaldata = result;
        if (data) {
            this.EDList = JSON.parse(JSON.stringify(data));
            // console.log('result---');
            // console.log(result);
            console.log(this.EDList);
        }
        if (error) {
            console.log(error);
        }
    }

    allChangeHandler(event){
        let isCheckVal = event.target.checked;
        console.log('isCheckVal-->>'+isCheckVal);

        const allCheckList = this.template.querySelectorAll('[data-mark="allCheckId"]');
        for (const ele of allCheckList) {
            ele.checked = event.target.checked;
        }

        this.EDList.forEach(ele => {
            console.log(ele);

            ele.isCheck = isCheckVal;
        });
    }

    onChangeHandler(event){
        let isCheckVal = event.target.checked;
        let indx = event.currentTarget.dataset.index;
        console.log('isCheckVal-->>'+isCheckVal);
        console.log('index-->>'+indx);
        this.EDList[indx].isCheck = isCheckVal;
    }

    handleDateChangeEvent(event){
        this.deliveryDate = event.target.value;
        let indx = event.currentTarget.dataset.index;
        console.log('deliveryDate-->>'+this.deliveryDate);
        console.log('index-->>'+indx);
        this.EDList[indx].deliveryDateReq = this.deliveryDate;
    }


    closeAction() {
        this.dispatchEvent(new CloseActionScreenEvent());
    }

    createLines(){
        this.isLoad = true;
        let edLineList = [];
         let selEDLinse = this.EDList.filter(ele => {
             console.log(ele);
            return ele.isCheck == true;
        });

        selEDLinse.forEach( ele => {
            let edObj = {
                lineId : ele.lineId,
                isCheck : ele.isCheck,
                description : ele.description,
                quantity : ele.quantity,
                price : ele.price,
                deliverySLA : ele.deliverySLA,
                deliveryDateReq : ele.deliveryDateReq
            }
            edLineList.push(edObj);
        })

        console.log('edLineList');
        console.log(edLineList);

       
        createEDLine({ edLines : edLineList, edId : this.recordId}).then( result => {
            console.log('result');
            console.log(result);
            this.isLoad = false;
            this.showNotification('Success!', `Successfully created 4ED Lines`, 'Success');
            
            refreshApex(this.originaldata);
            this.closeAction();
        }).catch(err =>{
            this.isLoad = false;
            console.log(err);

        });
    }

    showNotification(title, message, variant) {
        const evt = new ShowToastEvent({
            title: title,
            message: message,
            variant: variant,
        });
        this.dispatchEvent(evt);
    }

    get isLine(){
        if(this.EDList != undefined && this.EDList.length > 0){
            return true;
        }
        return false;
    }

}