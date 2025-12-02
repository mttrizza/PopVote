import SwiftUI
import SwiftData
import PhotosUI

struct EditFolderView: View {
    
    @Bindable var folder: Folder
    @Environment(\.dismiss) private var dismiss
    
    @State private var folderName: String
    @State private var selectedPosterItem: PhotosPickerItem?
    @State private var selectedPosterData: Data?
    
    init(folder: Folder) {
        self.folder = folder
        _folderName = State(initialValue: folder.name)
        _selectedPosterData = State(initialValue: folder.iconData)
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                
                // --- Image Picker ---
                PhotosPicker(selection: $selectedPosterItem, matching: .images, photoLibrary: .shared()) {
                    VStack {
                        if let data = selectedPosterData, let uiImage = UIImage(data: data) {
                            Image(uiImage: uiImage)
                                .resizable().scaledToFill()
                                .frame(width: 120, height: 120)
                                .clipShape(RoundedRectangle(cornerRadius: 15))
                        } else {
                            Image(systemName: "folder.fill")
                                .font(.system(size: 80))
                                .foregroundColor(.gray)
                                .frame(width: 120, height: 120)
                                .background(Color.gray.opacity(0.1))
                                .clipShape(RoundedRectangle(cornerRadius: 15))
                        }
                        Text("Change Icon").font(.caption).foregroundColor(.blue)
                    }
                }
                .padding(.top, 30)
                .onChange(of: selectedPosterItem) {
                    Task {
                        if let data = try? await selectedPosterItem?.loadTransferable(type: Data.self) {
                            selectedPosterData = data
                        }
                    }
                }
                
                // --- Nome Cartella ---
                TextField("Folder Name", text: $folderName)
                    .textFieldStyle(.roundedBorder)
                    .padding(.horizontal)
                
                Spacer()
            }
            .background(Color(red: 0.95, green: 0.85, blue: 0.75))
            .navigationTitle("Edit Folder")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Save") {
                        folder.name = folderName
                        folder.iconData = selectedPosterData
                        dismiss()
                    }
                    .disabled(folderName.isEmpty)
                }
            }
        }
    }
}
