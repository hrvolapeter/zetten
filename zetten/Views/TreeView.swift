//
//  TreeView.swift
//  zetten
//
//  Created by Peter Hrvola on 18/03/2020.
//  Copyright © 2020 Peter Hrvola. All rights reserved.
//

import SwiftUI

struct TreeView: View {
  @ObservedObject var vm: ViewModel

  typealias Key = CollectDict<Note.ID, Anchor<CGPoint>>

  var body: some View {
    VStack {
      SearchBar(text: $vm.searchTerm, placeholder: "Parent")
      Spacer()
      ZStack {
        ScrollView(.init(arrayLiteral: .horizontal, .vertical)) {
          tree
        }
        if vm.searchTerm.count != 0 {
          searchResult
        }
      }
      Spacer()

    }
  }

  var searchResult: some View {
    List {
      ForEach(vm.searchResult) { note in
        Button(action: {
          self.vm.searchTerm = ""
          DispatchQueue.main.async {
            self.vm.changeParent(parent: note, childId: self.vm.note.id)
          }

        }) {
          Text(note.title)
        }
      }
    }
  }

  var tree: some View {
    ForEach(vm.tree, id: \.hashValue) { level in
      HStack(alignment: .bottom, spacing: 10) {
        ForEach(level) { note in
          self.node(note: note)
        }
      }
    }.onAppear(perform: vm.onAppear)
      .onDisappear(perform: vm.onDisappear)
      .backgroundPreferenceValue(
        Key.self,
        { (centers: [Note.ID: Anchor<CGPoint>]) in
          self.geometry_reader(centers: centers)
        }).navigationBarTitle("Hierarchy")
  }

  func geometry_reader(centers: [Note.ID: Anchor<CGPoint>]) -> some View {
    GeometryReader { proxy in
      ForEach(self.vm.tree, id: \.hashValue) { level in
        ForEach(level) { note in
          Group {
            if note.parentId != nil && centers[note.parentId!] != nil {
              Line(
                from: proxy[centers[note.parentId!]!],
                to: proxy[centers[note.id]!]
              ).stroke()
                .foregroundColor(.accentColor)
            }
          }

        }
      }
    }
  }

  func node(note: Note) -> some View {
    Text(note.title)
      .padding(5)
      .background(Color.accentColor)
      .if(note == self.vm.note) {
        $0.background(Color.green)
      }
      .foregroundColor(.white)
      .cornerRadius(100)
      .lineLimit(1)
//      .onDrag {
//        NSItemProvider(object: note.id as NSString)
//      }.onDrop(of: NSString.writableTypeIdentifiersForItemProvider, isTargeted: nil) { providers in
//        guard let provider = providers.first
//        else { return false }
//        provider.loadItem(forTypeIdentifier: "public.utf8-plain-text", options: nil) {
//          item, error in
//          guard
//            let id = String(data: item as! Data, encoding: .utf8)
//          else { return }
//          self.vm.changeParent(parent: note, childId: id)
//        }
//
//        return true
//      }
      .padding(10)
      .anchorPreference(
        key: Key.self, value: .center,
        transform: {
          [note.id: $0]
        })
  }
}

struct Line: Shape {
  var from: CGPoint
  var to: CGPoint

  var animatableData: AnimatablePair<CGPoint, CGPoint> {
    get { AnimatablePair(from, to) }
    set {
      from = newValue.first
      to = newValue.second
    }
  }

  func path(in rect: CGRect) -> Path {
    Path { p in
      p.move(to: self.from)
      p.addLine(to: self.to)
    }
  }
}

extension CGPoint: VectorArithmetic {
  public static func -= (lhs: inout CGPoint, rhs: CGPoint) {
    lhs = lhs - rhs
  }

  public static func - (lhs: CGPoint, rhs: CGPoint) -> CGPoint {
    return CGPoint(x: lhs.x - rhs.x, y: lhs.y - rhs.y)
  }

  public static func += (lhs: inout CGPoint, rhs: CGPoint) {
    lhs = lhs + rhs
  }

  public mutating func scale(by rhs: Double) {
    x *= CGFloat(rhs)
    y *= CGFloat(rhs)
  }

  public static func + (lhs: CGPoint, rhs: CGPoint) -> CGPoint {
    return CGPoint(x: lhs.x + rhs.x, y: lhs.y + rhs.y)
  }

  public var magnitudeSquared: Double { return Double(x * x + y * y) }
}

struct CollectDict<Key: Hashable, Value>: PreferenceKey {
  static var defaultValue: [Key: Value] { [:] }

  static func reduce(value: inout [Key: Value], nextValue: () -> [Key: Value]) {
    value.merge(nextValue(), uniquingKeysWith: { $1 })
  }
}

struct TreeView_Previews: PreviewProvider {
  static var previews: some View {
    TreeView(vm: .init(note: notePreview))
  }
}
