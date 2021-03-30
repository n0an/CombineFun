//
//  ViewController.swift
//  ExampleApp-HandlingErrors
//
//  Created by Ben Scheirman on 8/21/20.
//

import UIKit
import Combine

class ViewController: UIViewController {
    @IBOutlet weak var diceImage: UIImageView!
    @IBOutlet weak var rollDiceButton: UIButton!
    
    private var cancellables = Set<AnyCancellable>()
    private var viewModel = DiceViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureDiceImage()
        
        viewModel.$diceImage
            .map { $0 as UIImage? }
            .assign(to: \.image, on: diceImage)
            .store(in: &cancellables)
        
        viewModel.$isRolling
            .map { !$0 }
            .assign(to: \.isEnabled, on: rollDiceButton)
            .store(in: &cancellables)
        
        viewModel.$isRolling
            .sink { [unowned self] isRolling in
                UIView.animate(withDuration: 0.5) {
                    diceImage.alpha = isRolling ? 0.5 : 1.0
                    diceImage.transform = isRolling ? CGAffineTransform(scaleX: 0.5, y: 0.5) : CGAffineTransform.identity
                }
            }
            .store(in: &cancellables)
        
        viewModel.$error
            .compactMap { $0 }
            .sink { [unowned self] error in
                let alert = UIAlertController(title: "Dice Error", message: "\(error)", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Dismiss", style: .cancel, handler: nil))
                alert.addAction(UIAlertAction(title: "Reroll", style: .default, handler: { _ in
                    rollDiceTapped(self)
                }))
                present(alert, animated: true, completion: nil)
            }
            .store(in: &cancellables)
    }
    
    private func configureDiceImage() {
        diceImage.layer.shadowColor = UIColor.black.cgColor
        diceImage.layer.shadowOpacity = 0.25
        diceImage.layer.shadowRadius = 2
        diceImage.layer.shadowOffset = .zero
    }

    @IBAction func rollDiceTapped(_ sender: Any) {
        viewModel.rollDice()
    }
}

