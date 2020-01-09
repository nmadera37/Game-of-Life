//
//  ViewController.swift
//  Life
//
//  Created by Nate Madera on 1/8/20.
//  Copyright © 2020 Nate Madera. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    // MARK: UI Elements
    private var collectionView: UICollectionView!
    private var startStopButton: UIButton!
    
    // MARK: Properties
    private var grid = [[Int]](repeating: [Int](repeating: 0, count: 11), count: 11)
    private var game: GameOfLife?
    
    // MARK: Constants
    private enum Constants {
        enum CollectionView {
            static let identifier = "lifeCell"
            static let numberOfRows = 10
            static let itemSize = CGSize(width: 30, height: 30)
            static let spacing = CGFloat(2)
            static let width = (Constants.CollectionView.itemSize.width * CGFloat(numberOfRows)) + (CGFloat(numberOfRows) * spacing)
        }
    }

    // MARK: View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()

        setupView()
    }
    
    @objc func tappedStartStop() {
        if game == nil {
            startStopButton.setTitle("STOP", for: .normal)
            let aGame = GameOfLife(grid: grid, delegate: self)
            
            game = aGame
            game?.start()
        } else {
            game?.stop()
            game = nil

            startStopButton.setTitle("START", for: .normal)
        }
    }
}

// MARK: - GameOfLifeDelegate
extension ViewController: GameOfLifeDelegate {
    func gridDidChange(_ grid: [[Int]]) {
        self.grid = grid
        collectionView.reloadData()
    }
    
    func gameDidEnd() {
        tappedStartStop()
        
        let alertController = UIAlertController(title: "Game Over", message: nil, preferredStyle: .alert)
        
        let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alertController.addAction(okAction)
        
        present(alertController, animated: true, completion: nil)
    }
}

// MARK: - UICollectionViewDataSource
extension ViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return grid.count * grid.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: Constants.CollectionView.identifier,
                                                            for: indexPath) as? LifeCell else {
            fatalError()
        }
        
        let col = indexPath.row % Constants.CollectionView.numberOfRows
        let row = indexPath.row / Constants.CollectionView.numberOfRows
        let item = grid[col][row]

        cell.backgroundColor = item == 1 ? .dodgerBlue : .white

        return cell
    }
}

extension ViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let col = indexPath.row % Constants.CollectionView.numberOfRows
        let row = indexPath.row / Constants.CollectionView.numberOfRows
                
        grid[col][row] = grid[col][row] == 1 ? 0 : 1
        
        collectionView.reloadItems(at: [indexPath])
    }
}

// MARK: - Private Setup
private extension ViewController {
    func setupView() {
        title = "Game of Life"
        navigationController?.navigationBar.prefersLargeTitles = true
        
        view.backgroundColor = .white
        
        setupCollectionView()
        setupStartStopButton()
        
        addConstraintsForColelctionView()
        addConstraintsForStartStopButton()
    }
    
    func setupCollectionView() {
        let aLayout = UICollectionViewFlowLayout()
        aLayout.itemSize = Constants.CollectionView.itemSize
        aLayout.minimumLineSpacing = Constants.CollectionView.spacing
        aLayout.minimumInteritemSpacing = Constants.CollectionView.spacing
        
        let aCollectionView = UICollectionView(frame: .zero, collectionViewLayout: aLayout)
        aCollectionView.register(LifeCell.self, forCellWithReuseIdentifier: Constants.CollectionView.identifier)
        aCollectionView.layer.borderColor = UIColor.lightGray.cgColor
        aCollectionView.layer.borderWidth = Constants.CollectionView.spacing
        aCollectionView.allowsMultipleSelection = true
        aCollectionView.isScrollEnabled = false
        aCollectionView.backgroundColor = .lightGray
        aCollectionView.dataSource = self
        aCollectionView.delegate = self
        
        collectionView = aCollectionView
        
        view.addSubview(collectionView)
    }
    
    func setupStartStopButton() {
        let aButton = UIButton(type: .custom)
        aButton.backgroundColor = .dodgerBlue
        aButton.layer.cornerRadius = 6.0
        aButton.clipsToBounds = true
        aButton.setTitle("START", for: .normal)
        aButton.addTarget(self, action: #selector(tappedStartStop), for: .touchUpInside)
        
        startStopButton = aButton
        
        view.addSubview(startStopButton)
    }
    
    // MARK: Layout Constraints
    func addConstraintsForColelctionView() {
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            collectionView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            collectionView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            collectionView.widthAnchor.constraint(equalToConstant: Constants.CollectionView.width),
            collectionView.heightAnchor.constraint(equalToConstant: Constants.CollectionView.width)
        ])
    }
    
    func addConstraintsForStartStopButton() {
        startStopButton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            startStopButton.topAnchor.constraint(equalTo: collectionView.bottomAnchor, constant: 20.0),
            startStopButton.leftAnchor.constraint(equalTo: collectionView.leftAnchor, constant: 0.0),
            startStopButton.rightAnchor.constraint(equalTo: collectionView.rightAnchor, constant: 0.0),
            startStopButton.heightAnchor.constraint(equalToConstant: 50.0)
        ])
    }
}

