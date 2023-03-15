import {LightningElement, track, api,wire} from 'lwc';
import getOffers from '@salesforce/apex/CombineOfferController.getOffers';
import offerCombine from '@salesforce/apex/CombineOfferController.combineOffer';
import {CloseActionScreenEvent} from 'lightning/actions';
import {ShowToastEvent} from 'lightning/platformShowToastEvent';
import { getRecordNotifyChange } from 'lightning/uiRecordApi';
import { updateRecord } from 'lightning/uiRecordApi';
import Error_on from '@salesforce/label/c.Error_on';


export default class CombineOffer extends LightningElement {
    @api recordId;
    @track offerList;
    
    isLoad = false;
    value = 'All';

    @wire(getOffers, {
        oppId: '$recordId', type : '$value'
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

        let selOffer = this.offerList[indx].offer;
        console.log(selOffer);
        console.log(selOffer['RecordType'].Id);

        if(selOffer.RecordType.DeveloperName == 'Offer_Non_Spare'){
            this.offerList.forEach(ele => {
                if(ele.offer.RecordType.DeveloperName == 'Offer'){
                    ele.isDisable = true;
                }
            });
        }

        if(selOffer.RecordType.DeveloperName == 'Offer'){
            this.offerList.forEach(ele => {
                if(ele.offer.RecordType.DeveloperName == 'Offer_Non_Spare'){
                    ele.isDisable = true;
                }
            });
        }

        
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
            console.log('OfferIds =>',offerLineIds);
            offerCombine({
                offerIds: offerLineIds
            }).then(res => {
                console.log(res);
                this.isLoad = false;
                this.showNotification('Success!', `Successfully combined offer ${res.Name}`, 'Success');
                //updateRecord({ fields: { Id: this.recordId }});
                // document.dispatchEvent(new CustomEvent("aura://refreshView"));
                this.closeAction();
            }).catch(err => {
                this.isLoad = false;
                console.log(err);
                this.closeAction();
                this.showNotification('Error!',` ${Error_on}`, 'Error', 'sticky');
            })
        } 
        else {
            this.showNotification('Warning!', 'Single offer cannot be combine.', 'Warning');
        }
    }

    closeAction() {
        this.dispatchEvent(new CloseActionScreenEvent());
    }
    showNotification(title, message, variant, mode) {
        const evt = new ShowToastEvent({
            title: title,
            message: message,
            variant: variant,
            mode: mode,
        });
        this.dispatchEvent(evt);
    }

    get isOffer(){
        if(this.offerList != undefined && this.offerList.length > 0){
            return true;
        }
        return false;
    }


    get options() {
        return [
            { label: 'All', value: 'All' },
            { label: 'Spare', value: 'Spare' },
            { label: 'Non Spare', value: 'Non Spare' },
        ];
    }

    handleChange(event){
        let selVal = event.detail.value;
        console.log('selVal-->>'+selVal);
        this.value = event.detail.value;
    }

    

}