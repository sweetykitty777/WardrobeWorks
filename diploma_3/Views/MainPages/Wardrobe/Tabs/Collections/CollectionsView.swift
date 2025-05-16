import SwiftUI

struct CollectionsView: View {
    @State private var collections: [Collection] = MockData.collections
    @State private var showingNewCollectionSheet = false
    @State private var editingCollectionID: UUID?

    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                ScrollView {
                    LazyVStack(spacing: 12) {
                        ForEach($collections, id: \.id) { $collection in
                            LookbookListItemView(
                                title: collection.name,
                                subtitle: "Мок Дата",
                                onEdit: {
                                    editingCollectionID = collection.id
                                },
                                isEditing: editingCollectionID == collection.id,
                                textFieldText: $collection.name,
                                onCommit: {
                                    editingCollectionID = nil
                                }
                            )
                            .padding(.horizontal)
                        }
                    }
                    .padding(.top)
                }

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
            .navigationBarHidden(true)
        }
        .sheet(isPresented: $showingNewCollectionSheet) {
            NewCollectionView(collections: $collections, isPresented: $showingNewCollectionSheet)
        }
    }
}
