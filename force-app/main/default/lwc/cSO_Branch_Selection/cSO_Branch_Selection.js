import { LightningElement, api, wire } from 'lwc';
import NAME_FIELD from '@salesforce/schema/Customer_Sales_Organization__c.Name';
import CUSTOMER_FIELD from '@salesforce/schema/Customer_Sales_Organization__c.Customer__c';
import CURRENCY_FIELD from '@salesforce/schema/Customer_Sales_Organization__c.CurrencyIsoCode';
import CUSTOMER_CODE_FIELD from '@salesforce/schema/Customer_Sales_Organization__c.Customer_Code__c';
import DIVISION_FIELD from '@salesforce/schema/Customer_Sales_Organization__c.Division__c';
import SALES_OFFICE_DESCRIPTION_FIELD from '@salesforce/schema/Customer_Sales_Organization__c.Sales_Office_Description__c';
import COMPANY_CODE_FIELD from '@salesforce/schema/Customer_Sales_Organization__c.Company_Code__c';
import CREATED_BY_FIELD from '@salesforce/schema/Customer_Sales_Organization__c.CreatedById';
import CREATED_DATE_FIELD from '@salesforce/schema/Customer_Sales_Organization__c.CreatedDate';
import LAST_MODIFIED_BY_FIELD from '@salesforce/schema/Customer_Sales_Organization__c.LastModifiedById';
import LAST_MODIFIED_DATE_FIELD from '@salesforce/schema/Customer_Sales_Organization__c.LastModifiedDate';
import COMPANY_FIELD from '@salesforce/schema/Customer_Sales_Organization__c.Company__c';
import BRANCH_FIELD from '@salesforce/schema/Customer_Sales_Organization__c.Branch__c';
import DISTRIBUTION_CHANNEL_FIELD from '@salesforce/schema/Customer_Sales_Organization__c.Distribution_Channel__c';
import STATUS_FIELD from '@salesforce/schema/Customer_Sales_Organization__c.Status__c';
import uId from '@salesforce/user/Id';
import getCompany from '@salesforce/apex/UserBranchClass.getCompanyFromUserBranch';
import getBranch from '@salesforce/apex/UserBranchClass.getBranchFromSelectedCompany';
import saveCSORecord from '@salesforce/apex/UserBranchClass.saveCSO';
import { ShowToastEvent } from 'lightning/platformShowToastEvent'
import { NavigationMixin } from 'lightning/navigation';
import { getRecord, getFieldValue } from 'lightning/uiRecordApi';
import COMPANY__NAME_FIELD from '@salesforce/schema/Customer_Sales_Organization__c.Company__r.Name';
import BRANCH_NAME_FIELD from '@salesforce/schema/Customer_Sales_Organization__c.Branch__r.Name';

export default class CSO_Branch_Selection extends NavigationMixin(LightningElement) {

    @api recordId;
    @api isEditBtnClicked;
    userId = uId;
    items;
    branchItems;
    error;
    value1;
    value2;
    customerSalesOrg;
    isReadMode = true;
    isEditMode = false;
    isBothFilled = true;
    isCompanyFilled = true;
    recordFromWire;
    isPreFilled = false;

    companyField = COMPANY_FIELD;
    branchField = BRANCH_FIELD;
    distributionChannelField = DISTRIBUTION_CHANNEL_FIELD;
    nameField = NAME_FIELD;
    currencyField = CURRENCY_FIELD;
    customerField = CUSTOMER_FIELD;
    customerCodeField = CUSTOMER_CODE_FIELD;
    divisionField = DIVISION_FIELD;
    salesOfficeDiscriptionField = SALES_OFFICE_DESCRIPTION_FIELD;
    companyCodeField = COMPANY_CODE_FIELD;
    createdByField = CREATED_BY_FIELD;
    createdDateField = CREATED_DATE_FIELD;
    lastModifiedByField = LAST_MODIFIED_BY_FIELD;
    lastModifiedDateField = LAST_MODIFIED_DATE_FIELD;
    statusField = STATUS_FIELD;

    @wire(getRecord, { recordId: '$recordId', fields: [COMPANY__NAME_FIELD, BRANCH_NAME_FIELD] })
    wiredRecord({ error,data }){
        if(data){
            this.recordFromWire = data;
            console.log("Wire Data",data);
            console.log("storedData", this.recordFromWire);
            this.value1 = this.recordFromWire.fields.Company__r.displayValue;
            console.log("value1",this.value1);
            this.value2 = this.recordFromWire.fields.Branch__r.displayValue;
            console.log("value2",this.value2);
            this.callBranchMethod();
        }
    }

    @wire(getCompany, { currentUserId: '$userId' })
    getRecords({error,data}){
        console.log('data : ',data);
        console.log("RECORD ID ",this.recordId);
        if(this.isEditBtnClicked === "Y"){
            console.log("worked");
            this.isReadMode = false;
            this.isEditMode = true;
        }
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

    handleSubmit(event){
        console.log("HANDLE SUBMIT CALLED");
        
    }

    saveClick(event){
        console.log("SAVE SUBMIT CALLED");
        saveCSORecord({ csoId: this.recordId, selectedCompany: this.value1, selectedBranch: this.value2 }).then((result) => {
            console.log("result in saveClick",result)
            if(result === 'SUCCESS'){
                const event = new ShowToastEvent({
                    title: 'Record Updated',
                    message: 'Offer record updated successfully',
                    variant: 'success',
                    mode: 'dismissable'
                });
                this.dispatchEvent(event);
                this.isReadMode = true;
                this.isEditMode = false;
                this.navigateToRecordPage();
            }else{
                const evt = new ShowToastEvent({
                    title: 'Record Update Failed',
                    message: result,
                    variant: 'error',
                    mode: 'dismissable'
                });
                this.dispatchEvent(evt);
            }
        })
        .catch((error) => {
            this.error = error;
            console.log('Error',this.error);
        })
    }

    navigateToRecordPage() {
        console.log("Inside navigation mixin")
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: this.recordId,
                objectApiName: 'Customer_Sales_Organization__c',
                actionName: 'view'
            }
        });
    }

    // handleEdit(event){
    //     this.isReadMode = false;
    //     this.isEditMode = true;
    // }

    cancelClick(event){
        this.isReadMode = true;
        this.isEditMode = false;
        this.navigateToRecordPage();
    }

    callBranchMethod() {
        //this.value1 = event.detail.value;
        getBranch({ selectedCompany: this.value1 }).then((result) => {
            if(result){
                this.branchItems = result;
            }
        })
        .catch((error) => {
            this.error = error;
            console.log('Error',this.error);
        })
        this.isBothFilled = false;
        this.isCompanyFilled = false;
        this.isPreFilled = true;
    }
}