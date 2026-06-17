import Foundation
import SwiftUI
import PhotosUI

struct ImageSelectorModifier: ViewModifier {
    @State private var isShowingCamera: Bool = false
    @State private var selectedGalleryItem: PhotosPickerItem?
    @State private var isShowingGallery: Bool = false
    @Binding private var isShowingDialog: Bool
    private let onImagePick: (Data) -> Void
    
    init(isShowingDialog: Binding<Bool>, onImagePick: @escaping (Data) -> Void) {
        self._isShowingDialog = isShowingDialog
        self.onImagePick = onImagePick
    }
    
    func body(content: Content) -> some View {
        content
            .confirmationDialog(.chooseSource, isPresented: $isShowingDialog, titleVisibility: .hidden) {
                Button(.makeAnImage) {
                    isShowingCamera = true
                }
                
                Button(.takeFromLibrary) {
                    isShowingGallery = true
                }
                
                Button(.cancel, role: .cancel) {}
            }
            .background {
                Color.clear
                    .photosPicker(
                        isPresented: $isShowingGallery,
                        selection: $selectedGalleryItem,
                        matching: .images
                    )
                    .onChange(of: selectedGalleryItem) { _, newItem in
                        Task {
                            if let data = try? await newItem?.loadTransferable(type: Data.self) {
                                onImagePick(data)
                            }
                            selectedGalleryItem = nil
                        }
                    }
            }
            .background {
                Color.clear
                    .fullScreenCover(isPresented: $isShowingCamera) {
                        CameraView { data in
                            onImagePick(data)
                        }
                        .ignoresSafeArea()
                    }
            }
    }
}
