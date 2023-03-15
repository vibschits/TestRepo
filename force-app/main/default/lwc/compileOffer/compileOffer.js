import {LightningElement, track, api,wire} from 'lwc';
import getOffers from '@salesforce/apex/CompileOfferController.getOffers';
import offerCombine from '@salesforce/apex/CompileOfferController.compileOffer';
import {CloseActionScreenEvent} from 'lightning/actions';
import {ShowToastEvent} from 'lightning/platformShowToastEvent';
import { getRecordNotifyChange } from 'lightning/uiRecordApi';
import { updateRecord } from 'lightning/uiRecordApi';


export default class CompileOffer extends LightningElement {
    @api recordId;
    @track offerList;
    isLoad = false;

    @wire(getOffers, {
        oppId: '$recordId'
    })
    offers(result) {
        if (result.data) {
            this.offerList = JSON.parse(JSON.stringify(result.data));
            console.log(this.offerList);
        }
        if (result.error) {
            console.log(result.error);
        }
    }

    onCheckHandler(event) {
        let val = event.target.checked;
        console.log('Val->>', val);
        let indx = event.currentTarget.dataset.id;
        console.log('indx->>', indx);
        this.offerList[indx].selected = val;
        console.log('Val List->>', this.offerListal);
    }

    SaveCombineOfr() {
        let offerLineIds = [];
        
        this.offerList.forEach(ele => {
            console.log(ele.selected);
            if (ele.selected) {
                offerLineIds.push(ele.offer.Id);
            }
        });
        console.log(offerLineIds);
        if (offerLineIds.length > 1) {
            this.isLoad = true;
            offerCombine({
                offerIds: offerLineIds
            }).then(res => {
                console.log(res);
                this.isLoad = false;
                this.showNotification('Success!', `Successfully compile offer${res.Name}`, 'Success');
                //updateRecord({ fields: { Id: this.recordId }});
                // document.dispatchEvent(new CustomEvent("aura://refreshView"));
                this.closeAction();
            }).catch(err => {
                this.isLoad = false;
                console.log(err);
            })
        } else {
            this.showNotification('Warning!', 'Single offer cannot be compile.', 'Warning');

        }
    }

    closeAction() {
        this.dispatchEvent(new CloseActionScreenEvent());
    }
    showNotification(title, message, variant) {
        const evt = new ShowToastEvent({
            title: title,
            message: message,
            variant: variant,
        });
        this.dispatchEvent(evt);
    }
		
		get isOffer(){
        if(this.offerList != undefined && this.offerList.length > 0){
            return true;
        }
        return false;
    }

}