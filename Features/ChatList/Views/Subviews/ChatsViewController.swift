//
//  ChatsView.swift
//  my-bump
//
//  Created by Pavel Playerz0redd on 8.06.26.
//

import SwiftUI
import UIKit
import Combine

final class ChatsViewController: UIViewController {
    
    private var dataSource: UICollectionViewDiffableDataSource<Int, ChatModel>!
    private var cancellables: Set<AnyCancellable> = []
    private let viewModel: ChatListViewModel
    private let cellIdentifier = "chatCell"
    
    private let backgroundGradient: CAGradientLayer = {
        let gradient = CAGradientLayer()
        gradient.colors = [
            UIColor.systemPink.withAlphaComponent(Constants.gradientColorAlpha).cgColor,
            UIColor.systemBlue.withAlphaComponent(Constants.gradientColorAlpha).cgColor
        ]
        gradient.startPoint = .init(x: Constants.gradientStartX, y: Constants.gradientStartY)
        gradient.endPoint = .init(x: Constants.gradientEndX, y: Constants.gradientEndY)
        gradient.masksToBounds = false
        return gradient
    }()
    
    private let refreshControl: UIRefreshControl = {
        let control = UIRefreshControl()
        control.tintColor = .lightPink
        return control
    }()
    
    private let collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumLineSpacing = Constants.collectionLayoutSpacing
        
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .clear
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        return collectionView
    }()
    
    init(viewModel: ChatListViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .clear
        setupCollectionView()
        setupBindings()
        applyGradient()
        configureRefreshControl()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        view.layer.masksToBounds = false
        backgroundGradient.frame = view.bounds
    }
    
    private func reloadData(with chats: [ChatModel]) {
        var snapshot = NSDiffableDataSourceSnapshot<Int, ChatModel>()
        snapshot.appendSections([0])
        snapshot.appendItems(chats)
        dataSource.apply(snapshot, animatingDifferences: true)
    }
    
    private func applyGradient() {
        view.layer.insertSublayer(backgroundGradient, at: 0)
    }
    
    private func setupBindings() {
        viewModel.$visibleChats
            .receive(on: RunLoop.main)
            .sink { [weak self] chats in
                self?.reloadData(with: chats)
                if self?.refreshControl.isRefreshing == true {
                    self?.refreshControl.endRefreshing()
                }
            }
            .store(in: &cancellables)
    }
    
    private func configureRefreshControl() {
        refreshControl.addTarget(self, action: #selector(refresh), for: .valueChanged)
        collectionView.refreshControl = refreshControl
    }
    
    @objc
    private func refresh() {
        viewModel.fetchChats()
    }
    
    private func setupCollectionView() {
        dataSource = UICollectionViewDiffableDataSource<Int, ChatModel>(collectionView: collectionView) { [weak self] (collectionView, indexPath, chat) -> UICollectionViewCell? in
            
            guard let self = self, let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: cellIdentifier,
                for: indexPath
            ) as? ChatCollectionViewCell else { return UICollectionViewCell() }
            
            cell.configure(with: chat)
            return cell
        }
        collectionView.delegate = self
        collectionView.register(ChatCollectionViewCell.self, forCellWithReuseIdentifier: cellIdentifier)
        collectionView.clipsToBounds = false
        self.edgesForExtendedLayout = .all
        view.addSubview(collectionView)
        setupConstraits()
    }
    
    private func setupConstraits() {
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: view.topAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
}

private extension ChatsViewController {
    enum Constants {
        static let gradientColorAlpha: CGFloat = 0.2
        static let gradientStartX: CGFloat = 0.5
        static let gradientEndX: CGFloat = 0.5
        static let gradientStartY: CGFloat = 0
        static let gradientEndY: CGFloat = 1
        static let collectionLayoutSpacing: CGFloat = 20
        static let horizontalPadding: CGFloat = 16
        static let cellHeight: CGFloat = 80
    }
}

extension ChatsViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        guard let text = searchController.searchBar.text else { return }
        viewModel.searchChats(search: text)
        reloadData(with: viewModel.visibleChats)
    }
}

extension ChatsViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = collectionView.bounds.width - Constants.horizontalPadding * 2
        return CGSize(width: width, height: Constants.cellHeight)
    }
}

extension ChatsViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
        guard let clickedChat = dataSource.itemIdentifier(for: indexPath) else { return }
        viewModel.openChat(with: clickedChat.id)
    }
}

