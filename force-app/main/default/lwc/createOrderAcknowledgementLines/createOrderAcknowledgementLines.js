import { LightningElement,api, track,wire } from 'lwc';
import get4EDLines from '@salesforce/apex/CreateOrderAcknowledgementLines.getLineItems';
import {CloseActionScreenEvent} from 'lightning/actions';
import createEDLine from '@salesforce/apex/CreateOrderAcknowledgementLines.saveLines';
import {ShowToastEvent} from 'lightning/platformShowToastEvent';
import { refreshApex } from '@salesforce/apex';

export default class Create4EDLine extends LightningElement {
    @api recordId;
    @track EDList;
    isLoad = false;
    allCheck = false;
    @track originaldata;
    @track deliveryDate;

    @wire(get4EDLines, {OAId: '$recordId'})
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
            // let edObj = {
            //     lineId : ele.lineId,
            //     isCheck : ele.isCheck,
            //     description : ele.description,
            //     quantity : ele.quantity,
            //     price : ele.price,
            //     deliverySLA : ele.deliverySLA,
            //     deliveryDateReq : ele.deliveryDateReq
            // }
            let edObj = {
                lineId : ele.lineId,
                description : ele.description
            }
            edLineList.push(edObj);
        })

        console.log('edLineList');
        console.log(edLineList);

       
        createEDLine({ oALines : edLineList, oAId : this.recordId}).then( result => {
            console.log('result');
            console.log(result);
            this.isLoad = false;
            this.showNotification('Success!', `Successfully created Order Acknowledgement Lines`, 'Success');
            
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