//
//  DiceViewModel.swift
//  ExampleApp-HandlingErrors
//
//  Created by Ben Scheirman on 8/21/20.
//

import UIKit
import Combine

class DiceViewModel {
    private static var unknownDiceImage = UIImage(systemName: "questionmark.square.fill")!
    
    @Published
    var isRolling = false
    
    @Published
    var diceValue: Int?
    
    @Published
    var diceImage: UIImage = unknownDiceImage
    
    @Published
    var error: DiceError?
    
    private var rollSubject = PassthroughSubject<Void, Never>()
    private var cancellables: Set<AnyCancellable> = []
    
    enum DiceError: Error {
        case rolledOffTable
    }
    
    init() {
        rollSubject
            .flatMap { [unowned self] in
                roll()
                    .map { $0 as Int? }
                    .handleEvents(
                        receiveSubscription: { _ in
                            error = nil
                            isRolling = true
                        },
                        receiveCompletion: { _ in
                            isRolling = false
                        },
                        receiveCancel: {
                            isRolling = false
                        })
                    .catch { error -> Just<Int?> in
                        print("Error: \(error)")
                        self.error = error
                        return Just(nil)
                    }
            }
            .assign(to: &$diceValue)
            
        $diceValue
            .map { [unowned self] in diceImage(for: $0) }
            .assign(to: &$diceImage)
    }
    
    private func roll() -> AnyPublisher<Int, DiceError> {
        Future { promise in
            if Int.random(in: 1...4) == 1 {
                promise(.failure(DiceError.rolledOffTable))
            } else {
                let value = Int.random(in: 1...6)
                promise(.success(value))
            }
        }
        .delay(for: 1, scheduler: DispatchQueue.main)
        .eraseToAnyPublisher()
    }
    
    func rollDice() {
        rollSubject.send()
    }
    
    private func diceImage(for value: Int?) -> UIImage {
        switch value {
        case 1: return UIImage(named: "dice-one")!
        case 2: return UIImage(named: "dice-two")!
        case 3: return UIImage(named: "dice-three")!
        case 4: return UIImage(named: "dice-four")!
        case 5: return UIImage(named: "dice-five")!
        case 6: return UIImage(named: "dice-six")!
        default:
            return DiceViewModel.unknownDiceImage
        }
    }
}
