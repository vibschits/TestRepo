import { LightningElement, api, wire, track } from 'lwc';
import uId from '@salesforce/user/Id';
import { getPicklistValues, getObjectInfo } from 'lightning/uiObjectInfoApi';
import CUSTOMER_SALES_ORG_OBJECT from '@salesforce/schema/Customer_Sales_Organization__c';
import CURRENCY_FIELD from '@salesforce/schema/Customer_Sales_Organization__c.CurrencyIsoCode';
import DIVISION_FIELD from '@salesforce/schema/Customer_Sales_Organization__c.Division__c';
import getCompany from '@salesforce/apex/UserBranchClass.getCompanyFromUserBranch';
import getBranch from '@salesforce/apex/UserBranchClass.getBranchFromSelectedCompany';
import createCSORecord from '@salesforce/apex/UserBranchClass.createCSO';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { CloseActionScreenEvent } from 'lightning/actions';
import { NavigationMixin } from 'lightning/navigation';

export default class CSO_Insert extends NavigationMixin(LightningElement) {
    @api recordId;
    @api objectApiName;
    userId = uId;
    items;
    branchItems;
    error;
    errorMessage;
    value1;
    value2;
    customerSalesOrg;
    isEditMode = false;
    isBothFilled = true;
    isCompanyFilled = true;
    newCSOId;
    selectedCurrency;
    selectedCustomerCode;
    selectedCompanyCode;
    selectedSOD;
    selectedDivisions = [];
    @track lstOptions = [];

    @wire(getObjectInfo, { objectApiName: CUSTOMER_SALES_ORG_OBJECT })
    objectInfo;

    @wire(getPicklistValues, { recordTypeId: '$objectInfo.data.defaultRecordTypeId', fieldApiName: CURRENCY_FIELD })
    currencyValues;

    @wire(getPicklistValues, {recordTypeId: '$objectInfo.data.defaultRecordTypeId', fieldApiName: DIVISION_FIELD })
    divisionValues(data, error){
        console.log("DIVISION DATA ",data);
        if(data && data.data && data.data.values){
            data.data.values.forEach( objPicklist => {
                this.lstOptions.push({
                    label: objPicklist.label,
                    value: objPicklist.value
                });
                console.log("DIVISION OPTIONS ",this.lstOptions);
            });
        } else if(error){
            console.log(error);
        }
    };
    
    @wire(getCompany, { currentUserId: '$userId' })
    getRecords({error,data}){
        console.log('data : ',data);
        if(data){
            this.items = data;
        }else if(error){
            console.error('Error =>',error);
        }
    }

    get options() {
        var returnOptions = [];
        if(this.items){
            this.items.forEach(ele =>{
                returnOptions.push({label:ele , value:ele});
            }); 
        }
        console.log(JSON.stringify(returnOptions));
        return returnOptions;
    }

    handleChange1(event) {
        this.value1 = event.detail.value;
        getBranch({ selectedCompany: this.value1 }).then((result) => {
            if(result){
                this.branchItems = result;
            }
        })
        .catch((error) => {
            this.error = error;
            console.log('Error',this.error);
        })
        this.isBothFilled = true;
        this.isCompanyFilled = false;
    }

    get options2() {
        var returnOptions = [];
        if(this.branchItems){
            this.branchItems.forEach(ele =>{
                returnOptions.push({label:ele , value:ele});
            }); 
        }
        console.log(JSON.stringify(returnOptions));
        return returnOptions;
    }

    handleChange2(event){
        this.value2 = event.detail.value;
        if(this.value1 != '' && this.value2 != ''){
            this.isBothFilled = false;
        }else{
            this.isBothFilled = true;
        }
    }

    handleCurrencyChange(event){
        this.selectedCurrency = event.detail.value;
        console.log("selectedCurrency: ",this.selectedCurrency);
    }

    handleDivision(event){
        this.selectedDivisions = event.detail.value;
        console.log("selectedDivision: ",this.selectedDivisions);
    }

    handleSave(event) {
        console.log("Selected Company in handleSuccess ",this.value1);
        console.log("Selected Branch in handleSuccess ",this.value2);
        //this.newCSOId = event.detail.id;
        console.log("Create Record CALLED");
        createCSORecord({ customerId: this.recordId, selectedCompany: this.value1, selectedBranch: this.value2, currencySelected: "USD", 
        divisionsSelected: this.selectedDivisions }).then((result) => {
            console.log("result in saveClick",result)
            this.newCSOId = result;
            const event = new ShowToastEvent({
                title: 'Record Updated',
                message: 'Offer record updated successfully',
                variant: 'success',
                mode: 'dismissable'
            });
            this.dispatchEvent(event);
            this.navigateToRecordPage();
            // if(result === 'SUCCESS'){
            //     const event = new ShowToastEvent({
            //         title: 'Record Created',
            //         message: 'Offer record updated successfully',
            //         variant: 'success',
            //         mode: 'dismissable'
            //     });
            //     this.dispatchEvent(event);
            //     this.dispatchEvent(new CloseActionScreenEvent());
            // }else{
            //     const evt = new ShowToastEvent({
            //         title: 'Record Update Failed',
            //         message: result,
            //         variant: 'error',
            //         mode: 'dismissable'
            //     });
            //     this.dispatchEvent(evt);
            // }
        })
        .catch((error) => {
            this.error = error;
            this.errorMessage = error.body.message;
            console.log('Error',this.error);
            console.log('Error',this.errorMessage);
            const event = new ShowToastEvent({
                title: 'Failed',
                message: this.errorMessage,
                variant: 'error',
                mode: 'dismissable'
            });
            this.dispatchEvent(event);
        })
    }

    navigateToRecordPage() {
        console.log("Inside navigation mixin")
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: this.newCSOId,
                objectApiName: 'Customer_Sales_Organization__c',
                actionName: 'view'
            }
        });
    }
}