//
//  CustomFolderSelectionView.swift
//  PopVote
//
//  Created by Mattia Rizza on 03/11/25.
//

import SwiftUI
import SwiftData

struct CustomFolderSelectionView: View {
    // La lista di tutte le cartelle disponibili
    var folders: [Folder]
    
    // Il Binding all'ID della cartella selezionata in AddFilmView
    @Binding var selectedID: PersistentIdentifier?
    
    // Per chiudere questa vista
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        // Usiamo una List per l'elenco
        List {
            // Opzione "No Folder"
            Button(action: {
                selectedID = nil
                dismiss() // Torna indietro
            }) {
                HStack {
                    Text("No Folder")
                    Spacer()
                    if selectedID == nil {
                        Image(systemName: "checkmark")
                            .foregroundColor(.blue)
                    }
                }
            }
            .foregroundColor(.primary) // Rende il testo del bottone nero
            
            // Elenco di tutte le cartelle
            ForEach(folders) { folder in
                Button(action: {
                    selectedID = folder.id
                    dismiss() // Torna indietro
                }) {
                    HStack {
                        Text(folder.name)
                        Spacer()
                        if selectedID == folder.id {
                            Image(systemName: "checkmark")
                                .foregroundColor(.blue)
                        }
                    }
                }
                .foregroundColor(.primary)
            }
        }
        .navigationTitle("Select Folder")
        .navigationBarTitleDisplayMode(.inline)
        
        // <<< LA SOLUZIONE CHIAVE >>>
        // Rende lo sfondo della List trasparente
        .scrollContentBackground(.hidden)
        // Applica il tuo colore di sfondo all'intera vista
        .background(Color(red: 0.95, green: 0.85, blue: 0.75))
    }
}
