//
//  ChatView.swift
//  my-bump
//
//  Created by Pavel Playerz0redd on 16.06.26.
//

import Foundation
import SwiftUI

struct ChatView: View {
    
    @Bindable private var viewModel: ChatViewModel
    
    init(viewModel: ChatViewModel) {
        self.viewModel = viewModel
    }
    
    var body: some View {
        ScrollView(showsIndicators: false) {
            LazyVStack {
                ForEach(viewModel.messages, id: \.self) { message in
                    messageView(message: message)
                        .rotationEffect(.degrees(Constants.rotationAngle))
                        .frame(maxWidth: .infinity, alignment: message.isMyMessage ? .trailing : .leading)
                }
            }
            .animation(.bouncy, value: viewModel.messages)
        }
        .rotationEffect(.degrees(Constants.rotationAngle))
        .background {
            Gradients.backgroundGradient
                .ignoresSafeArea()
        }
        .safeAreaInset(edge: .bottom) {
            inputSection
                .padding(.horizontal)
        }
        .navigationTitle(.chat)
        .navigationBarTitleDisplayMode(.inline)
    }
}

private extension ChatView {
    var inputSection: some View {
        HStack(spacing: Constants.inputSectionSpacing) {
            attachmentButton
            
            inputField
        }
    }
    
    var attachmentButton: some View {
        Button(action: viewModel.openAttachments) {
            Image(systemName: Assets.paperClip.rawValue)
                .font(.system(size: Constants.attachmentButtonImageFont))
                .padding(Constants.attachmentButtonPadding)
                .background(.ultraThinMaterial)
                .clipShape(.circle)
        }
    }
    
    var inputField: some View {
        HStack(spacing: Constants.inputFieldSpacing) {
            TextField("", text: $viewModel.messageText, prompt: Text(.message).font(.system(size: Constants.inputFieldFontSize, weight: .medium)))
                .padding(Constants.inputFieldPadding)
                .frame(maxWidth: .infinity)
                .font(.system(size: Constants.inputFieldFontSize, weight: .medium))
            
            if !viewModel.messageText.isEmpty {
                sendButton
            }
        }
        .background(.thinMaterial)
        .clipShape(.capsule)
        .animation(.bouncy, value: viewModel.messageText)
    }
    
    var sendButton: some View {
        Button(action: viewModel.sendMessage) {
            Image(systemName: Assets.plane.rawValue)
                .font(.system(size: Constants.sendButtonImageSize))
                .foregroundStyle(.white)
                .padding(Constants.sendButtonPadding)
                .background {
                    Capsule()
                        .foregroundStyle(.blue)
                }
                .transition(.opacity.combined(with: .scale))
        }
    }
}

private extension ChatView {
    func messageView(message: MessageModel) -> some View {
        VStack(alignment: message.isMyMessage ? .trailing : .leading, spacing: Constants.messageInfoSpacing) {
            VStack {
                if let text = message.text {
                    Text(text)
                        .multilineTextAlignment(.leading)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
            .padding()
            .background {
                MessageBubble()
                    .fill(message.isMyMessage ?
                          AnyShapeStyle(Gradients.pinkGradient) : AnyShapeStyle(Color.white)
                    )
                    .scaleEffect(x: message.isMyMessage ? 1 : -1, anchor: .center)
            }
            .frame(
                maxWidth: UIScreen.main.bounds.width / Constants.maxMessageWidthCoef,
                alignment: message.isMyMessage ? .trailing : .leading
            )
            .shadow(
                color: .black.opacity(Constants.shadowOpacity),
                radius: Constants.shadowRadius,
                y: Constants.shadowY
            )
            
            Text(message.messageTime)
                .font(.system(size: Constants.messageTimeFontSize, weight: .semibold))
                .foregroundStyle(.darkGray)
        }
    }
}

private extension ChatView {
    enum Assets: String {
        case plane = "paperplane.fill"
        case paperClip = "paperclip"
    }
}

private extension ChatView {
    enum Constants {
        static let inputSectionSpacing: CGFloat = 5
        static let attachmentButtonImageFont: CGFloat = 24
        static let attachmentButtonPadding: CGFloat = 5
        static let inputFieldSpacing: CGFloat = 5
        static let inputFieldFontSize: CGFloat = 17
        static let inputFieldPadding: CGFloat = 10
        static let sendButtonImageSize: CGFloat = 24
        static let sendButtonPadding: CGFloat = 5
        static let messageInfoSpacing: CGFloat = 5
        static let maxMessageWidthCoef: CGFloat = 1.5
        static let shadowOpacity: CGFloat = 0.15
        static let shadowRadius: CGFloat = 5
        static let shadowY: CGFloat = 5
        static let messageTimeFontSize: CGFloat = 16
        static let rotationAngle: CGFloat = 180
    }
}
