import { LightningElement, api, wire, track } from 'lwc';
import SearchContacts from '@salesforce/apex/RelateSearchContactController.SearchContacts';
import FirstName from '@salesforce/schema/Contact.FirstName';
import LastName from '@salesforce/schema/Contact.LastName';
import Email from '@salesforce/schema/Contact.Email';
import Phone from '@salesforce/schema/Contact.Phone';
import CreateContacts from '@salesforce/apex/RelateSearchContactController.CreateContacts';
import { NavigationMixin } from 'lightning/navigation';

const columns = [
    { label: 'Name', fieldName: 'Name', type: 'button',
    typeAttributes: {label: { fieldName: 'Name' }, variant: 'base',
    target: '_blank'}, },
    
    { label: 'Phone', fieldName: 'Phone', type: 'phone' },
    { label: 'Email', fieldName: 'Email', type: 'email' },
]

export default class SearchContact extends NavigationMixin(LightningElement) {
    @api recordId;
    @track error;
    @track data = [];
    @track columns = columns;
    @track rowOffSet=0;
    @track searchString;
    @track initialRecords = [];
    @track flag = false;
    @track flagContact = false;
    @track name;
    @track email;
    @track phone;
    @track contactid;
    @track flagbutton = false;
    @track contactRecord = {
        FirstName : FirstName,
        LastName : LastName,
        Email : Email,
        Phone : Phone
       }
    

    handleSave(event) {
        
        console.log(this.contactRecord.AccountId);
        CreateContacts({ id1 : this.recordId, con: this.contactRecord })
        .then(result => {
            // Clear the user enter values
            this.flagContact = false;
            this.contactRecord.FirstName = '';
            this.contactRecord.LastName = '';
            this.contactRecord.Email = '';
            this.contactRecord.Phone = '';
            refreshApex(this.wiredContacts);
            window.console.log('result ===> '+result);
            // Show success messsage
            this.dispatchEvent(new ShowToastEvent({
                title: 'Success!!',
                message: 'Contact Created',
                variant: 'success'
            }),);
        })
        .catch(error => {
            this.error = error.message;
        });
    }


    handleRowAction(event){
        this.flagbutton = true;
        const actionName = event.detail.action.name;
        const row = event.detail.row;
        this.contactid = row.Id;
        this.name = row.Name;
        this.email = row.Email;
        this.phone = row.Phone;

    }
 
    handleFirstName(event){
        this.contactRecord.FirstName = event.detail.value;
    }
    handleLastName(event){
        this.contactRecord.LastName = event.detail.value;
    }
    handleEmail(event){
        this.contactRecord.Email = event.detail.value;
    }
    handlePhone(event){
        this.contactRecord.Phone = event.detail.value;
    }
    handleClick(event) {

        if(event.target.label == 'Close'){
            this.flagbutton = false;
            this.flag = false;
            this.flagContact = false;
            this.name = '';
            this.email = '';
            this.phone = '';
            this.rowOffSet = 0;
            this.data = [];
            this.initialRecords = [];
            this.loadData();

        }else if(event.target.label == 'Create'){
            this.flagContact = true;
        }else if(event.target.label == 'Search'){
            this.flag = true;
        }
    }

     handleSearch(event){

        const searchKey = event.target.value.toLowerCase();
        console.log(searchKey);
        if (searchKey && searchKey.length>=3) {
        
 
            if (this.data) {
                let searchRecords = [];
 
                for (let record of this.data) {
                    let valuesArray = Object.values(record);
 
                    for (let val of valuesArray) {
             
                        let strVal = String(val);
 
                        if (strVal) {
 
                            if (strVal.toLowerCase().includes(searchKey)) {
                                searchRecords.push(record);
                                break;
                            }
                        }
                    }
                }
 
          
                this.data = searchRecords;
            }
        } else {
            this.data = this.initialRecords;
        }
    }

    handleUrl(){
        console.log(this.contactid);
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: this.contactid,
                objectApiName: 'PersonAccount',
                actionName: 'view'
            }
        }, false 
    );
    }
    handleClose(){
        this.flagContact = false;
        this.contactRecord.FirstName = '';
        this.contactRecord.LastName = '';
        this.contactRecord.Email = '';
        this.contactRecord.Phone = '';
    }
    connectedCallback() {
        this.loadData();
        console.log(this.initialRecords);
    }

    loadData(){
        return  SearchContacts({ idacc : this.recordId ,  offSetCount : this.rowOffSet })
        .then(result => {
            let updatedRecords = [...this.data, ...result];
            let updatedRecords1 = [...this.initialRecords, ...result];
            this.data = updatedRecords;
            this.initialRecords = updatedRecords1;
            this.error = undefined;
        })
        .catch(error => {
            this.error = error;
            this.data = undefined;
        });
    }

    loadMoreData(event) {
        const currentRecord = this.accounts;
        const { target } = event;
        target.isLoading = true;

        this.rowOffSet = this.rowOffSet + 2;
        this.loadData()
            .then(()=> {
                target.isLoading = false;
            });   
    }


    formatBytes(bytes,decimals) {
        if(bytes == 0) return '0 Bytes';
        var k = 1024,
            dm = decimals || 2,
            sizes = ['Bytes', 'KB', 'MB', 'GB', 'TB', 'PB', 'EB', 'ZB', 'YB'],
            i = Math.floor(Math.log(bytes) / Math.log(k));
        return parseFloat((bytes / Math.pow(k, i)).toFixed(dm)) + ' ' + sizes[i];
    }

}