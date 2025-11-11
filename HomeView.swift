//
//  HomeView.swift
//  PopVote
//
//  Created by Mattia Rizza on 02/11/25.
//

import SwiftUI
import SwiftData

struct HomeView: View {
    // <<< NUOVO: Variabile di stato per controllare la visibilità della splash screen
    @State private var showSplashScreen = true
    
    var body: some View {
        // <<< MODIFICA: Usiamo un ZStack per sovrapporre la splash screen alla TabView
        ZStack {
            // --- CONTENUTO PRINCIPALE (La tua TabView) ---
            // Questo blocco sarà sempre sotto la splash screen
            // e apparirà quando showSplashScreen diventa false.
            VStack(spacing: 0) {
                
                // <<< INVARIATO: Header globale "POPVOTE" >>>
                HStack {
                    Text("POPVOTE")
                        .font(Font.custom("HoltwoodOneSC-Regular", size: 20))
                        .padding(.leading)
                    
                    Spacer()
                }
                .padding(.top, 40)
                .padding(.bottom, 5)
                
                // <<< INVARIATO: La tua TabView >>>
                TabView {
                    LibraryView()
                        .tabItem {
                            Image(systemName: "books.vertical.fill")
                            Text("Library")
                        }
                    
                    AllFilmsView()
                        .tabItem {
                            Image(systemName: "film.stack")
                            Text("All Films")
                        }
                    
                    AddFilmView()
                        .tabItem {
                            Image(systemName: "plus.circle.fill")
                            Text("Add")
                        }
                }
            }
            .background(Color(red: 0.95, green: 0.85, blue: 0.75))
            .edgesIgnoringSafeArea(.top)
            
            // --- SPLASH SCREEN (Mostrata condizionalmente) ---
            // Questo blocco sarà visibile solo se showSplashScreen è true
            if showSplashScreen {
                VStack {
                    Spacer() // Spinge il titolo e l'immagine verso l'alto
                    
                    // Titolo POPVOTE centrale sulla splash screen
                    Text("POPVOTE")
                        .font(Font.custom("HoltwoodOneSC-Regular", size: 48)) // Più grande per la splash
                        .padding(.bottom, 30) // Spazio sotto il titolo
                    
                    // La tua immagine
                    Image("popvote_splash") // <<< Assicurati che il nome sia corretto
                        .resizable()
                        .scaledToFit()
                        .frame(width: 300) // Regola la dimensione come preferisci
                        .clipShape(RoundedRectangle(cornerRadius: 20)) // Bordi arrotondati all'immagine
                        .shadow(radius: 10) // Un po' di ombra
                    
                    Spacer() // Spinge il copyright in basso
                    
                    // Copyright
                    Text("© Matti, Ale & Martha")
                        .font(.caption) // Testo piccolo
                        .foregroundColor(.secondary) // Colore grigio chiaro
                        .padding(.bottom, 20) // Spazio dal fondo
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity) // Occupa tutto lo schermo
                .background(Color(red: 0.95, green: 0.85, blue: 0.75)) // Colore di sfondo uguale
                .edgesIgnoringSafeArea(.all) // Estende lo sfondo a tutto schermo
                // <<< NUOVO: Applicazione della dissolvenza e del timer
                .opacity(showSplashScreen ? 1 : 0) // Controlla l'opacità per la dissolvenza
                .animation(.easeOut(duration: 0.5), value: showSplashScreen) // Animazione di 0.5 secondi
                .onAppear {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 3) { // Aspetta 3 secondi
                        showSplashScreen = false // Fai scomparire la splash
                    }
                }
            }
        }
    }
}

#Preview {
    HomeView()
        .modelContainer(for: [Folder.self, Film.self], inMemory: true)
}
