//
//  ContactList.h
//  ContactsList
//
//  Created by Reinier Isalgue on 12/06/17.
//  Copyright © 2017 MyGroup. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AddressBook/AddressBook.h> //AddressBook.framework for below iOS 9
#import <Contacts/Contacts.h> //Contacts.framework for above iOS 9

@interface ContactList : NSObject{
    
    NSMutableArray *totalPhoneNumberArray; //Total Mobile Contacts from access from this variable
    
    NSMutableArray *groupsOfContact; //Collection of contacts by using contacts.framework
    NSArray *arrayOfAllPeople; //Collection of contacts by using  AddressBook.framework
    
    ABAddressBookRef addressBook; //Address Book Object
    
    CNContactStore *contactStore; //ContactStore Object
}

@property (nonatomic,retain) NSMutableArray *totalPhoneNumberArray; //Total Mobile Contacts access from this variable property

//fetch Contact shared instance method
+(id)sharedContacts; //Singleton method

///fetch contacts from Addressbooks or Contacts framework
-(void)fetchAllContacts; //Method of fetch contacts from Addressbooks or Contacts framework

@end



