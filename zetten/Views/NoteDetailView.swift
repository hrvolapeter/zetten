//
//  NoteDetail.swift
//  zetten
//
//  Created by Peter Hrvola on 08/03/2020.
//  Copyright © 2020 Peter Hrvola. All rights reserved.
//

import SwiftUI
import UIKit

/// View generating note detail
struct NoteDetailView: View {
    @ObservedObject var vm: ViewModel
    @State var showingActionSheet = false
    @State var isShowingMetadataView = false
    @State var isShowingTreeView = false
    
    var body: some View {
        ScrollView {
            VStack {
                TextField("Title", text: $vm.note.title)
                    .font(.title)
                TypeaheadTextField("Tags", text: $vm.tagsField, typeahead: $vm.typeahead, onCommit: vm.addTag)
                    .font(.callout)
                tags
                MultilineTextField(text: $vm.note.content)
                
                NavigationLink(
                    destination: NoteDetailMetadataView(vm: self.vm),
                    isActive: $isShowingMetadataView,
                    label: { EmptyView() }
                )
                NavigationLink(
                    destination: TreeView(vm: .init(note: self.vm.note)),
                    isActive: $isShowingTreeView,
                    label: { EmptyView() }
                )
            }.padding()
            
        }.navigationBarTitle("", displayMode: .inline)
            .navigationBarItems(trailing: barItems)
            .onDisappear {
                logger.debug("Dissapearing\(self.vm.note.id): \(self.vm.note.title)")
                self.vm.onDisapper()
        }.onAppear(perform: self.vm.onAppear)
    }
    
    var tags: some View {
        ScrollView(.horizontal) {
            HStack {
                ForEach(vm.note.tags, id: \.self) { tag in
                    HStack {
                        Text(tag).font(.footnote)
                        Button(action: { self.vm.removeTag(tag) }) {
                            Image(systemName: "xmark.circle.fill")
                        }
                    }.padding(7).lineLimit(1).background(Color.accentColor).foregroundColor(.white)
                        .cornerRadius(10)
                    
                }
            }
        }
    }
    
    // Actionsheet menu for metadata
    var barItems: some View {
        Button(action: {
            self.showingActionSheet.toggle()
        }) {
            Image(systemName: "ellipsis.circle")
                .resizable()
                .frame(width: 25, height: 25)
        }.popSheet(isPresented: $showingActionSheet) {
            PopSheet(
                title: Text(""),
                buttons: [
                    .default(
                        Text("Info"),
                        action: { self.isShowingMetadataView.toggle() }
                    ),
                    .default(
                        Text("Tree"),
                        action: { self.isShowingTreeView.toggle() }
                    ),
                    .cancel(),
                ]
            )
        }
    }
    
}

struct NoteDetail_Previews: PreviewProvider {
    static var previews: some View {
        NoteDetailView(vm: .init(note: notePreview))
    }
}
