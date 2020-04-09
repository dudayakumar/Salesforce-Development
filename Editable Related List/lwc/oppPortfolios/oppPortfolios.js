/* eslint-disable @lwc/lwc/no-async-operation */
/* eslint-disable no-console */
import { LightningElement, track, wire, api } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

// importing apex class methods
import fetchPortfoliosFromOpps from '@salesforce/apex/OppPortfoliosController.getPortfoliosForOpp';
import savePortfolios from '@salesforce/apex/OppPortfoliosController.savePortfolios';

export default class OppPortfolios2 extends LightningElement {

    @track isEdited = false;
    @track toggleSaveLabel = 'Save';
    @api recordId;
    @api fieldName;
    @api objectName;
	@track fieldLabelName;
    @track pfList = [];
    @track originalPfList = [];

    _wiredResult;
    @wire(fetchPortfoliosFromOpps, { recordId: "$recordId" })
    wiredCallback(result) {
        this._wiredResult = result;
        if (result.data) {
            this.pfList = result.data;
            this.originalPfList = result.data;
            this.error = undefined;
        } 
        else if (result.error) {
            this.error = result.error;
            this.pfList = undefined;
            this.originalPfList = undefined;
        }
    }

    handleNumberChange(event){
        let newValue = event.detail.value;
        let fieldId = event.target.dataset.id;
        let uniqueKey = event.target.dataset.key;
        let tempPfList  = JSON.parse(JSON.stringify(this.pfList));

        tempPfList.map(e =>{
            
            if(e.Id === uniqueKey){
                if(fieldId === "Equity_Target__c")
                    e.Equity_Target__c = newValue;
                else if(fieldId === "Bond_Target__c")
                    e.Bond_Target__c = newValue;
                else if(fieldId === "Cash_Target__c")
                    e.Cash_Target__c = newValue;
            }    
        })

        this.pfList = tempPfList;
    }

    handleTextChange(event){
        let newValue = event.detail.value;
        let fieldId = event.target.dataset.id;
        let uniqueKey = event.target.dataset.key;
        let tempPfList  = JSON.parse(JSON.stringify(this.pfList));

        tempPfList.map(e =>{
            if(e.Id === uniqueKey){
                if(fieldId === "Fee_Schedule__c")
                    e.Fee_Schedule__c = newValue;
                else if(fieldId === "Who_Receives_Reporting__c")
                    e.Who_Receives_Reporting__c = newValue;
                else if(fieldId === "Restricted_Data__c")
                    e.Restricted_Data__c = newValue;
            }
        })

        this.pfList = tempPfList;
    }

    handlePicklistChange(event){
        let pickValue = event.detail.selectedValue;
        let uniqueKey = event.detail.key;
        let fieldId = event.target.dataset.id;

        let tempPfList  = JSON.parse(JSON.stringify(this.pfList));

        tempPfList.map(e =>{
            if(e.Id === uniqueKey){
                if(fieldId === 'Registration_Type__c')
                    e.Registration_Type__c = pickValue;
                else if(fieldId === 'Fee_Type__c')
                    e.Fee_Type__c = pickValue;
                else if(fieldId === 'Discretionary__c')
                    e.Discretionary__c = pickValue;
                else if(fieldId === 'Billing_In__c')
                    e.Billing_In__c = pickValue;
                else if(fieldId === 'Proxy_Voting_by_Us__c')
                    e.Proxy_Voting_by_Us__c = pickValue;
                else if(fieldId === 'Revenue_Source__c')
                    e.Revenue_Source__c = pickValue;
                else if(fieldId === 'ManagedNew__c')
                    e.ManagedNew__c = pickValue;
            }
        })

        this.pfList = tempPfList;
    }

    handleChange(event){
        const inputFields = this.template.querySelectorAll('lightning-input-field');
        
        let tempPfList  = JSON.parse(JSON.stringify(this.pfList));

        inputFields.forEach(field => {
            let pfId = field.name;
            let custodianId = field.value;

            tempPfList.map(e =>{
                if(e.Id === pfId){
                    e.Custodian__c = custodianId;
                }
            })
        });

        this.pfList = tempPfList;
    }

    onDoubleClickEdit() {
        this.isEdited = true;
    }

    handleSave(){
        this.toggleSaveLabel = 'Saving...';
        let toSaveList = this.pfList;
        toSaveList.forEach((element, index) => {
            if(element.Name === ''){
                toSaveList.splice(index, 1);
            }
        });

        this.pfList = toSaveList;
        savePortfolios({records : toSaveList})
        .then(() => {
            this.toggleSaveLabel = 'Saved';
            
            this.dispatchEvent(
                new ShowToastEvent({
                    title : 'Success',
                    message : `Portfolios saved succesfully!`,
                    variant : 'success',
                }),
            )
            this.isEdited = false;
            this.error = undefined;
        })
        .catch(error => {
            this.error = error;
            this.record = undefined;
            this.dispatchEvent(
                new ShowToastEvent({
                    title : 'Error',
                    message : error.body.pageErrors[0].message,
                    variant : 'error',
                }),
            )
        })
        .finally(() => {
            setTimeout(() => {
                this.toggleSaveLabel = 'Save';
            }, 3000);
        });
    }

    handleCancel() {
        this.pfList = this.originalPfList;
        this.isEdited = false;
    }
}