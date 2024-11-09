//
//  ContentView.swift
//  ToDoListInSwiftUI
//
//  Created by h-chaya on 2024/11/09.
//

import SwiftUI

struct ToDoModel: Identifiable, Equatable, Codable {
    var id: UUID
    var title: String
    var body: String
}

func encode(_ models: [ToDoModel]) throws -> Data {
    do {
        let data = try JSONEncoder().encode(models)
        return data
    } catch {
        throw error
    }
}

func decode(_ data: Data) throws -> [ToDoModel] {
    do {
        let model = try JSONDecoder().decode([ToDoModel].self, from: data)
        return model
    } catch {
        throw error
    }
}

struct ContentView: View {
    @State private var toDoModels: [ToDoModel] = []

    @State private var isShowAddView: Bool = false

    @AppStorage("TODODATA") private var toDoDatas: Data?

    init() {
        self._toDoModels = State(initialValue: initToDoModels)
    }

    var body: some View {
        NavigationStack {
            List($toDoModels) { $todo in
                NavigationLink {
                    DetailView(title: $todo.title, textEditorBody: $todo.body) {
                        delete(todo.id)
                    }
                } label: {
                    Text(todo.title)
                }
                .swipeActions(edge: .trailing) {
                    Button {
                        delete(todo.id)
                    } label: {
                        Image(systemName: "trash.fill")
                    }
                    .tint(.red)
                }
            }
            .navigationTitle("ToDoList")
            .toolbar {
//                ToolbarItem(placement: .navigationBarTrailing) {
//                    Button("Clear") {
//                        toDoModels.removeAll()
//                    }
//                }
            }
            .overlay(alignment: .bottomTrailing) {
                CircleButton("plus") {
                    isShowAddView = true
                }
            }
        }
        .sheet(isPresented: $isShowAddView) {
            AddView() { title, body in
                toDoModels.append(ToDoModel(id: UUID(), title: title, body: body))
                isShowAddView = false
            }
            .presentationDetents([.large, .medium])
        }
        .onChange(of: toDoModels) {
            do {
                let data = try encode(toDoModels)

                toDoDatas = data
            } catch {
                print(error.localizedDescription)
            }
        }
    }

    var initToDoModels: [ToDoModel] {
        do {
            guard let toDoDatas = toDoDatas else { return [] }
            return try decode(toDoDatas)
        } catch {
            print(error.localizedDescription)
            return []
        }
    }

    func delete(_ id: UUID) {
        if let deleteIndex = toDoModels.firstIndex(where: { $0.id == id }) {
            toDoModels.remove(at: deleteIndex)
        }
    }
}

struct DetailView: View {
    @Environment(\.dismiss) var dismiss
    @Binding var title: String
    @Binding var textEditorBody: String

    var delete: () -> ()
    var body: some View {
        VStack {
            TextField("TITLE", text: $title)
            TextEditor(text: $textEditorBody)
        }
        .padding()
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    delete()
                    dismiss()
                } label: {
                    Image(systemName: "trash.fill")
                }
                .tint(.red)
            }
        }
    }
}

struct AddView: View {
    @State private var title: String = ""
    @State private var textEditorBody: String = ""

    var add: (String, String) -> ()
    var body: some View {
        VStack {
            TextField("TITLE", text: $title)
            TextEditor(text: $textEditorBody)
        }
        .padding()
        .overlay(alignment: .bottomTrailing) {
            CircleButton("plus") {
                add(title, textEditorBody)
            }
            .opacity(title.isEmpty ? 0.5 : 1)
        }

    }
}

@ViewBuilder func CircleButton(_ symbol: String, action: @escaping () -> ()) -> some View {
    Button {
        action()
    } label: {
        Image(systemName: symbol)
            .foregroundStyle(.background)
            .font(.title)
            .padding()
            .background(.primary, in: .circle)
    }
    .foregroundStyle(.primary)
    .padding()
}

#Preview {
    ContentView()
}
