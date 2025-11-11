//
//  LibraryView.swift
//  PopVote
//
//  Created by Mattia Rizza on 31/10/25.
//

import SwiftUI
import PhotosUI
import SwiftData

struct LibraryView: View {
    
    // --- Variabili di Stato (invariate) ---
    @State private var showingAddFolderSheet = false
    @State private var newFolderName = ""
    @State private var selectedPhotoItem: PhotosPickerItem?
    @State private var selectedPhotoData: Data?

    // --- Integrazione SwiftData (invariata) ---
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Folder.dateAdded) private var folders: [Folder]
    
    // --- Layout Griglia (invariato) ---
    private var gridColumns: [GridItem] = [
        GridItem(.adaptive(minimum: 120))
    ]

    var body: some View {
        NavigationStack {
            // <<< MODIFICA: Lo ZStack non è più necessario per il pulsante,
            // ma lo teniamo per applicare il colore di sfondo a tutto schermo.
            ZStack {
                

                
                // --- GRIGLIA DELLE CARTELLE ---
                ScrollView {
                    LazyVGrid(columns: gridColumns, spacing: 20) {
                        
                        ForEach(folders) { folder in
                            NavigationLink(value: folder) {
                                VStack {
                                    if let data = folder.iconData, let uiImage = UIImage(data: data) {
                                        Image(uiImage: uiImage)
                                            .resizable()
                                            .scaledToFill()
                                            .frame(width: 100, height: 100)
                                            .clipShape(RoundedRectangle(cornerRadius: 10))
                                    } else {
                                        Image(systemName: "folder.fill")
                                            .font(.system(size: 60))
                                            .foregroundColor(.gray.opacity(0.5))
                                            .frame(width: 100, height: 100)
                                            .background(Color.gray.opacity(0.1))
                                            .clipShape(RoundedRectangle(cornerRadius: 10))
                                    }
                                    
                                    Text(folder.name)
                                        .font(Font.custom("HoltwoodOneSC-Regular", size: 12))
                                        .lineLimit(2)
                                        .multilineTextAlignment(.center)
                                        .foregroundColor(.primary)
                                }
                                .frame(width: 120)
                            } // <<< Fine NavigationLink
                        }
                    }
                    .padding() //modificare questo se voglio mettere 3 cartelle per fila 
                    
                    .navigationDestination(for: Folder.self) { folder in
                        FolderDetailsView(folder: folder)
                    }
                    
                    .padding(.top, 70)
                    
                    .navigationTitle("Library")
                    .navigationBarTitleDisplayMode(.inline)
                    
                } // <<< Fine ScrollView
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color(red: 0.95, green: 0.85, blue: 0.75))
                .edgesIgnoringSafeArea(.all)

                
            }
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button(action: {
                        showingAddFolderSheet = true
                    }) {
                        Image(systemName: "folder.badge.plus")
                            .foregroundColor(.black) // Imposta il colore
                    }
                }
            }
            
            // --- POP-UP (SHEET) (invariato) ---
            .sheet(isPresented: $showingAddFolderSheet) {
                VStack(spacing: 20) {
                    Text("New Folder")
                        .font(.headline)
                        .padding(.top, 20)

                    PhotosPicker(
                        selection: $selectedPhotoItem,
                        matching: .images,
                        photoLibrary: .shared()
                    ) {
                        VStack {
                            if let data = selectedPhotoData, let uiImage = UIImage(data: data) {
                                Image(uiImage: uiImage)
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 100, height: 100)
                                    .clipShape(RoundedRectangle(cornerRadius: 10))
                            } else {
                                Image(systemName: "photo.badge.plus")
                                    .font(.system(size: 60))
                                    .foregroundColor(.gray)
                                    .frame(width: 100, height: 100)
                                    .background(Color.gray.opacity(0.1))
                                    .clipShape(RoundedRectangle(cornerRadius: 10))
                            }
                            Text("Add icon")
                                .font(.caption)
                                .foregroundColor(.blue)
                        }
                    }
                    .onChange(of: selectedPhotoItem) {
                        Task {
                            if let data = try? await selectedPhotoItem?.loadTransferable(type: Data.self) {
                                selectedPhotoData = data
                            }
                        }
                    }
                    
                    TextField("Folder Name", text: $newFolderName)
                        .textFieldStyle(.roundedBorder)
                        .padding(.horizontal)
                    
                    Button("Save") {
                        let newFolder = Folder(name: newFolderName, iconData: selectedPhotoData)
                        modelContext.insert(newFolder)
                        
                        newFolderName = ""
                        selectedPhotoItem = nil
                        selectedPhotoData = nil
                        showingAddFolderSheet = false
                    }
                    .buttonStyle(.borderedProminent)
                    .disabled(newFolderName.isEmpty)
                    
                    Spacer()
                }
                .presentationDetents([.height(400)])
            }
        }
    }
}

#Preview {
    LibraryView()
        .modelContainer(for: [Folder.self, Film.self], inMemory: true)
}
