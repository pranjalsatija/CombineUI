//
//  ViewController.swift
//  Example
//
//  Created by pranjal on 1/23/20.
//  Copyright © 2020 pranjal. All rights reserved.
//

import CombineUI

class ViewController: CUIViewController {
    // MARK: State
    @Published(initialValue: 0.92)
    var sliderValue: Float
    
    // MARK: IBOutlets
    @IBOutlet var resetButton: UIButton!
    @IBOutlet var slider: UISlider!
    @IBOutlet var sliderValueLabel: UILabel!
    
    // MARK: Bindings
    override func configureBindings() {
        configureResetButtonBindings()
        configureSliderBindings()
        configureSliderValueBindings()
    }
    
    private func configureResetButtonBindings() {
        resetButton.publisher(for: .touchUpInside)
            .sink {(_) in self.sliderValue = 0.5 }
            .store(in: &cancellables)
    }
    
    private func configureSliderBindings() {
        slider.publisher(for: .valueChanged)
            .map { $0.value }
            .sink { self.sliderValue = $0 }
            .store(in: &cancellables)
    }
    
    private func configureSliderValueBindings() {
        $sliderValue
            .sink {
                self.sliderValueLabel.text = "Slider Value: \($0)"
                self.slider.value = $0
            }
            .store(in: &cancellables)
    }
}
