import SwiftUI

struct CollectionsView: View {
    @State private var collections: [LookbookResponse] = []
    @State private var showingNewCollection = false
    @State private var editingCollection: LookbookResponse? = nil

    var wardrobeId: Int

    var body: some View {
        VStack(spacing: 0) {
            ScrollView {
                if collections.isEmpty {
                    Text("У вас пока нет лукбуков")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                        .padding()
                } else {
                    LazyVStack(spacing: 12) {
                        ForEach(collections, id: \.id) { collection in
                            NavigationLink(value: collection) {
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
            }

            Divider()

            Button(action: {
                showingNewCollection = true
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
        .navigationDestination(for: LookbookResponse.self) { collection in
            LookbookDetailView(lookbook: collection, wardrobeId: collection.wardrobeId)
        }
        .navigationBarHidden(true)
        .onAppear {
            fetchLookbooks(for: wardrobeId)
        }
        .onChange(of: wardrobeId) { newId in
            fetchLookbooks(for: newId)
        }
        .fullScreenCover(isPresented: $showingNewCollection) {
            NavigationStack {
                NewCollectionView(
                    onCreate: {
                        fetchLookbooks(for: wardrobeId)
                    },
                    isPresented: $showingNewCollection
                )
            }
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
        WardrobeService.shared.fetchLookbooks(for: wardrobeId) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let fetched):
                    collections = fetched
                case .failure(let error):
                    print("Ошибка загрузки лукбуков: \(error)")
                }
            }
        }
    }
}
