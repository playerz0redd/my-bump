//
//  ChatCollectionViewCell.swift
//  my-bump
//
//  Created by Pavel Playerz0redd on 8.06.26.
//

import Foundation
import UIKit
import Kingfisher

class ChatCollectionViewCell: UICollectionViewCell {
    
    override var isHighlighted: Bool {
        didSet {
            UIView.animate(withDuration: Constants.animationDuration) {
                self.contentView.alpha = self.isHighlighted ? Constants.highlightedAlpha : Constants.defaultAlpha
            }
        }
    }
    
    private let avatarImage: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.backgroundColor = .systemGray5
        return imageView
    }()
    
    private let chatNameLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: Constants.chatNameFontSize, weight: .semibold)
        label.textColor = .label
        return label
    }()
    
    private let lastMessageLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: Constants.messageFontSize, weight: .regular)
        label.textColor = .secondaryLabel
        label.numberOfLines = Constants.messageMaxLineCount
        return label
    }()
    
    private let lastMessageDateLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: Constants.messageDateFontSize, weight: .regular)
        label.textColor = .secondaryLabel
        return label
    }()
    
    private let unreadCountLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: Constants.unreadCountFontSize, weight: .semibold)
        label.textColor = .white
        label.backgroundColor = .secondaryLabel
        label.layer.cornerRadius = Constants.unreadCountCornerRadius
        label.textAlignment = .center
        label.clipsToBounds = true
        return label
    }()
    
    private let cellHorizontalStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.spacing = Constants.cellStackSpacing
        stack.alignment = .fill
        return stack
    }()
    
    private let chatInfoVerticalStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = Constants.chatInfoStackSpacing
        stack.alignment = .leading
        stack.distribution = .fill
        return stack
    }()
    
    private let messagesInfoVerticalStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = Constants.messageInfoSpacing
        stack.alignment = .trailing
        stack.distribution = .fill
        return stack
    }()
    
    private let leadingStackSpacer: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        view.setContentHuggingPriority(.init(Constants.huggingPriority), for: .vertical)
        return view
    }()
    
    private let trailingStackSpacer: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        view.setContentHuggingPriority(.init(Constants.huggingPriority), for: .vertical)
        return view
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(with chat: ChatModel) {
        chatNameLabel.text = chat.userWithName
        lastMessageLabel.text = chat.lastMessage
        lastMessageDateLabel.text = chat.lastMessageTime
        
        if let count = chat.unreadCount {
            unreadCountLabel.text = "\(count)"
            unreadCountLabel.isHidden = false
        } else {
            unreadCountLabel.isHidden = true
        }
        
        let config = UIImage.SymbolConfiguration(pointSize: Constants.symbolSize, weight: .regular)
        let placeholderImage = UIImage(systemName: Assets.photo.rawValue, withConfiguration: config)?
            .withTintColor(.systemGray3, renderingMode: .alwaysOriginal)
    
        avatarImage.contentMode = .center
        
        avatarImage.kf.setImage(with: chat.avatar, placeholder: placeholderImage, options: [
            .transition(.fade(Constants.fadeCoef)),
            .cacheOriginalImage
        ]) { [weak self] result in
            if case .success = result {
                self?.avatarImage.contentMode = .scaleAspectFill
            }
        }
    }
    
    private func setupLayout() {
        chatInfoVerticalStack.addArrangedSubview(chatNameLabel)
        chatInfoVerticalStack.addArrangedSubview(leadingStackSpacer)
        chatInfoVerticalStack.addArrangedSubview(lastMessageLabel)
        
        messagesInfoVerticalStack.addArrangedSubview(lastMessageDateLabel)
        messagesInfoVerticalStack.addArrangedSubview(trailingStackSpacer)
        messagesInfoVerticalStack.addArrangedSubview(unreadCountLabel)
        
        let avatarContainer = UIView()
        avatarContainer.addSubview(avatarImage)
        cellHorizontalStack.addArrangedSubview(avatarContainer)
        cellHorizontalStack.addArrangedSubview(chatInfoVerticalStack)
        cellHorizontalStack.addArrangedSubview(messagesInfoVerticalStack)
        
        contentView.addSubview(cellHorizontalStack)
        
        setupConstraints()
        NSLayoutConstraint.activate([
                avatarImage.centerYAnchor.constraint(equalTo: avatarContainer.centerYAnchor),
                avatarImage.leadingAnchor.constraint(equalTo: avatarContainer.leadingAnchor),
                avatarImage.trailingAnchor.constraint(equalTo: avatarContainer.trailingAnchor),
                avatarContainer.widthAnchor.constraint(equalToConstant: Constants.avatarContainerWidth)
            ])
        avatarImage.layer.cornerRadius = Constants.avatarCornerRadius
        unreadCountLabel.layer.cornerRadius = Constants.unreadCountLabelCornerRadius
        contentView.backgroundColor = .systemBackground
        contentView.layer.cornerRadius = Constants.contentViewCornerRadius
        contentView.layer.cornerCurve = .continuous
        contentView.clipsToBounds = true
        self.clipsToBounds = false
        self.backgroundColor = .clear
    }
    
    private func setupConstraints() {
        cellHorizontalStack.translatesAutoresizingMaskIntoConstraints = false
        avatarImage.translatesAutoresizingMaskIntoConstraints = false
        unreadCountLabel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            cellHorizontalStack.topAnchor.constraint(equalTo: contentView.topAnchor, constant: Constants.cellStackVerticalPadding),
            cellHorizontalStack.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: Constants.cellStackHorizontalPadding),
            cellHorizontalStack.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -Constants.cellStackHorizontalPadding),
            cellHorizontalStack.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -Constants.cellStackVerticalPadding),
            
            avatarImage.widthAnchor.constraint(equalToConstant: Constants.avatarSize),
            avatarImage.heightAnchor.constraint(equalToConstant: Constants.avatarSize),
            
            unreadCountLabel.widthAnchor.constraint(greaterThanOrEqualToConstant: Constants.unreadCountSize),
            unreadCountLabel.heightAnchor.constraint(equalToConstant: Constants.unreadCountSize),
            
            trailingStackSpacer.heightAnchor.constraint(equalToConstant: Constants.trailingStackSpacerHeigth),
            leadingStackSpacer.heightAnchor.constraint(equalToConstant: Constants.leadingStackSpacerHeigth)
        ])
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        avatarImage.kf.cancelDownloadTask()
        avatarImage.image = nil
        avatarImage.contentMode = .scaleAspectFill
    }
}

private extension ChatCollectionViewCell {
    enum Assets: String {
        case photo = "photo"
    }
}

private extension ChatCollectionViewCell {
    enum Constants {
        static let animationDuration: CGFloat = 0.1
        static let highlightedAlpha: CGFloat = 0.7
        static let defaultAlpha: CGFloat = 1
        static let chatNameFontSize: CGFloat = 19
        static let messageFontSize: CGFloat = 15
        static let messageMaxLineCount: Int = 2
        static let messageDateFontSize: CGFloat = 13
        static let unreadCountFontSize: CGFloat = 14
        static let unreadCountCornerRadius: CGFloat = 10
        static let cellStackSpacing: CGFloat = 10
        static let chatInfoStackSpacing: CGFloat = 0
        static let messageInfoSpacing: CGFloat = 0
        static let huggingPriority: Float = 1
        static let symbolSize: CGFloat = 22
        static let fadeCoef: CGFloat = 0.3
        static let avatarContainerWidth: CGFloat = 50
        static let avatarCornerRadius: CGFloat = 25
        static let unreadCountLabelCornerRadius: CGFloat = 12.5
        static let contentViewCornerRadius: CGFloat = 40
        static let cellStackVerticalPadding: CGFloat = 12
        static let cellStackHorizontalPadding: CGFloat = 16
        static let avatarSize: CGFloat = 50
        static let unreadCountSize: CGFloat = 25
        static let trailingStackSpacerHeigth: CGFloat = 5
        static let leadingStackSpacerHeigth: CGFloat = 0
    }
}
