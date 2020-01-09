//
//  GameOfLife.swift
//  Life
//
//  Created by Nate Madera on 1/8/20.
//  Copyright © 2020 Nate Madera. All rights reserved.
//

import Foundation

protocol GameOfLifeDelegate: class {
    func gridDidChange(_ grid: [[Int]])
    func gameDidEnd()
}

class GameOfLife {
    // MARK: Properties
    private var timer: Timer?
    private var grid: [[Int]]
    private weak var delegate: GameOfLifeDelegate?
    
    // MARK: Initializer
    init(grid: [[Int]], delegate: GameOfLifeDelegate) {
        self.grid = grid
        self.delegate = delegate
    }
    
    deinit {
        timer?.invalidate()
    }
    
    // MARK: Public Functions
    func start() {
        startTimer()
    }
    
    func stop() {
        timer?.invalidate()
    }
}

// MARK: - Private Helpers
private extension GameOfLife {
    private func startTimer (){
        // Scheduling timer to Call the function "updateCounting" with the interval of 1 seconds
        timer = Timer.scheduledTimer(timeInterval: 1,
                                     target: self,
                                     selector: #selector(play),
                                     userInfo: nil,
                                     repeats: true)
    }
    
    @objc func play() {
        var outputGrid = grid
        
        // Iterate through two dem array
        for (r, row) in grid.enumerated() {
          for (c, _) in row.enumerated() {
            let neighbors = getNeighbors(grid: grid, r: r, c: c)
            
            if grid[r][c] == 1 {
                outputGrid[r][c] = transformActive(withNeighbors: neighbors)
            } else {
                outputGrid[r][c] = transformUnactive(withNeighbors: neighbors)
            }
          }
        }
        
        // Check for end
        if grid == outputGrid {
            delegate?.gameDidEnd()
            stop()
            return
        }
        
        grid = outputGrid
        
        delegate?.gridDidChange(grid)
    }
}

// MARK: - Game Play
private extension GameOfLife {
    func transformActive(withNeighbors neighbors: Int) -> Int {
        if neighbors <= 1 || neighbors >= 4 {
           return 0
        } else {
            return  1
        }
    }
    
    func transformUnactive(withNeighbors neighbors: Int) -> Int {
        return neighbors == 3 ? 1 : 0
    }
    
    func getNeighbors(grid: [[Int]], r: Int, c: Int) -> Int {
        let numberOfRows = grid.count
        let numberOfCols = grid[r].count
        
        var neighbors = 0

        // 1) Up -> [r - 1, c]
        if r - 1 >= 0  {
            neighbors += grid[r - 1][c]
        }
          
        // 2) Up Right -> [r - 1, c + 1]
        if r - 1 >= 0 && c + 1 < numberOfCols {
            neighbors += grid[r - 1][c + 1]
        }
        
        // 3) Right -> [r, c + 1]
        if c + 1 < numberOfCols {
            neighbors += grid[r][c + 1]
        }
          
        // 4) Down Right -> [r + 1, c + 1]
        if r + 1 < numberOfRows && c + 1 < numberOfCols {
           neighbors += grid[r + 1][c + 1]
        }
        
        // 5) Down -> [r + 1, c]
        if r + 1 < numberOfRows {
           neighbors += grid[r + 1][c]
        }

        // 6) Down Left -> [r + 1, c - 1]
        if r + 1 < numberOfRows && c - 1 >= 0 {
           neighbors += grid[r + 1][c - 1]
        }

        // 7) Left -> [r, c - 1]
        if c - 1 >= 0 {
           neighbors += grid[r][c - 1]
        }

        // 8) Up Left -> [r - 1, c - 1]
        if r - 1 >= 0 && c - 1 >= 0 {
           neighbors += grid[r - 1][c - 1]
        }
        
        return neighbors
    }
    
    func printGrid(_ grid: [[Int]]) {
        for row in grid.enumerated() {
            print(row.element)
        }
        
        print("")
    }
    
    func gridString(_ grid: [[Int]]) -> String {
        var string = ""
        
        for row in grid.enumerated() {
            let rowString = row.element.reduce("", { "\($0) \($1)" })
            string.append(rowString)
            string.append("\n")
        }
        
        return string
    }
}
