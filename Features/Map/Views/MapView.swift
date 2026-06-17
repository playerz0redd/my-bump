//
//  MapView.swift
//  my-bump
//
//  Created by Pavel Playerz0redd on 21.04.26.
//

import Foundation
import SwiftUI
import CoreLocation
import MapKit
import Kingfisher

struct MapView: View {
    
    @Bindable private var viewModel: MapViewModel
    
    init(viewModel: MapViewModel) {
        self.viewModel = viewModel
    }
    
    var body: some View {
        Map {
            ForEach(viewModel.friendsState.keys.sorted(), id: \.self) { userId in
                if let coordinates = viewModel.friendsState[userId]?.location?.coordinates {
                    Annotation("", coordinate: coordinates) {
                        userAnnotationView(userId: userId)
                    }
                }
            }
            
            Annotation("My Location", coordinate: viewModel.myCoordinates) {
                Image(systemName: Assets.person.rawValue)
                    .foregroundStyle(.blue)
                    .font(.system(size: Constants.annotationImageSize))
            }
        }
        .animation(.easeInOut, value: viewModel.friendsState)
        .animation(.easeInOut, value: viewModel.myCoordinates)
    }
}

private extension MapView {
    func userAnnotationView(userId: String) -> some View {
        VStack(spacing: Constants.userAnnotationSpacing) {
            KFImage(viewModel.getUserAvatar(for: userId))
                .resizable()
                .placeholder {
                    RoundedRectangle(cornerRadius: Constants.annotationCornerRadius)
                        .foregroundStyle(.white)
                        .overlay {
                            ProgressView()
                        }
                }
                .scaledToFill()
                .keyframeAnimator(
                    initialValue: Constants.keyframeInitialValue,
                    repeating: true,
                    content: { content, value in
                        content
                            .frame(width: Constants.annotationWidth / value, height: Constants.annotationHeight * value)
                    }, keyframes: { _ in
                        LinearKeyframe(Constants.keyframeMaxValue, duration: Constants.keyframeDuration)
                        LinearKeyframe(Constants.keyframeInitialValue, duration: Constants.keyframeDuration)
                    }
                )
                .clipShape(RoundedRectangle(cornerRadius: Constants.annotationCornerRadius))
                .padding(Constants.annotationPadding)
                .background {
                    RoundedRectangle(cornerRadius: Constants.annotationCornerRadius)
                        .foregroundStyle(.white)
                        .overlay {
                            RoundedRectangle(cornerRadius: Constants.annotationCornerRadius)
                                .stroke(.black, lineWidth: Constants.annotationLinewidth)
                        }
                }
            
            Text(viewModel.getUsername(for: userId) ?? "noname")
                .font(.system(size: Constants.usernameFontSize, weight: .medium))
                .foregroundStyle(.black)
        }
    }
}

private extension MapView {
    enum Assets: String {
        case person = "person.fill"
    }
}

private extension MapView {
    enum Constants {
        static let cameraDistance: CLLocationDistance = 500
        static let annotationImageSize: CGFloat = 30
        static let userAnnotationSpacing: CGFloat = 5
        static let annotationCornerRadius: CGFloat = 30
        static let keyframeInitialValue: CGFloat = 1
        static let annotationWidth: CGFloat = 50
        static let annotationHeight: CGFloat = 55
        static let usernameFontSize: CGFloat = 14
        static let annotationPadding: CGFloat = 5
        static let annotationLinewidth: CGFloat = 1
        static let keyframeDuration: CGFloat = 1
        static let keyframeMaxValue: CGFloat = 1.2
    }
}
