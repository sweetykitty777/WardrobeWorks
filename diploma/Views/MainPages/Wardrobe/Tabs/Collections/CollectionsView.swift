import SwiftUI

struct CollectionsView: View {
    @State private var collections: [LookbookResponse] = []
    @State private var showingNewCollectionSheet = false
    @State private var editingCollection: LookbookResponse? = nil
    
    var wardrobeId: Int

    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                ScrollView {
                    LazyVStack(spacing: 12) {
                        ForEach(collections, id: \.id) { collection in
                            NavigationLink {
                                LookbookDetailView(lookbook: collection, wardrobeId: wardrobeId)
                            } label: {
                                LookbookListItemView(
                                    title: collection.name,
                                    subtitle: collection.description,
                                    onEdit: {
                                        editingCollection = collection
                                    }
                                )
                                .padding(.horizontal)
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                    }
                    .padding(.top)
                }

                Divider()

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
            .onAppear {
                fetchLookbooks(for: wardrobeId)
            }
        }
        .sheet(isPresented: $showingNewCollectionSheet) {
            NewCollectionView(
                onCreate: {
                    fetchLookbooks(for: wardrobeId)
                },
                isPresented: $showingNewCollectionSheet
            )
        }
        .sheet(item: $editingCollection) { collection in
            EditLookbookView(
                lookbookId: collection.id,
                initialName: collection.name,
                initialDescription: collection.description,
                onSave: {
                    fetchLookbooks(for: wardrobeId)
                },
                onDelete: {
                    fetchLookbooks(for: wardrobeId)
                }
            )
        }

    }

    private func fetchLookbooks(for wardrobeId: Int) {
        LookbookService.shared.fetchLookbooks(for: wardrobeId) { result in
            switch result {
            case .success(let fetched):
                collections = fetched
            case .failure(let error):
                print("Ошибка загрузки лукбуков: \(error)")
            }
        }
    }
}
