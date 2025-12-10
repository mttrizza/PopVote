import SwiftUI
import SwiftData

struct HomeView: View {
    @State private var showSplashScreen = true
    
    var body: some View {
        ZStack {
            VStack(spacing: 0) {
                
                HStack {
                    Text("POPVOTE")
                        .font(Font.custom("HoltwoodOneSC-Regular", size: 20))
                        .padding(.leading)
                    Spacer()
                }
                .padding(.top, 40)
                .padding(.bottom, 5)
                
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
                    
                    WishlistView()
                        .tabItem {
                            Image(systemName: "list.star")
                            Text("WishList")
                        }
                    
                    StatisticsView()
                        .tabItem {
                            Image(systemName: "chart.bar.fill")
                            Text("Stats")
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
            
            if showSplashScreen {
                VStack {
                    Spacer()
                    Text("POPVOTE")
                        .font(Font.custom("HoltwoodOneSC-Regular", size: 48))
                        .padding(.bottom, 30)
                    Image("popvote_splash")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 300)
                        .clipShape(RoundedRectangle(cornerRadius: 20))
                        .shadow(radius: 10)
                    Spacer()
                    Text("© Matti, Ale & Martha")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .padding(.bottom, 20)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color(red: 0.95, green: 0.85, blue: 0.75))
                .edgesIgnoringSafeArea(.all)
                .opacity(showSplashScreen ? 1 : 0)
                .animation(.easeOut(duration: 0.5), value: showSplashScreen)
                .onAppear {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                        showSplashScreen = false
                    }
                }
            }
        }
    }
}
