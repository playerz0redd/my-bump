//
//  InputField.swift
//  my-bump
//
//  Created by Pavel Playerz0redd on 14.04.26.
//

import Foundation
import SwiftUI

struct InputField<Content: View>: View {
    
    @Binding private var text: String
    
    private let errorMessage: LocalizedStringResource?
    private let fieldType: AuthViewModel.FieldType
    private let additionalContent: (() -> Content)?
    
    init(
        text: Binding<String>,
        errorMessage: LocalizedStringResource?,
        fieldType: AuthViewModel.FieldType,
        @ViewBuilder additionalContent: @escaping () -> Content
    ) {
        self._text = text
        self.errorMessage = errorMessage
        self.fieldType = fieldType
        self.additionalContent = additionalContent
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: InputFieldConstants.textFieldElementsSpacing) {
            textFieldTitleView
            
            textField
            
            validationErrorView
            
        }
    }
}

private extension InputField {
    var textFieldTitleView: some View {
        
        HStack {
            Text(fieldType.title)
                .font(.system(size: InputFieldConstants.textFontSize, weight: .semibold))
                .foregroundStyle(.darkGray)
            
            Spacer()
            
            if let additionalContent = additionalContent {
                additionalContent()
            }
        }
        .padding(.horizontal, InputFieldConstants.fieldHorizontalSpacing)
    }
}

private extension InputField {
    @ViewBuilder
    var validationErrorView: some View {
        if let errorMessage = errorMessage {
            Text(errorMessage)
                .foregroundStyle(.red)
                .font(.system(size: InputFieldConstants.textFontSize, weight: .semibold))
                .padding(.leading, InputFieldConstants.leadingOffset)
        }
    }
}

private extension InputField {
    
    var textField: some View {
        HStack(spacing: InputFieldConstants.inputFieldPlaceholderSpacing) {
            Image(systemName: fieldType.image)
                .font(.system(size: InputFieldConstants.inputTextFontSize, weight: .medium))
                .foregroundStyle(.darkGray)
                .frame(
                    width: InputFieldConstants.placeholderImageFrame.width,
                    height: InputFieldConstants.placeholderImageFrame.height
                )
            
            textFieldTypeSelector
        }
        .padding(InputFieldConstants.placeholderPaddingForBackCapsule)
        .background {
            Capsule()
                .foregroundStyle(.lightGray)
        }
    }
    
    var textFieldTypeSelector: some View {
        Group {
            if fieldType.isPassword {
                SecureField("", text: $text, prompt: Text(fieldType.placeholder).foregroundStyle(.darkGray))
            } else {
                TextField("", text: $text, prompt: Text(fieldType.placeholder).foregroundStyle(.darkGray))
            }
        }
        .autocorrectionDisabled()
        .textInputAutocapitalization(.never)
        .keyboardType(fieldType.keyboardType)
        .foregroundStyle(.darkGray)
        .font(.system(size: InputFieldConstants.inputTextFontSize, weight: .medium))
    }
}

fileprivate extension AuthViewModel.FieldType {
    var keyboardType: UIKeyboardType {
        switch self {
        case .name:
                .default
        case .email:
                .emailAddress
        case .password:
                .default
        case .confirmPassword:
                .default
        }
    }
}

extension InputField where Content == EmptyView {
    init(
        text: Binding<String>,
        errorMessage: LocalizedStringResource? = nil,
        fieldType: AuthViewModel.FieldType
    ) {
        self._text = text
        self.errorMessage = errorMessage
        self.fieldType = fieldType
        self.additionalContent = nil
    }
}

private enum InputFieldConstants {
    static let textFieldElementsSpacing: CGFloat = 7
    static let textFontSize: CGFloat = 15
    static let fieldHorizontalSpacing: CGFloat = 8
    static let leadingOffset: CGFloat = 7
    static let inputTextFontSize: CGFloat = 20
    static let inputFieldPlaceholderSpacing: CGFloat = 10
    static let placeholderImageFrame: CGSize = CGSize(width: 30, height: 30)
    static let placeholderPaddingForBackCapsule: CGFloat = 15
}

