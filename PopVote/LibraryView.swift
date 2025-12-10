import SwiftUI
import PhotosUI
import SwiftData

struct LibraryView: View {
    
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Folder.dateAdded) private var folders: [Folder]
    
    @State private var showingAddFolderSheet = false
    @State private var newFolderName = ""
    @State private var selectedPhotoItem: PhotosPickerItem?
    @State private var selectedPhotoData: Data?

    @State private var isSelectionMode = false
    @State private var selectedFolders = Set<PersistentIdentifier>()
    @State private var showDeleteConfirmation = false

    private var gridColumns: [GridItem] = [
        GridItem(.adaptive(minimum: 120))
    ]

    var body: some View {
        NavigationStack {
            ZStack {
                
                ScrollView {
                    LazyVGrid(columns: gridColumns, spacing: 20) {
                        
                        ForEach(folders) { folder in
                            ZStack {
                                VStack {
                                    if let data = folder.iconData, let uiImage = UIImage(data: data) {
                                        Image(uiImage: uiImage)
                                            .resizable()
                                            .scaledToFill()
                                            .frame(width: 100, height: 100)
                                            .clipShape(RoundedRectangle(cornerRadius: 10))
                                            .opacity(isSelectionMode && selectedFolders.contains(folder.id) ? 0.6 : 1.0)
                                    } else {
                                        Image(systemName: "folder.fill")
                                            .font(.system(size: 60))
                                            .foregroundColor(.gray.opacity(0.5))
                                            .frame(width: 100, height: 100)
                                            .background(Color.gray.opacity(0.1))
                                            .clipShape(RoundedRectangle(cornerRadius: 10))
                                            .opacity(isSelectionMode && selectedFolders.contains(folder.id) ? 0.6 : 1.0)
                                    }
                                    
                                    Text(folder.name)
                                        .font(Font.custom("HoltwoodOneSC-Regular", size: 12))
                                        .lineLimit(2)
                                        .multilineTextAlignment(.center)
                                        .foregroundColor(.primary)
                                }
                                .frame(width: 120)
                                
                                if isSelectionMode {
                                    VStack {
                                        HStack {
                                            Spacer()
                                            Image(systemName: selectedFolders.contains(folder.id) ? "checkmark.circle.fill" : "circle")
                                                .font(.title2)
                                                .foregroundColor(selectedFolders.contains(folder.id) ? .blue : .gray)
                                                .background(Circle().fill(.white))
                                        }
                                        Spacer()
                                    }
                                    .frame(width: 100, height: 100)
                                }
                                
                                if !isSelectionMode {
                                    NavigationLink(value: folder) {
                                        Color.clear
                                    }
                                } else {
                                    Button(action: {
                                        toggleSelection(for: folder)
                                    }) {
                                        Color.clear
                                    }
                                }
                            }
                        }
                    }
                    .padding()
                    .navigationDestination(for: Folder.self) { folder in
                        FolderDetailsView(folder: folder)
                    }
                    .padding(.top, 70)
                    .navigationTitle("Library")
                    .navigationBarTitleDisplayMode(.inline)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color(red: 0.95, green: 0.85, blue: 0.75))
                .edgesIgnoringSafeArea(.all)
            }

            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button(isSelectionMode ? "Done" : "Select") {
                        withAnimation {
                            isSelectionMode.toggle()
                            selectedFolders.removeAll()
                        }
                    }
                }
                
 
                ToolbarItem(placement: .topBarTrailing) {
                    if isSelectionMode {
                        Button(action: {
                            if !selectedFolders.isEmpty {
                                showDeleteConfirmation = true
                            }
                        }) {
                            Image(systemName: "trash")
                                .foregroundColor(selectedFolders.isEmpty ? .gray : .red)
                        }
                        .disabled(selectedFolders.isEmpty)
                    } else {
                        Button(action: {
                            showingAddFolderSheet = true
                        }) {
                            Image(systemName: "folder.badge.plus")
                                .foregroundColor(.black)
                        }
                    }
                }
            }
            
            .alert("Delete selected folders?", isPresented: $showDeleteConfirmation) {
                Button("Delete", role: .destructive) {
                    deleteSelected()
                }
                Button("Cancel", role: .cancel) { }
            } message: {
                Text("Movies inside these folders will not be deleted.")
            }
            
            .sheet(isPresented: $showingAddFolderSheet) {
                VStack(spacing: 20) {
                    Text("New Folder").font(.headline).padding(.top, 20)
                    PhotosPicker(selection: $selectedPhotoItem, matching: .images, photoLibrary: .shared()) {
                        VStack {
                            if let data = selectedPhotoData, let uiImage = UIImage(data: data) {
                                Image(uiImage: uiImage).resizable().scaledToFill().frame(width: 100, height: 100).clipShape(RoundedRectangle(cornerRadius: 10))
                            } else {
                                Image(systemName: "photo.badge.plus").font(.system(size: 60)).foregroundColor(.gray).frame(width: 100, height: 100).background(Color.gray.opacity(0.1)).clipShape(RoundedRectangle(cornerRadius: 10))
                            }
                            Text("Add icon").font(.caption).foregroundColor(.blue)
                        }
                    }
                    .onChange(of: selectedPhotoItem) {
                        Task {
                            if let data = try? await selectedPhotoItem?.loadTransferable(type: Data.self) {
                                selectedPhotoData = data
                            }
                        }
                    }
                    TextField("Folder Name", text: $newFolderName).textFieldStyle(.roundedBorder).padding(.horizontal)
                    Button("Save") {
                        let newFolder = Folder(name: newFolderName, iconData: selectedPhotoData)
                        modelContext.insert(newFolder)
                        newFolderName = ""; selectedPhotoItem = nil; selectedPhotoData = nil
                        showingAddFolderSheet = false
                    }
                    .buttonStyle(.borderedProminent).disabled(newFolderName.isEmpty)
                    Spacer()
                }
                .presentationDetents([.height(400)])
            }
        }
    }
    
    private func toggleSelection(for folder: Folder) {
        if selectedFolders.contains(folder.id) {
            selectedFolders.remove(folder.id)
        } else {
            selectedFolders.insert(folder.id)
        }
    }
    
    private func deleteSelected() {
        withAnimation {
            for folder in folders {
                if selectedFolders.contains(folder.id) {
                    modelContext.delete(folder)
                }
            }
            selectedFolders.removeAll()
            isSelectionMode = false 
        }
    }
}
