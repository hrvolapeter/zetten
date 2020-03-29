# Zetten

Zetten is a note taking app based on Zettelkasten Method where notes form tree structure where ideas can
be indefinetly explored to more detailed notes.

Zetten is build on top of Google Firebase engine and SwitfUI introduced in 2019. Firebase is used for securely storing and
synchronizing notes acros multiple devices with soft real-time guarantess.

SwiftUI is a novel approach to writing composable native application using Swift and targeting Apple's Catalyst platform where
you get support for both Mac OS and iOS devices out of the box. SwiftUI choses similar approach to view composition as React making developing natively looking views significantly simpler

<img src="https://github.com/hrvolapeter/zetten/blob/master/images/mac_tree.png" 
alt="Mac OS tree" width="500"/>
<img src="https://github.com/hrvolapeter/zetten/blob/master/images/simulator_list.png" 
alt="iOS list" width="160"/>

## Compilation
1. Create [Firebase account](https://firebase.google.com), create new project and download `GoogleService-Info.plist` file into the root of Zetten
2. In your Firebase account create a new Cloud Firestore database with the following rules:
    ```
    rules_version = '2';
    service cloud.firestore {
      match /databases/{database}/documents {
        match /notes/{noteId} {
          function isSignedIn() {
            return request.auth.uid != null;
          }
          allow read, update: if isSignedIn() && request.auth.uid == resource.data.userId;
          allow create: if isSignedIn();    }
      }
    }
    ```
3. Create Note collection in Firestore with id `notes`. When creating colleciton you need to provide one document to infer the format.
   The current format of notes is:
   ```
    content: ""
    createdTime: March 19, 2020 at 11:22:50 PM UTC+1
    id: "6D12EB88-3884-4944-B1F9-DF2B6A2544D1"
    parentId: "71ED0AAD-7937-4311-B4A7-52D7E4E37474"
    tags: ["tag"]
    title: "Bug 2"
    userId: "nv7IZa2YMha1vdtaubBXFa4s54v2"
   ```
4. Compile Zetten in Xcode
5. After the first run you will see errors from Firestore in the application console with links. Copy the link to your browser
   and follow the steps to creater required incides for the database
6. Now you are good to run 🏃‍♂️

### What does Zetten mean?
Everyone referring to Zettelkasten method seems to be using the German name, which in translation simply means Note box. When I was looking for a name for the app at first I wanted to simply call it Zettelkasten, however, Zettelkasten is a fairly long name and doesn't look good on visual materials. After playing with a word for a while I've come up with a shorter version - Zetten from simply omitting the middle part of the word; Zett(elkast)en. Some research showed Zetten means typesetting in Dutch and is also a Dutch city.
