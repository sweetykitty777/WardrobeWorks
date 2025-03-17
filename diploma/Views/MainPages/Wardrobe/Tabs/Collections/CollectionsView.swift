import SwiftUI

struct CollectionsView: View {
    @State private var collections: [Collection] = MockData.collections
    @State private var showingNewCollectionSheet = false
    @State private var editingCollectionID: UUID?

    var body: some View {
        NavigationView {
            VStack {
                List {
                    ForEach($collections, id: \.id) { $collection in
                        HStack {
                            if editingCollectionID == collection.id {
                                TextField("Название лукбука", text: $collection.name, onCommit: {
                                    editingCollectionID = nil
                                })
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .padding(.trailing, 10)

                                Button(action: {
                                    editingCollectionID = nil
                                    hideKeyboard()
                                }) {
                                    Image(systemName: "checkmark.circle.fill")
                                        .foregroundColor(.green)
                                }
                            } else {

                                NavigationLink(destination: CollectionDetailView(collection: $collection)) {
                                    Text(collection.name)
                                        .font(.headline)
                                        .padding(.vertical, 5)
                                }

                                Spacer()

                                Button(action: {
                                    editingCollectionID = collection.id
                                }) {
                                    Image(systemName: "pencil.circle.fill")
                                        .foregroundColor(.blue)
                                }
                                .buttonStyle(BorderlessButtonStyle())
                            }
                        }
                    }
                    .onDelete { indexSet in
                        collections.remove(atOffsets: indexSet)
                    }
                }
                .listStyle(PlainListStyle())

                Button(action: {
                    showingNewCollectionSheet = true
                }) {
                    HStack {
                        Image(systemName: "plus.circle.fill")
                        Text("Добавить новый лукбук")
                    }
                    .font(.headline)
                    .foregroundColor(.blue)
                    .padding()
                }
            }
            .sheet(isPresented: $showingNewCollectionSheet) {
                NewCollectionView(collections: $collections, isPresented: $showingNewCollectionSheet)
            }
        }
    }


    private func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}
