import { LightningElement, api } from 'lwc';
import { FlowNavigationNextEvent } from 'lightning/flowSupport';

const columnsMill = [
    { label: 'Name', fieldName: 'linkName', type: 'url',typeAttributes: {label: { fieldName: 'Name' }, target: '_blank'}},
    { label: 'Ore', fieldName: 'Ore__c' },
    { label: 'Specific Gravity', fieldName: 'Specific_Gravity__c'},
    { label: 'BWI', fieldName: 'BWI_Kwh_t_metric__c'},
    { label: 'F80', fieldName: 'F80_mm__c'},
    { label: 'P80', fieldName: 'P80_mm__c'},
    { label: 'Created Date', fieldName: 'CreatedDate', sortable: true},
    { label: 'Last Modifed Date', fieldName: 'LastModifiedDate', sortable: true}
];

const columnsHydrocyclone = [
    { label: 'Name', fieldName: 'linkName', type: 'url',typeAttributes: {label: { fieldName: 'Name' }, target: '_blank'}},
    { label: 'Ore Type', fieldName: 'Ore_type__c' },
    { label: 'Specific Gravity of Solid', fieldName: 'Specific_Gravity_of_Solid__c'},
    { label: '% Solids', fieldName: 'Solids__c'},
    { label: 'Feed Rate (tph)', fieldName: 'Feed__c'},
    { label: 'Overflow (tph)', fieldName: 'Overflow_TPH__c'},
    { label: 'Created Date', fieldName: 'CreatedDate', sortable: true},
    { label: 'Last Modifed Date', fieldName: 'LastModifiedDate', sortable: true}
];

const columnsScreen = [
    { label: 'Name', fieldName: 'linkName', type: 'url',typeAttributes: {label: { fieldName: 'Name' }, target: '_blank'}},
    { label: 'Ore', fieldName: 'Ore__c' },
    { label: 'Specific Gravity', fieldName: 'Specific_Gravity__c'},
    { label: 'Moisture', fieldName: 'Moisture__c'},
    { label: 'Feed Rate (tph)', fieldName: 'Feed__c'},
    { label: 'Max Particle Size', fieldName: 'Max_Particle_Size__c'},
    { label: 'Created Date', fieldName: 'CreatedDate', sortable: true},
    { label: 'Last Modifed Date', fieldName: 'LastModifiedDate', sortable: true}
];

const columnsTrommel = [
    { label: 'Name', fieldName: 'linkName', type: 'url',typeAttributes: {label: { fieldName: 'Name' }, target: '_blank'}},
    { label: 'Ore', fieldName: 'Ore__c' },
    { label: 'Specific Gravity', fieldName: 'Specific_Gravity__c'},
    { label: 'Feed Rate (tph)', fieldName: 'Feed__c'},
    { label: 'Recirculation Load', fieldName: 'Recirculation_load__c'},
    { label: '% Solids', fieldName: 'Solids__c'},
    { label: 'Created Date', fieldName: 'CreatedDate', sortable: true},
    { label: 'Last Modifed Date', fieldName: 'LastModifiedDate', sortable: true}
];

const columnsWC = [
    { label: 'Name', fieldName: 'linkName', type: 'url',typeAttributes: {label: { fieldName: 'Name' }, target: '_blank'}},
    { label: 'Material Handled', fieldName: 'Material_Handled__c' },
    { label: 'Specific Gravity', fieldName: 'Specific_Gravity__c'},
    { label: 'Material Temperature', fieldName: 'Material_Temperature_C__c'},
    { label: 'Methods of Feeding', fieldName: 'Methods_of_Feeding__c'},
    { label: 'Silica Content', fieldName: 'Silica_Content__c'},
    { label: 'Created Date', fieldName: 'CreatedDate', sortable: true},
    { label: 'Last Modifed Date', fieldName: 'LastModifiedDate', sortable: true}
];

const columnsCC = [
    { label: 'Name', fieldName: 'linkName', type: 'url',typeAttributes: {label: { fieldName: 'Name' }, target: '_blank'}},
    { label: 'Material Handled', fieldName: 'Material_Handled__c' },
    { label: 'Specific Gravity', fieldName: 'Specific_Gravity__c'},
    { label: 'Material Temperature', fieldName: 'Material_Temperature_C__c'},
    { label: 'Capacity (tph)', fieldName: 'Capacity_tph__c'},
    { label: 'Trough Angle', fieldName: 'Trough_Angle_deg__c'},
    { label: 'Created Date', fieldName: 'CreatedDate', sortable: true},
    { label: 'Last Modifed Date', fieldName: 'LastModifiedDate', sortable: true}
];

export default class CloningOperatingParameters extends LightningElement {
    @api listOfOperatingParameters;
    @api selectedOperatingParameter;
    @api selectedBtn;
    @api prfRecTypeName
    columns;
    //columns = columns;
    multipleCheckboxSelected = false;
    defaultSortDirection = 'asc';
    sortDirection = 'asc';
    sortedBy;
    data;
    dataTableData;

    connectedCallback(){
        if(this.prfRecTypeName != ''){
            if(this.prfRecTypeName == 'Mill'){
                this.columns = columnsMill;
            }else if(this.prfRecTypeName == 'Hydrocyclone'){
                this.columns = columnsHydrocyclone;
            }else if(this.prfRecTypeName == 'Screen'){
                this.columns = columnsScreen;
            }else if(this.prfRecTypeName == 'Trommel'){
                this.columns = columnsTrommel;
            }else if(this.prfRecTypeName == 'Wear Component'){
                this.columns = columnsWC;
            }else if(this.prfRecTypeName == 'Conveyer Component'){
                this.columns = columnsCC;
            }
        }
        //this.data = JSON.parse(JSON.stringify(listOfOperatingParameters));
        if(this.listOfOperatingParameters){
            //this.data = this.listOfOperatingParameters;
            this.data = JSON.parse(JSON.stringify(this.listOfOperatingParameters));
            this.data.forEach(item => item['linkName'] = '/lightning/r/Operating_Parameters__c/' + item['Id'] + '/view');
            this.dataTableData = this.data;
        }
    }


    sortBy(field, reverse, primer) {
        const key = primer
            ? function (x) {
                  return primer(x[field]);
              }
            : function (x) {
                  return x[field];
              };

        return function (a, b) {
            a = key(a);
            b = key(b);
            return reverse * ((a > b) - (b > a));
        };
    }

    onHandleSort(event) {
        const { fieldName: sortedBy, sortDirection } = event.detail;
        const cloneData = [...this.listOfOperatingParameters];

        cloneData.sort(this.sortBy(sortedBy, sortDirection === 'asc' ? 1 : -1));
        this.listOfOperatingParameters = cloneData;
        this.sortDirection = sortDirection;
        this.sortedBy = sortedBy;
    }

    getSelectedRec() {
        var selectedRecords =  this.template.querySelector("lightning-datatable").getSelectedRows();
        if(selectedRecords.length === 1){
            console.log('selectedRecords are ', selectedRecords);
            let ids = '';
            selectedRecords.forEach(currentItem => {
                ids = ids + ',' + currentItem.Id;
            });
            this.selectedIds = ids.replace(/^,/, '');
            this.lstSelectedRecords = selectedRecords;
            this.selectedOperatingParameter = this.selectedIds;
            this.selectedBtn = 'Clone';
            //alert(this.selectedIds);
            const navigateNextEvent = new FlowNavigationNextEvent();
            this.dispatchEvent(navigateNextEvent);
        }else{
            console.log("More than 1");
            this.multipleCheckboxSelected = true;
            console.log("multipleCheckboxSelected ",this.multipleCheckboxSelected);
        } 
    }

    getSelectedRec2() {
        var selectedRecords =  this.template.querySelector("lightning-datatable").getSelectedRows();
        console.log('length of selected rows ',selectedRecords.length);
        if(selectedRecords.length === 1){
            console.log('selectedRecords are ', selectedRecords);
            let ids = '';
            selectedRecords.forEach(currentItem => {
                ids = ids + ',' + currentItem.Id;
            });
            this.selectedIds = ids.replace(/^,/, '');
            this.lstSelectedRecords = selectedRecords;
            this.selectedOperatingParameter = this.selectedIds;
            this.selectedBtn = 'Tag';
            //alert(this.selectedIds);
            const navigateNextEvent = new FlowNavigationNextEvent();
            this.dispatchEvent(navigateNextEvent);
        }else{
            console.log("More than 1");
            this.multipleCheckboxSelected = true;
            console.log("multipleCheckboxSelected ",this.multipleCheckboxSelected);
        }  
    }  
}