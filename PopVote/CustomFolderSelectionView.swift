import SwiftUI
import SwiftData

struct CustomFolderSelectionView: View {

    var folders: [Folder]
    

    @Binding var selectedID: PersistentIdentifier?
    
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        List {
            Button(action: {
                selectedID = nil
                dismiss()
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
            .foregroundColor(.primary)
            
            ForEach(folders) { folder in
                Button(action: {
                    selectedID = folder.id
                    dismiss()
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
        
        .scrollContentBackground(.hidden)

        .background(Color(red: 0.95, green: 0.85, blue: 0.75))
    }
}
