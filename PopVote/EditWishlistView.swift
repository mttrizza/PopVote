//
//  EditWishlistView.swift
//  PopVote
//
//  Created by Mattia Rizza on [Data Odierna].
//

import SwiftUI
import SwiftData
import PhotosUI

struct EditWishlistView: View {
    
    // Riceviamo l'oggetto da modificare
    @Bindable var item: WishlistItem
    
    @Environment(\.dismiss) private var dismiss
    
    // Stati temporanei per le modifiche
    @State private var title: String
    @State private var selectedPosterItem: PhotosPickerItem?
    @State private var selectedPosterData: Data?
    
    // Inizializzatore per caricare i dati esistenti
    init(item: WishlistItem) {
        self.item = item
        _title = State(initialValue: item.title)
        _selectedPosterData = State(initialValue: item.posterData)
    }
    
    var body: some View {
        NavigationStack {
            VStack {
                // --- Image Picker ---
                PhotosPicker(selection: $selectedPosterItem, matching: .images, photoLibrary: .shared()) {
                    VStack {
                        if let data = selectedPosterData, let uiImage = UIImage(data: data) {
                            Image(uiImage: uiImage)
                                .resizable().scaledToFill()
                                .frame(width: 150, height: 200)
                                .clipShape(RoundedRectangle(cornerRadius: 10))
                        } else {
                            Image(systemName: "popcorn.fill")
                                .font(.system(size: 80)).foregroundColor(.gray)
                                .frame(width: 150, height: 200)
                                .background(Color.gray.opacity(0.1))
                                .clipShape(RoundedRectangle(cornerRadius: 10))
                        }
                        Text("Change Poster").font(.caption).foregroundColor(.blue)
                    }
                }
                .padding(.top, 20)
                .onChange(of: selectedPosterItem) {
                    Task {
                        if let data = try? await selectedPosterItem?.loadTransferable(type: Data.self) {
                            selectedPosterData = data
                        }
                    }
                }
                
                // --- Campo Titolo ---
                TextField("Movie Title", text: $title)
                    .textFieldStyle(.roundedBorder)
                    .padding()
                
                Spacer()
            }
            .navigationTitle("Edit Movie")
            .navigationBarTitleDisplayMode(.inline)
            .background(Color(red: 0.95, green: 0.85, blue: 0.75))
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Save") {
                        // Salviamo le modifiche
                        item.title = title
                        item.posterData = selectedPosterData
                        dismiss()
                    }
                    .disabled(title.isEmpty)
                }
            }
        }
    }
}
