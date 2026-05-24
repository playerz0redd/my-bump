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
    @State private var cameraPosition: MapCameraPosition
    
    init(viewModel: MapViewModel) {
        self.viewModel = viewModel
        self.cameraPosition = .camera(.init(centerCoordinate: viewModel.myCoordinates, distance: Constants.cameraDistance))
    }
    
    var body: some View {
        Map(position: $cameraPosition) {
            ForEach(viewModel.friendsLocations.keys.sorted(), id: \.self) { userId in
                if let username = viewModel.friends[userId]?.name,
                    let coordinates = viewModel.friendsLocations[userId]?.coordinates,
                    let time = viewModel.friendsLocations[userId]?.updateTime {
                    Annotation("", coordinate: coordinates) {
                        userAnnotationView(userId: userId)
                    }
                }
            }
            
            Annotation("My Location", coordinate: viewModel.myCoordinates) {
                Image(systemName: "person.fill")
                    .foregroundStyle(.blue)
                    .font(.system(size: Constants.annotationImageSize))
            }
        }
        .animation(.easeInOut, value: viewModel.friendsLocations)
        .animation(.easeInOut, value: viewModel.myCoordinates)
    }
}

private extension MapView {
    func userAnnotationView(userId: String) -> some View {
        VStack(spacing: 5) {
            KFImage(viewModel.getUserAvatar(forUserId: userId))
                .resizable()
                .placeholder {
                    RoundedRectangle(cornerRadius: 30)
                        .foregroundStyle(.white)
                        .overlay {
                            ProgressView()
                        }
                }
                .scaledToFill()
                .keyframeAnimator(initialValue: 1, repeating: true, content: { content, value in
                    content
                        .frame(width: 50 / value, height: 55 * value)
                }, keyframes: { _ in
                    LinearKeyframe(1.2, duration: 1)
                    LinearKeyframe(1.0, duration: 1)
                })
                .clipShape( RoundedRectangle(cornerRadius: 30))
                .padding(5)
                .background {
                    RoundedRectangle(cornerRadius: 30)
                        .foregroundStyle(.white)
                        .overlay {
                            RoundedRectangle(cornerRadius: 30)
                                .stroke(.black, lineWidth: 1)
                        }
                }
            
            Text(viewModel.getUsername(forUserId: userId) ?? "noname")
                .font(.system(size: 14, weight: .medium))
                .foregroundStyle(.black)
        }
    }
}

private extension MapView {
    enum Constants {
        static let cameraDistance: CLLocationDistance = 500
        static let annotationImageSize: CGFloat = 30
    }
}

