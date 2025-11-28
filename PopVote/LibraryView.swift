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
    
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Folder.dateAdded) private var folders: [Folder]
    
    // Stati per aggiungere nuova cartella
    @State private var showingAddFolderSheet = false
    @State private var newFolderName = ""
    @State private var selectedPhotoItem: PhotosPickerItem?
    @State private var selectedPhotoData: Data?

    // --- NUOVO: Stati per la MODALITÀ SELEZIONE ---
    @State private var isSelectionMode = false // Siamo in modalità modifica?
    @State private var selectedFolders = Set<PersistentIdentifier>() // ID delle cartelle selezionate
    @State private var showDeleteConfirmation = false // Alert conferma

    // Layout Griglia
    private var gridColumns: [GridItem] = [
        GridItem(.adaptive(minimum: 120))
    ]

    var body: some View {
        NavigationStack {
            ZStack {
                
                ScrollView {
                    LazyVGrid(columns: gridColumns, spacing: 20) {
                        
                        ForEach(folders) { folder in
                            // Usiamo un ZStack per gestire sia il click normale che la selezione
                            ZStack {
                                // 1. Aspetto Visivo della Cartella
                                VStack {
                                    if let data = folder.iconData, let uiImage = UIImage(data: data) {
                                        Image(uiImage: uiImage)
                                            .resizable()
                                            .scaledToFill()
                                            .frame(width: 100, height: 100)
                                            .clipShape(RoundedRectangle(cornerRadius: 10))
                                            // Effetto visivo se selezionato
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
                                
                                // 2. Indicatore di Selezione (Spunta Blu)
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
                                    .frame(width: 100, height: 100) // Stessa dim dell'icona
                                }
                                
                                // 3. Gestione del Tocco
                                // Se NON siamo in selezione -> NavigationLink invisibile sopra tutto
                                if !isSelectionMode {
                                    NavigationLink(value: folder) {
                                        Color.clear // Invisibile, ma cliccabile
                                    }
                                } else {
                                    // Se SIAMO in selezione -> Bottone per selezionare
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
            // --- TOOLBAR AGGIORNATA ---
            .toolbar {
                // SINISTRA: Tasto "Edit" / "Done"
                ToolbarItem(placement: .topBarLeading) {
                    Button(isSelectionMode ? "Done" : "Select") {
                        withAnimation {
                            isSelectionMode.toggle()
                            selectedFolders.removeAll() // Pulisce selezione quando si esce/entra
                        }
                    }
                }
                
                // DESTRA: Mostra Cestino (se in selezione) OPPURE Aggiungi (se normale)
                ToolbarItem(placement: .topBarTrailing) {
                    if isSelectionMode {
                        // Tasto Cestino
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
                        // Tasto Aggiungi Cartella
                        Button(action: {
                            showingAddFolderSheet = true
                        }) {
                            Image(systemName: "folder.badge.plus")
                                .foregroundColor(.black)
                        }
                    }
                }
            }
            
            // ALERT Conferma Eliminazione
            .alert("Delete selected folders?", isPresented: $showDeleteConfirmation) {
                Button("Delete", role: .destructive) {
                    deleteSelected()
                }
                Button("Cancel", role: .cancel) { }
            } message: {
                Text("Movies inside these folders will not be deleted.")
            }
            
            // SHEET Aggiungi Cartella
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
    
    // LOGICA DI SELEZIONE
    private func toggleSelection(for folder: Folder) {
        if selectedFolders.contains(folder.id) {
            selectedFolders.remove(folder.id)
        } else {
            selectedFolders.insert(folder.id)
        }
    }
    
    // LOGICA DI CANCELLAZIONE
    private func deleteSelected() {
        withAnimation {
            // Cerchiamo le cartelle reali che corrispondono agli ID selezionati
            for folder in folders {
                if selectedFolders.contains(folder.id) {
                    modelContext.delete(folder)
                }
            }
            selectedFolders.removeAll()
            isSelectionMode = false // Esce dalla modalità edit
        }
    }
}
