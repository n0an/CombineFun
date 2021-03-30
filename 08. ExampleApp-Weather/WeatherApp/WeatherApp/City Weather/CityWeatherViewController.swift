//
//  CityWeatherViewController.swift
//  WeatherApp
//
//  Created by Ben Scheirman on 9/18/20.
//

import UIKit
import WeatherKit
import Combine

class CityWeatherViewController: UIViewController {
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    enum Section: Int, CaseIterable {
        case currentWeather
        case hourlyForecast
        case weeklyForecast
    }
    
    var city: City! {
        didSet {
            viewModel = CityWeatherViewModel(city: city!)
        }
    }
    
    private var viewModel: CityWeatherViewModel!
    private var cancellables = Set<AnyCancellable>()
    
    private var dailyForecasts: [DailyForecastViewModel] = [] {
        didSet {
            collectionView.reloadSections(IndexSet([Section.weeklyForecast.rawValue]))
        }
    }
    
    private var hourlyForecasts: [HourlyForecastViewModel] = [] {
        didSet {
            collectionView.reloadSections(IndexSet([Section.hourlyForecast.rawValue]))
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
                
        navigationItem.title = viewModel.date
        edgesForExtendedLayout = .all
        
        collectionView.backgroundView = GradientView(colors: [.systemBlue, .systemTeal])
        collectionView.backgroundView?.alpha = 0.8

        setupCollectionView()
    }
    
    private func setupCollectionView() {
        collectionView.collectionViewLayout = CityWeatherLayout.createLayout()
        collectionView.backgroundColor = .clear
        
        viewModel.$dailyForecast
            .sink { [unowned self] in
                dailyForecasts = $0
            }
            .store(in: &cancellables)

        viewModel.$hourlyForecast
            .sink { [unowned self] in
                hourlyForecasts = $0
            }
            .store(in: &cancellables)
        
        
//        let df = viewModel.$dailyForecast.map { _ in () }
//        let hf = viewModel.$hourlyForecast.map { _ in () }
//
//        df.merge(with: hf)
//            .debounce(for: .milliseconds(100), scheduler: DispatchQueue.main)
//            .sink { [unowned self] _ in
//                collectionView.reloadData()
//            }
//            .store(in: &cancellables)
    }
}

extension CityWeatherViewController: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return Section.allCases.count
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        switch Section(rawValue: section) {
        case .currentWeather: return 1
        case .weeklyForecast: return dailyForecasts.count
        case .hourlyForecast: return min(7, hourlyForecasts.count)
        default: return 0
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        switch Section(rawValue: indexPath.section) {
        case .currentWeather:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CurrentWeatherCell", for: indexPath) as! CurrentWeatherCell
            cell.update(with: viewModel)
            return cell
            
        case .weeklyForecast:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "DailyWeatherCell", for: indexPath) as! DailyWeatherCell
            
            cell.update(with: dailyForecasts[indexPath.row])
            
            return cell
            
        case .hourlyForecast:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "HourlyWeatherCell", for: indexPath) as! HourlyWeatherCell
            
            cell.update(with: hourlyForecasts[indexPath.row])
            
            return cell
            
        default: return UICollectionViewCell()
        }
    }
}
