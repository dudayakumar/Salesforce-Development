/* eslint-disable no-console */
import { LightningElement, track, wire, api } from 'lwc';
import { getPicklistValuesByRecordType } from 'lightning/uiObjectInfoApi';
import { getObjectInfo } from 'lightning/uiObjectInfoApi';
import { CurrentPageReference } from 'lightning/navigation';

export default class Picklist extends LightningElement {
    
    @wire(CurrentPageReference) pageRef;

    @api objectApiName;
    @api pickListfieldApiName;
    @api label;
    @api variant;
    @api uniqueKey;

    @track value;
    recordTypeIdValue;
    @track options = [];
    
    @api 
    get recordTypeId() {
        return this.recordTypeIdValue;
    }
    set recordTypeId(value) {
        this.recordTypeIdValue = value;
    }

    @api 
    get selectedValue() {
        return this.value;
    }
    set selectedValue(val) {
        if (val === '' || val === undefined || val === null)
            this.value = { label: '--None--', value: "" }.value;
        else
            this.value = val;
    }
         

    @wire(getObjectInfo, { objectApiName: '$objectApiName' })
    getRecordTypeId({ error, data }) {
        if (data) {
            this.record = data;
            this.error = undefined;
            if(this.recordTypeId === undefined){
                this.recordTypeId = this.record.defaultRecordTypeId;
            }
        } else if (error) {
            this.error = error;
            this.record = undefined;
        }
    }
                     
    @wire(getPicklistValuesByRecordType, { recordTypeId: '$recordTypeId', objectApiName: '$objectApiName' })
    wiredOptions({ error, data }) {
        if (data) {
            this.record = data;
            this.error = undefined;
            
            if(this.record.picklistFieldValues[this.pickListfieldApiName] !== undefined) {

                let tempOptions = [{ label: '--None--', value: "" }];
                let temp2Options = this.record.picklistFieldValues[this.pickListfieldApiName].values;
                temp2Options.forEach(opt => tempOptions.push(opt));

                this.options = tempOptions;
            }
            
            if(this.selectedValue === '' || this.selectedValue === undefined || this.selectedValue === null) {
                this.value = { label: '--None--', value: "" }.value;
            } else {
                this.value = this.options.find(listItem => listItem.value === this.selectedValue).value;
            }
        } else if (error) {
            this.error = error;
            this.record = undefined;
        }
    }


    handleChange(event) {
        let tempValue = event.target.value;
        let selectedValue = tempValue;
        let key = this.uniqueKey;

        const pickValueChangeEvent = new CustomEvent('picklistchange', {
            detail: { selectedValue, key },
        });
        this.dispatchEvent(pickValueChangeEvent);
    }

}